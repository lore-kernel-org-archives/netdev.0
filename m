From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 07:15:21 +0200
Message-ID: <1273209321.2222.36.camel@edumazet-laptop>
References: <1273037049.2304.7.camel@edumazet-laptop>
	 <20100506.220221.90798296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com,
	monstr@monstr.eu, microblaze-uclinux@itee.uq.edu.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58506 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab0EGFP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:15:29 -0400
Received: by bwz19 with SMTP id 19so366607bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 22:15:27 -0700 (PDT)
In-Reply-To: <20100506.220221.90798296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 22:02 -0700, David Miller a =C3=A9crit :

> Seeing this made me go check who was overriding NET_IP_ALIGN or
> NET_SKB_PAD.
>=20
> The powerpc bits are legitimate, but the microblaze case is complete
> bogosity.  It defines NET_IP_ALIGN to the default (2) and sets
> NET_SKB_PAD to L1_CACHE_BYTES which on microblaze is 4 and
> significantly smaller than the default.
>=20
> So I'm going to delete them in net-next-2.6 like so:
>=20
> --------------------
> microblaze: Kill NET_SKB_PAD and NET_IP_ALIGN overrides.
>=20
> NET_IP_ALIGN defaults to 2, no need to override.
>=20
> NET_SKB_PAD is now 64, which is much larger than microblaze's
> L1_CACHE_SIZE so no need to override that either.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  arch/microblaze/include/asm/system.h |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)
>=20
> diff --git a/arch/microblaze/include/asm/system.h b/arch/microblaze/i=
nclude/asm/system.h
> index 48c4f03..b1e2f07 100644
> --- a/arch/microblaze/include/asm/system.h
> +++ b/arch/microblaze/include/asm/system.h
> @@ -97,14 +97,4 @@ extern struct dentry *of_debugfs_root;
> =20
>  #define arch_align_stack(x) (x)
> =20
> -/*
> - * MicroBlaze doesn't handle unaligned accesses in hardware.
> - *
> - * Based on this we force the IP header alignment in network drivers=
=2E
> - * We also modify NET_SKB_PAD to be a cacheline in size, thus mainta=
ining
> - * cacheline alignment of buffers.
> - */
> -#define NET_IP_ALIGN	2
> -#define NET_SKB_PAD	L1_CACHE_BYTES
> -
>  #endif /* _ASM_MICROBLAZE_SYSTEM_H */

Yes, this seems strange it actually worked if L1_CACHE_BYTES =3D 4

Thanks


