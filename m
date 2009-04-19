From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Sun, 19 Apr 2009 13:22:10 +0200
Message-ID: <49EB0962.2060309@cosmosbay.com>
References: <528f811a0904190316v22621684o3047e37bf8e78bda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Tzungder Lin <tzungder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47681 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbZDSLWS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 07:22:18 -0400
In-Reply-To: <528f811a0904190316v22621684o3047e37bf8e78bda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tzungder Lin a =E9crit :
> From: Jonathan Lin <jon.lin@vatics.com, tzungder@gmail.com>
>=20
> While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
> In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before
> setting up the DMA buffer address. In this interval where RX was
> enabled and DMA buffer address is not yet set up, any incoming
> broadcast packet would be send to a strange physical address:
> 0x003e8800 which is the default value of DMA buffer address.
> Unfortunately, this address is used by Linux kernel. So kernel panics=
=2E
> This patch fix it by setting up DMA buffer address before RX enabled
> and everything is fine even under broadcast packets attack.
>=20
> Signed-off-by: Jonathan Lin <jon.lin@vatics.com, tzungder@gmail.com>
>=20
> ---
>=20
> --- linux-2.6.29.1/drivers/net/8139too.c.orig	2009-04-19
> 17:50:38.000000000 +0800
> +++ linux-2.6.29.1/drivers/net/8139too.c	2009-04-19 17:52:51.00000000=
0 +0800
> @@ -1382,6 +1382,10 @@ static void rtl8139_hw_start (struct net
>  	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)))=
;
>  	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)))=
;
>=20
> +	tp->cur_rx =3D 0;
> +	/* init Rx ring buffer DMA address BEFORE Rx enabled*/
> +	RTL_W32_F (RxBuf, tp->rx_ring_dma);
> +=09
>  	/* Must enable Tx/Rx before setting transfer thresholds! */
>  	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
>=20
> @@ -1389,8 +1393,6 @@ static void rtl8139_hw_start (struct net
>  	RTL_W32 (RxConfig, tp->rx_config);
>  	RTL_W32 (TxConfig, rtl8139_tx_config);
>=20
> -	tp->cur_rx =3D 0;
> -
>  	rtl_check_media (dev, 1);
>=20
>  	if (tp->chipset >=3D CH_8139B) {
> @@ -1405,9 +1407,6 @@ static void rtl8139_hw_start (struct net
>  	/* Lock Config[01234] and BMCR register writes */
>  	RTL_W8 (Cfg9346, Cfg9346_Lock);
>=20
> -	/* init Rx ring buffer DMA address */
> -	RTL_W32_F (RxBuf, tp->rx_ring_dma);
> -
>  	/* init Tx buffer DMA addresses */
>  	for (i =3D 0; i < NUM_TX_DESC; i++)
>  		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] -
> tp->tx_bufs));
> --

Hi Jonathan

There are at least two small problems on this patch submission.

1) Please chose one of email address for Signoff line, not two :)

=46or example : Signed-off-by: Jonathan Lin <tzungder@gmail.com>

You'll be soon flooded by spams, so dont ease spamers life :)

2) Try to find out why your email got two lines wrapped
    You can read Documentation/email-clients.txt if you want extensive =
documentation.
    You can also test this by sending your 'patch' to yourself and chec=
k if
    no lines were wrapped before sending the 'official patch'

I dont want to bother you Jonathan, as it is pretty hard for a newcomer=
 to learn
this things, but I feel that you might find other bugs in linux kernel,=
 so this
learning is likely a good investment, both for you and others.

Thanks

