From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net-next V2 13/16] net: fec: print more debug info in
 fec_timeout
Date: Fri, 4 Mar 2016 10:06:18 +0000
Message-ID: <VI1PR0401MB18552AB3E4128E412273B439FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-14-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
 "andrew@lunn.ch" <andrew@lunn.ch>,
 "stillcompiling@gmail.com" <stillcompiling@gmail.com>,
 "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "sergei.shtylyov@cogentembedded.com" <sergei.shtylyov@cogentembedded.com>,
 "laci@boundarydevices.com" <laci@boundarydevices.com>,
 "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
 "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
 "shawnguo@kernel.org" <shawnguo@kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "tremyfr@gmail.com" <tremyfr@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "b38611@freescale.com" <b38611@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456360619-24390-14-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
> johannes@sipsolutions.net; stillcompiling@gmail.com;
> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
> <troy.kisky@boundarydevices.com>
> Subject: [PATCH net-next V2 13/16] net: fec: print more debug info in
> fec_timeout
> 
> Print the current interrupt flags and mask and the interrupt state during the last
> interrupt in fec_timeout.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      | 1 +
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++++
>  2 files changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h
> b/drivers/net/ethernet/freescale/fec.h
> index 001200b..615cca1 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -506,6 +506,7 @@ struct fec_enet_private {
>  	unsigned int total_tx_ring_size;
>  	unsigned int total_rx_ring_size;
>  	uint	events;
> +	uint	last_ievents;
> 
>  	struct	platform_device *pdev;
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index afd4060..9a3136b 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1107,6 +1107,9 @@ fec_timeout(struct net_device *ndev)
>  	int i;
>  	uint events = 0;
> 
> +	pr_err("%s: last=%x %x, mask %x\n", __func__, fep->last_ievents,
> +	       readl(fep->hwp + FEC_IEVENT), readl(fep->hwp + FEC_IMASK));
> +
pr_err() -> netdev_err()

I don't want the debug patch enter to the driver.

>  	for (i = 0; i < fep->num_tx_queues; i++) {
>  		struct fec_enet_priv_tx_q *txq = fep->tx_queue[i];
>  		int index;
> @@ -1514,6 +1517,7 @@ fec_enet_interrupt(int irq, void *dev_id)
> 
>  	if (!int_events)
>  		return IRQ_NONE;
> +	fep->last_ievents = int_events;
> 
>  	if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
>  		if (napi_schedule_prep(&fep->napi)) {
> --
> 2.5.0
