From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [2.6 patch] drivers/net/cxgb3/xgmac.c: remove dead code
Date: Tue, 31 Jul 2007 16:43:59 -0700
Message-ID: <46AFC93F.6010104@chelsio.com>
References: <20070729145544.GA16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31140 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbXGaXpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 19:45:10 -0400
In-Reply-To: <20070729145544.GA16817@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
>
> This patch removes dead code ("tx_xcnt" can never be != 0 at this place)
> spotted by the Coverity checker.
>
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>
Acked-by: Divy Le Ray <divy@chelsio.com>
>
>
> ---
>
>  drivers/net/cxgb3/xgmac.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> --- linux-2.6.22-rc6-mm1/drivers/net/cxgb3/xgmac.c.old  2007-07-24 
> 13:55:33.000000000 +0200
> +++ linux-2.6.22-rc6-mm1/drivers/net/cxgb3/xgmac.c      2007-07-24 
> 13:57:06.000000000 +0200
> @@ -510,38 +510,35 @@ int t3b2_mac_watchdog_task(struct cmac *
>         if (tx_mcnt == mac->tx_mcnt) {
>                 tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
>                                                 
> A_XGM_TX_SPI4_SOP_EOP_CNT +
>                                                 mac->offset)));
>                 if (tx_xcnt == 0) {
>                         t3_write_reg(adap, A_TP_PIO_ADDR,
>                                      A_TP_TX_DROP_CNT_CH0 + macidx(mac));
>                         tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
>                                                       A_TP_PIO_DATA)));
>                 } else {
>                         goto rxcheck;
>                 }
>         } else {
>                 mac->toggle_cnt = 0;
>                 goto rxcheck;
>         }
>
> -       if (((tx_tcnt != mac->tx_tcnt) &&
> -            (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
> -           ((mac->tx_mcnt == tx_mcnt) &&
> -            (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
> +       if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
>                 if (mac->toggle_cnt > 4) {
>                         status = 2;
>                         goto out;
>                 } else {
>                         status = 1;
>                         goto out;
>                 }
>         } else {
>                 mac->toggle_cnt = 0;
>                 goto rxcheck;
>         }
>
>  rxcheck:
>         if (rx_mcnt != mac->rx_mcnt)
>                 rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
>                                                 
> A_XGM_RX_SPI4_SOP_EOP_CNT +
>                                                 mac->offset)));
>

