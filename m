From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 11 Jan 2009 17:00:37 +0100
Message-ID: <496A17A5.7010200@cosmosbay.com>
References: <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <20090109224258.GA10257@ioremap.net> <496850D5.8040907@cosmosbay.com> <20090111125759.GB24173@ioremap.net> <4969F0D1.8020504@cosmosbay.com> <20090111133533.GB25337@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:36151 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396AbZAKRKk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 12:10:40 -0500
In-Reply-To: <20090111133533.GB25337@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Sun, Jan 11, 2009 at 02:14:57PM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>>>> 1) the release_sock/lock_sock done in tcp_splice_read() is not nec=
essary
>>>> to process backlog. Its already done in skb_splice_bits()
>>> Yes, in the tcp_splice_read() they are added to remove a deadlock.
>> Could you elaborate ? A deadlock only if !SPLICE_F_NONBLOCK ?
>=20
> Sorry, I meant that we drop lock in skb_splice_bits() to prevent the =
deadlock,
> and tcp_splice_read() needs it to process the backlog.

While we drop lock in skb_splice_bits() to prevent the deadlock, we
also process backlog at this stage. No need to process backlog
again in the higher level function.

>=20
> I think that even with non-blocking splice that release_sock/lock_soc=
k
> is needed, since we are able to do a parallel job: to receive new dat=
a
> (scheduled by early release_sock backlog processing) in bh and to
> process already received data via splice codepath.
> Maybe in non-blocking splice mode this is not an issue though, but fo=
r
> the blocking mode this allows to grab more skbs at once in skb_splice=
_bits.

skb_splice_bits() operates on one skb, you lost me :)



