From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169:Set RxConfig on same func. with TxConfig
Date: Tue, 18 Aug 2015 13:04:17 -0700
Message-ID: <1439928257.6610.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35388 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbHRUET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 16:04:19 -0400
Received: by pdob1 with SMTP id b1so16182650pdo.2
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 13:04:18 -0700 (PDT)
In-Reply-To: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-18 at 22:10 +0300, Corcodel Marian wrote:
>  Add set DMA burst size and  Rx FIFO threshold on RxConfig =20
>   register to function rtl_set_rx_tx_config_register.
>=20
>=20
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 6d16de3..c3c908c 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5183,6 +5183,7 @@ static void rtl_set_rx_tx_config_registers(stru=
ct rtl8169_private *tp)
>  	/* Set DMA burst size and Interframe Gap Time */
>  	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
>                  (InterFrameGap << TxInterFrameGapShift) | InterFrame=
Gap2);
> +	RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
>  }
> =20
>  static void rtl_hw_start(struct net_device *dev)

This does not even compile. This is insane.



  CC [M]  drivers/net/ethernet/realtek/r8169.o
drivers/net/ethernet/realtek/r8169.c: In function
=E2=80=98rtl_set_rx_tx_config_registers=E2=80=99:
drivers/net/ethernet/realtek/r8169.c:5186:20: error: =E2=80=98RX_FIFO_T=
HRESHOLD=E2=80=99
undeclared (first use in this function)
  RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
                    ^
drivers/net/ethernet/realtek/r8169.c:104:38: note: in definition of
macro =E2=80=98RTL_W32=E2=80=99
 #define RTL_W32(reg, val32) writel ((val32), ioaddr + (reg))
                                      ^
drivers/net/ethernet/realtek/r8169.c:5186:20: note: each undeclared
identifier is reported only once for each function it appears in
  RTL_W32(RxConfig, RX_FIFO_THRESHOLD | RX_DMA_BURST);
                    ^
drivers/net/ethernet/realtek/r8169.c:104:38: note: in definition of
macro =E2=80=98RTL_W32=E2=80=99
 #define RTL_W32(reg, val32) writel ((val32), ioaddr + (reg))
                                      ^
make[1]: *** [drivers/net/ethernet/realtek/r8169.o] Error 1
make: *** [drivers/net/ethernet/realtek/r8169.o] Error 2
