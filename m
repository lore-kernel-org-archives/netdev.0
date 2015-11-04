From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 04 Nov 2015 15:09:17 +0100
Message-ID: <2511200.aYIar34voW@stwm.de>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <3363088.63t9TqhiQf@stwm.de> <1446640851.4184.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:57225 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932178AbbKDOJU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 09:09:20 -0500
In-Reply-To: <1446640851.4184.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 4. November 2015, 04:40:51 schrieb Eric Dumazet:
> On Wed, 2015-11-04 at 13:19 +0100, Wolfgang Walter wrote:
> > Today I found a problem: on a router forwarding GRE-packets (ipv4) =
(it is
> > not the endpount) the interface (intel igb) stops sending packets a=
fter
> > some time. I think this happens when an ISATAP packet is inside the
> > GRE-packet.>=20
> > 	gre packets arrives on eth0
> > 	eth1 stops sending (receiving still works)
> > 	ethtool -r eth1
> > 	eth1 works again for some time
> >=20
> > Switching GRO off on eth0 "fixes" the problem.
> >=20
> > I didn't test vanilla 4.1.12 yet, though. Until today 4.1.11 has be=
en
> > running on the router. What I tested was your patch
> >=20
> > 	"gre_gso_segment() chokes if SIT frames were aggregated by GRO=20
engine."
> >=20
> > but did not solve the problem.
> >=20
> > So I would not recommend to backport it to longterm 4.1.
> >=20
> > My plans are:
> >=20
> > * test vanilla 4.1.12
> > * test 4.3
> >=20
> > I want to test 4.3 on another router first, though.
>=20
> If the NIC stops sending packets after some time, it might be an igb
> issue.

Yes, maybe igb has a problem sending a gro-packet if it is an isatap in=
 gre.

igb has no problem sending gro-packets which are pure isatap or which a=
re ipv4=20
(tcp/udp) in gre with 4.1.12 + these patches.

And it had no problem with 4.1.11 with isatap in gre.

Disabling gso for the interface does help.

I'll test pure 4.1.12 soon.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
