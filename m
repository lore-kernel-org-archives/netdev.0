From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] skb align patch
Date: Mon, 21 Sep 2009 08:13:20 +0200
Message-ID: <4AB71980.4020208@gmail.com>
References: <20090920142212.1106d2a1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47602 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbZIUGNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 02:13:22 -0400
In-Reply-To: <20090920142212.1106d2a1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Based on the Intel suggestion that PCI-express overhead is
> a significant cost.
>=20
> Would people doing performance please measure the impact of
> changing SKB alignment (64 bit only).

I had this idea some time ago when I hit a limit on bnx2 adapter
(Giga bit link, BCM5708S), with small packets. pktgen was able
to send ~500 Mbps 'only', or 700kps if I remember well.
So I tried to align the pktgen build packet to a cache line,
it gave no difference at all, but it was on a 32 bit kernel.
(Thus my patch was for pktgen only, not a generic one as yours)

Could you elaborate why this change could be useful on 64bit ?

Thanks

>=20
>=20
> --- a/arch/x86/include/asm/system.h	2009-09-20 14:08:40.922346912 -07=
00
> +++ b/arch/x86/include/asm/system.h	2009-09-20 14:14:37.012371200 -07=
00
> @@ -455,4 +455,14 @@ static inline void rdtsc_barrier(void)
>  	alternative(ASM_NOP3, "lfence", X86_FEATURE_LFENCE_RDTSC);
>  }
> =20
> +#ifndef CONFIG_X86_32
> +/*
> + * DMA to unaligned address is more expensive than the the
> + * overhead of unaligned CPU access.
> + */
> +#define NET_IP_ALIGN	0
> +#define NET_SKB_PAD	L1_CACHE_BYTES
> +#endif
> +
> +
>  #endif /* _ASM_X86_SYSTEM_H */
> --

