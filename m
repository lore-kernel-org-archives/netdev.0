From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 08/40] net: fec: move cbd_bufaddr assignment closer to the mapping function
Date: Thu, 28 Jan 2016 23:02:19 +0100
Message-ID: <1725152.bhtFKTSjnb@wuerfel>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com> <1454016364-30985-9-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	linux@arm.linux.org.uk, laci@boundarydevices.com,
	l.stach@pengutronix.de, shawnguo@kernel.org, tremyfr@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:61728 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcA1WDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 17:03:14 -0500
In-Reply-To: <1454016364-30985-9-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 January 2016 14:25:32 Troy Kisky wrote:
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

[note: missing changelog?]

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index b87f80d..15a93f90 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -476,6 +476,8 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
>  				estatus |= BD_ENET_TX_TS;
>  		}
>  	}
> +	bdp->cbd_bufaddr = addr;
> +	bdp->cbd_datlen = buflen;
>  
>  	if (fep->bufdesc_ex) {
>  
> @@ -499,8 +501,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
>  	/* Save skb pointer */
>  	txq->tx_skbuff[index] = skb;
>  
> -	bdp->cbd_datlen = buflen;
> -	bdp->cbd_bufaddr = addr;
>  	/* Make sure the updates to rest of the descriptor are performed before
>  	 * transferring ownership.
>  	 */
> 

This patch and others in the series conflicts with the bugfix "net: fec: make
driver endian-safe" that Johannes sent this week. Can you include his fix
in your series and ensure that all descriptor accesses are done in
an endian-safe way?

	Arnd
