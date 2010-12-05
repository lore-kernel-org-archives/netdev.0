From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Sun, 05 Dec 2010 17:49:16 +0100
Message-ID: <1291567756.2806.258.camel@edumazet-laptop>
References: <20101203101450.GA9573@Desktop-Junchang>
	 <1291373429.2897.96.camel@edumazet-laptop>
	 <20101204141826.GA5830@Desktop-Junchang>
	 <1291474058.2806.96.camel@edumazet-laptop>
	 <20101205105616.GA4770@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45773 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174Ab0LEQtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 11:49:24 -0500
Received: by wyb28 with SMTP id 28so11228565wyb.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 08:49:23 -0800 (PST)
In-Reply-To: <20101205105616.GA4770@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 d=C3=A9cembre 2010 =C3=A0 18:56 +0800, Junchang Wang a =C3=
=A9crit :
> On Sat, Dec 04, 2010 at 03:47:38PM +0100, Eric Dumazet wrote:
> >
> >Yes I believe so, pktgen being very specific, but I have few questio=
ns :
> >
> >Is it with SLUB or SLAB ?
> I had read your discussion about "net: allocate skbs on local node" i=
n
> the list, so SLUB was used.


>=20
> BTW, what I observed is that network subsystem scales well on NUMA
> systems equipped with a single processor(up to six cores), but the
> performance didn't scale very well if there are two processors.=20
>=20
> I have noticed there are a number of discussions in the list. Are=20
> there any suggestions? I'm very pleasant to do test.
>=20
> >
> >How many buffers in TX ring on you nic (ethtool -g eth0) ?
> >
> Pre-set maximums:
> RX:             4096
> RX Mini:        0
> RX Jumbo:       0
> TX:             4096
> Current hardware settings:
> RX:             512
> RX Mini:        0
> RX Jumbo:       0
> TX:             512
>=20
> >What is the datalen value here ? (you prefetch, then advance skb->da=
ta)
> >
> 16. But the following skb_push will drawback 14 bytes.
>=20
> >32 or 64bit kernel ?
> >
> This is a CentOS 5.5 - 64bit distribution with the latest net-next.
>=20
> >How many pps do you get before and after patch ?
> >
> A Intel SR1625 server with two E5530 quad-core processors and a singl=
e
> ixgbe-based NIC.
> Without prefetch: 8.63 Mpps
> With prefetch: 9.03 Mpps
> Improvement: 4.6%
>=20
>=20

Thanks Junchang, please submit your pktgen patch with the two added
prefetchw(), I'll Ack it :)



