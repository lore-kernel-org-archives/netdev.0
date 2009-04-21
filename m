From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Tue, 21 Apr 2009 12:30:24 +0200
Message-ID: <49EDA040.5040600@cosmosbay.com>
References: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw> <20090421.015235.23457775.davem@davemloft.net> <20090421094825.GA6752@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jon.lin@vatics.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amos Kong <jianjun@zeuux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49933 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077AbZDUKbf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:31:35 -0400
In-Reply-To: <20090421094825.GA6752@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amos Kong a =E9crit :
> ...
>>> Unfortunately, this address is used by Linux kernel. So kernel pani=
cs.
>>> This patch fix it by setting up DMA buffer address before RX enable=
d and everything is fine even under broadcast packets attack.
>>>
>>> Signed-off-by: Jonathan Lin <jon.lin@vatics.com>
>> This patch does not apply, it was corrupted by your email client.
>>
>> I even think it has MS-DOS style newlines in it :-(
>=20
> Another new patch :)
>=20
>=20
>  While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c)=
=2E
>  In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX befor=
e setting up the DMA
>  buffer address. In this interval where RX was enabled and DMA buffer=
 address is not yet set
>  up, any incoming broadcast packet would be send to a strange physica=
l address:
>  0x003e8800 which is the default value of DMA buffer address.
>  Unfortunately, this address is used by Linux kernel. So kernel panic=
s.
>  This patch fix it by setting up DMA buffer address before RX enabled=
 and everything is fine
>  even under broadcast packets attack.
>=20
> Signed-off-by: Jonathan Lin <jon.lin@vatics.com>
> Signed-off-by: Amos Kong <jianjun@zeuux.org>

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Thanks Amos and Jonathan

>=20
> ---
>  drivers/net/8139too.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index 29df398..1fc4543 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -1383,6 +1383,11 @@ static void rtl8139_hw_start (struct net_devic=
e *dev)
>  	RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)))=
;
>  	RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)))=
;
> =20
> +	tp->cur_rx =3D 0;
> +
> +	/* init Rx ring buffer DMA address */
> +	RTL_W32_F (RxBuf, tp->rx_ring_dma);
> +
>  	/* Must enable Tx/Rx before setting transfer thresholds! */
>  	RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
> =20
> @@ -1390,8 +1395,6 @@ static void rtl8139_hw_start (struct net_device=
 *dev)
>  	RTL_W32 (RxConfig, tp->rx_config);
>  	RTL_W32 (TxConfig, rtl8139_tx_config);
> =20
> -	tp->cur_rx =3D 0;
> -
>  	rtl_check_media (dev, 1);
> =20
>  	if (tp->chipset >=3D CH_8139B) {
> @@ -1406,9 +1409,6 @@ static void rtl8139_hw_start (struct net_device=
 *dev)
>  	/* Lock Config[01234] and BMCR register writes */
>  	RTL_W8 (Cfg9346, Cfg9346_Lock);
> =20
> -	/* init Rx ring buffer DMA address */
> -	RTL_W32_F (RxBuf, tp->rx_ring_dma);
> -
>  	/* init Tx buffer DMA addresses */
>  	for (i =3D 0; i < NUM_TX_DESC; i++)
>  		RTL_W32_F (TxAddr0 + (i * 4), tp->tx_bufs_dma + (tp->tx_buf[i] - t=
p->tx_bufs));


