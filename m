From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 01/20] net-core: extending (hw_/wanted_/vlan_)features
 fields to a bitmap.
Date: Wed, 6 Apr 2011 12:29:18 +0200
Message-ID: <BANLkTik3Uz_zu5qev1bc=mop4fUTYGZaDQ@mail.gmail.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com> <1302050665-10460-2-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52143 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab1DFK3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 06:29:39 -0400
Received: by pwi15 with SMTP id 15so507243pwi.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 03:29:38 -0700 (PDT)
In-Reply-To: <1302050665-10460-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/6 Mahesh Bandewar <maheshb@google.com>:
> Converting current use of (hw_/wanted_/vlan_)features to
> legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed =
usage.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> =C2=A0include/linux/netdevice.h | =C2=A0110 +++++++++++++++++++++++++=
++++++-------------
> =C2=A0net/core/dev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 51 +++++++++++----------
> =C2=A0net/core/ethtool.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 97 +++++=
+++++++++++++++-------------------
> =C2=A0net/core/net-sysfs.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 +-
> =C2=A0net/core/sock.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +-
> =C2=A05 files changed, 155 insertions(+), 109 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 09d2624..637bf2a 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -980,6 +980,42 @@ struct net_device_ops {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 features);
> =C2=A0};
>
> +enum netdev_features {
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_SG_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 /* Scatter/gather IO. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_IP_CSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Can checksum TCP/UDP over IPv4. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_NO_CSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Does not require checksum. F.e. loopack. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_CSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Can checksum all the packets. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_IPV6_CSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* Can checksum TCP/UDP over IPV6 */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_HIGHDMA_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Can DMA to high memory. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_FRAGLIST_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* Scatter/gather IO. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_VLAN_TX_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Transmit VLAN hw acceleration */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_VLAN_RX_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Receive VLAN hw acceleration */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_VLAN_FILTER_BIT, =C2=A0 =C2=A0 /* R=
eceive filtering on VLAN */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_VLAN_CHALLENGED_BIT, =C2=A0 =C2=A0/* D=
evice cannot handle VLAN packets */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_GSO_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Enable software GSO. */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_LLTX_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 /* LockLess TX - deprecated. Please */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* do n=
ot use LLTX in new drivers */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_NETNS_LOCAL_BIT, =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* Does not change network namespaces */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_GRO_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* Generic receive offload */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_LRO_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/* large receive offload */
> + =C2=A0 =C2=A0 =C2=A0 /* the GSO_MASK reserves bits 16 through 23 */
> + =C2=A0 =C2=A0 =C2=A0 RESERVED1_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED2_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED3_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED4_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED5_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED6_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED7_BIT,
> + =C2=A0 =C2=A0 =C2=A0 RESERVED8_BIT,
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_FCOE_CRC_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* FCoE CRC32 */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_SCTP_CSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* SCTP checksum offload */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_FCOE_MTU_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /* Supports max FCoE MTU, 2158 bytes*/
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_NTUPLE_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* N-tuple filters supported */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_RXHASH_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* Receive hashing offload */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_RXCSUM_BIT, =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* Receive checksumming offload */
> + =C2=A0 =C2=A0 =C2=A0 NETIF_F_NOCACHE_COPY_BIT, =C2=A0 =C2=A0 =C2=A0=
 /* Use no-cache copyfromuser */
> +};
> +

This should be a separate cleanup patch. And after that, for the
conversion you would add as a last entry:
NETIF_F_NUM_BITS and use it later (see below).

> =C2=A0/*
> =C2=A0* =C2=A0 =C2=A0 The DEVICE structure.
> =C2=A0* =C2=A0 =C2=A0 Actually, this whole structure is a big mistake=
=2E =C2=A0It mixes I/O
> @@ -1029,44 +1065,51 @@ struct net_device {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0=
napi_list;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0=
unreg_list;
>
> +#define DEV_FEATURE_WORDS =C2=A0 =C2=A0 =C2=A02
> +#define =C2=A0 =C2=A0 =C2=A0 =C2=A0DEV_FEATURE_BITS =C2=A0 =C2=A0 =C2=
=A0 =C2=A0(DEV_FEATURE_WORDS*sizeof(long)*BITS_PER_BYTE)
> +#define LEGACY_FEATURE_WORD =C2=A0 =C2=A00
> +

#define DEV_FEATURE_WORDS BITS_TO_LONGS(NETIF_F_NUM_BITS)
#define DEV_FEATURE_BITS (DEV_FEATURE_WORDS*BITS_PER_LONG)

Though using bitmaps will make a mess for 32 versus 64 bit archs. It
would be better to stick to u32 as the base type instead of long.

[...]
> @@ -2376,13 +2419,13 @@ static inline void netif_tx_unlock_bh(struct =
net_device *dev)
> =C2=A0}
>
> =C2=A0#define HARD_TX_LOCK(dev, txq, cpu) { =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
> - =C2=A0 =C2=A0 =C2=A0 if ((dev->features & NETIF_F_LLTX) =3D=3D 0) {=
 =C2=A0 =C2=A0 =C2=A0\
> + =C2=A0 =C2=A0 =C2=A0 if ((dev->legacy_features & NETIF_F_LLTX) =3D=3D=
 0) { =C2=A0 =C2=A0 =C2=A0 \
[...]

=46or those type of conversion there is really no point in using the
macro. Changing it to
dev->features[0] instead of dev->legacy_features needs the same effort
but avoids the
cleanup later. Flags in other feature words could have names line
NETIF_F2_xxx so that
it would be clear in which word they belong.

Best Regards,
Micha=C5=82 Miros=C5=82aw
