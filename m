From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH net v2 1/1] net: fec: Fix Transmitted bytes counter
Date: Fri, 28 Jun 2013 10:10:49 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE01509E83@039-SN2MPN1-023.039d.mgd.msft.net>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1372413082-7983-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:51529
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754879Ab3F1KK5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 06:10:57 -0400
In-Reply-To: <1372413082-7983-1-git-send-email-jim_baxter@mentor.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/13 17:51, Jim Baxter wrote:
> The tx_bytes field was not being updated so the network card statistics showed 0.0B transmitted.
>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
> Change from v1 to v2
> Moved the tx_bytes incrementing to include all packets passed to the network card.
>
>  drivers/net/ethernet/freescale/fec_main.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index d48099f..51493ce 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -332,6 +332,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  
>  	/* Save skb pointer */
>  	fep->tx_skbuff[index] = skb;
> +	ndev->stats.tx_bytes += skb->len;
>  
>  	/* Push the data cache so the CPM does not get stale memory
>  	 * data.
> --
> 1.7.10.4

Acked-By: Fugang Duan  <B38611@freescale.com>
