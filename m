From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Wed, 29 Jun 2011 13:37:09 +0200
Message-ID: <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com> <1308942371-12748-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:60795 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199Ab1F2Lha convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 07:37:30 -0400
Received: by qyk29 with SMTP id 29so2461707qyk.19
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 04:37:29 -0700 (PDT)
In-Reply-To: <1308942371-12748-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/24  <greearb@candelatech.com>:
> From: Ben Greear <greearb@candelatech.com>
>
> This allows e100 to be configured to append the
> Ethernet FCS to the skb.
>
> Useful for sniffing networks.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 c1352c6... 761f6f5... M =A0drivers/net/e100.c
> =A0drivers/net/e100.c | =A0 15 ++++++++++++---
> =A01 files changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index c1352c6..761f6f5 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -1089,6 +1089,7 @@ static void e100_configure(struct nic *nic, str=
uct cb *cb, struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct config *config =3D &cb->u.config;
> =A0 =A0 =A0 =A0u8 *c =3D (u8 *)config;
> + =A0 =A0 =A0 struct net_device *netdev =3D nic->netdev;
>
> =A0 =A0 =A0 =A0cb->command =3D cpu_to_le16(cb_config);
>
> @@ -1132,6 +1133,9 @@ static void e100_configure(struct nic *nic, str=
uct cb *cb, struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->promiscuous_mode =3D 0x1; =A0 =
=A0 =A0 =A0 /* 1=3Don, 0=3Doff */
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (netdev->wanted_features & NETIF_F_RXFCS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 config->rx_crc_transfer =3D 0x1; =A0/* =
1=3Dsave, 0=3Ddiscard */
> +

You should check netdev->features here.

> =A0 =A0 =A0 =A0if (nic->flags & multicast_all)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0config->multicast_all =3D 0x1; =A0 =A0=
 =A0 =A0 =A0 =A0/* 1=3Daccept, 0=3Dno */
>
> @@ -1919,6 +1923,7 @@ static int e100_rx_indicate(struct nic *nic, st=
ruct rx *rx,
> =A0 =A0 =A0 =A0struct sk_buff *skb =3D rx->skb;
> =A0 =A0 =A0 =A0struct rfd *rfd =3D (struct rfd *)skb->data;
> =A0 =A0 =A0 =A0u16 rfd_status, actual_size;
> + =A0 =A0 =A0 u16 fcs_pad =3D 0;
>
> =A0 =A0 =A0 =A0if (unlikely(work_done && *work_done >=3D work_to_do))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EAGAIN;
> @@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, s=
truct rx *rx,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Get actual data size */
> + =A0 =A0 =A0 if (dev->wanted_features & NETIF_F_RXFCS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fcs_pad =3D 4;

Same here.

Best Regards,
Micha=B3 Miros=B3aw
