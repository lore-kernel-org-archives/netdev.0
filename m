From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] solos-pci: Increase headroom on received packets
Date: Wed, 16 Sep 2015 03:53:33 -0700
Message-ID: <1442400813.4116.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442399145.131189.56.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, simon@fire.lp0.eu, guy@traverse.com.au,
	linux-atm-general@lists.sourceforge.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36790 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbbIPKxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 06:53:35 -0400
Received: by padhk3 with SMTP id hk3so206248255pad.3
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 03:53:35 -0700 (PDT)
In-Reply-To: <1442399145.131189.56.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-16 at 11:25 +0100, David Woodhouse wrote:
> A comment in include/linux/skbuff.h says that:
>=20
>  * Various parts of the networking layer expect at least 32 bytes of
>  * headroom, you should not reduce this.
>=20
> This was demonstrated by a panic when handling fragmented IPv6 packet=
s:
> http://marc.info/?l=3Dlinux-netdev&m=3D144236093519172&w=3D2
>=20
> It's not entirely clear if that comment is still valid =E2=80=94 and =
if it is,
> perhaps netif_rx() ought to be enforcing it with a warning.
>=20
> But either way, it is rather stupid from a performance point of view
> for us to be receiving packets into a buffer which doesn't have enoug=
h
> room to prepend an Ethernet header =E2=80=94 it means that *every* in=
coming
> packet is going to be need to be reallocated. So let's fix that.
>=20
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---=20
> Tested in the DMA code path; I don't believe the DMA-capable devices
> can still be used in MMIO mode. Simon, Guy, would you be able to test
> the MMIO version?

You should use netdev_alloc_skb() : This helper is better for rx skbs,
as it allows for better packing of frames in GRO or TCP stack.

Also netdev_alloc_skb_ip_align() might handle the NET_IP_ALIGN stuff
for arches that care.
