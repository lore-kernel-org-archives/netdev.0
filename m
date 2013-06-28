From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH net v1 1/1] net: fec: Fix Transmitted bytes counter
Date: Fri, 28 Jun 2013 02:11:30 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE01508FB2@039-SN2MPN1-023.039d.mgd.msft.net>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1372357508-23038-1-git-send-email-jim_baxter@mentor.com>
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
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:7756
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753652Ab3F1CLf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 22:11:35 -0400
In-Reply-To: <1372357508-23038-1-git-send-email-jim_baxter@mentor.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/13 02:25, Jim Baxter wrote:

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Jim Baxter
> Sent: Friday, June 28, 2013 2:25 AM
> To: David S. Miller
> Cc: Estevam Fabio-R49496; Li Frank-B20596; Shawn Guo; netdev@vger.kernel.org
> Subject: [PATCH net v1 1/1] net: fec: Fix Transmitted bytes counter
>
> The tx_bytes field was not being updated so the network card statistics showed 0.0B transmitted.
>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index ed6180e..05a5f76 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -738,6 +738,7 @@ fec_enet_tx(struct net_device *ndev)
>  				ndev->stats.tx_carrier_errors++;
>  		} else {
>  			ndev->stats.tx_packets++;
> +			ndev->stats.tx_bytes += bdp->cbd_datlen;
>  		}
>  
>  		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
> --
You cannot stat. tx_bytes in here, since stat.tx_bytes indicate that all bytes sent by MAC regardless whether there have error packets or not.
You must add the stat. at xmit function as below:
...
fep->tx_skbuff[index] = skb;
+ ndev->stats.tx_bytes += skb->len;
...

Thanks,
Andy
