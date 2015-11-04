From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 04 Nov 2015 13:19:43 +0100
Message-ID: <3363088.63t9TqhiQf@stwm.de>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <19837690.PaPkekjCr9@stwm.de> <1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:55083 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965423AbbKDMT7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 07:19:59 -0500
In-Reply-To: <1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 3. November 2015, 05:07:33 schrieb Eric Dumazet:
> On Tue, 2015-11-03 at 13:57 +0100, Wolfgang Walter wrote:
> > Am Montag, 19. Oktober 2015, 20:40:17 schrieb Eric Dumazet:
> > > From: Eric Dumazet <edumazet@google.com>
> > >=20
> > > Tom Herbert added SIT support to GRO with commit
> > > 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
> > > later reverted by Herbert Xu.
> > >=20
> > > The problem came because Tom patch was building GRO
> > > packets without proper meta data : If packets were locally
> > > delivered, we would not care.
> > >=20
> > > But if packets needed to be forwarded, GSO engine was not
> > > able to segment individual segments.
> > >=20
> > > With the following patch, we correctly set skb->encapsulation
> > > and inner network header. We also update gso_type.
> >=20
> > I'm running 4.1.11 / 4.1.12 with this patch on top now since over a=
 week.
> > ISATAP works fine.
>=20
> Perfect ! thanks a lot for testing !

Today I found a problem: on a router forwarding GRE-packets (ipv4) (it =
is not=20
the endpount) the interface (intel igb) stops sending packets after som=
e time.=20
I think this happens when an ISATAP packet is inside the GRE-packet.

	gre packets arrives on eth0
	eth1 stops sending (receiving still works)
	ethtool -r eth1
	eth1 works again for some time

Switching GRO off on eth0 "fixes" the problem.

I didn't test vanilla 4.1.12 yet, though. Until today 4.1.11 has been r=
unning=20
on the router. What I tested was your patch
	"gre_gso_segment() chokes if SIT frames were aggregated by GRO engine.=
"
but did not solve the problem.

So I would not recommend to backport it to longterm 4.1.

My plans are:

* test vanilla 4.1.12
* test 4.3

I want to test 4.3 on another router first, though.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
