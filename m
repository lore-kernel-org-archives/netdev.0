From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] skb align patch
Date: Mon, 21 Sep 2009 21:30:11 -0700
Message-ID: <20090921213011.704e0594@nehalam>
References: <20090920142212.1106d2a1@s6510>
	<4AB71980.4020208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60375 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbZIVEaN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 00:30:13 -0400
In-Reply-To: <4AB71980.4020208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Sep 2009 08:13:20 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Based on the Intel suggestion that PCI-express overhead is
> > a significant cost.
> >=20
> > Would people doing performance please measure the impact of
> > changing SKB alignment (64 bit only).
>=20
> I had this idea some time ago when I hit a limit on bnx2 adapter
> (Giga bit link, BCM5708S), with small packets. pktgen was able
> to send ~500 Mbps 'only', or 700kps if I remember well.
> So I tried to align the pktgen build packet to a cache line,
> it gave no difference at all, but it was on a 32 bit kernel.
> (Thus my patch was for pktgen only, not a generic one as yours)
>=20
> Could you elaborate why this change could be useful on 64bit ?
>=20

It is useful on all architecture where unaligned CPU access is
relatively cheap.

The issue is that a unaligned DMA requires a read/modify/write
cache line access versus just a write access. I am not a bus
expert, but writes are probably more pipelined as well.

--=20
