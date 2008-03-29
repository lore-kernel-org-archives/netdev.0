From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ibm_newemac: emac_tx_csum typo fix
Date: Fri, 28 Mar 2008 21:54:06 -0400
Message-ID: <47EDA13E.3080504@garzik.org>
References: <20080327144357.GA9111@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080327144357.GA9111@ru.mvista.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Valentine Barshak wrote:
> Move the "&& skb->ip_summed == CHECKSUM_PARTIAL" part out of
> emac_has_feature parameters.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> ---
>  drivers/net/ibm_newemac/core.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.c linux-2.6/drivers/net/ibm_newemac/core.c
> --- linux-2.6.orig/drivers/net/ibm_newemac/core.c	2008-02-21 16:45:36.000000000 +0300
> +++ linux-2.6/drivers/net/ibm_newemac/core.c	2008-02-22 19:55:29.000000000 +0300
> @@ -1235,8 +1235,8 @@ static int emac_close(struct net_device 
>  static inline u16 emac_tx_csum(struct emac_instance *dev,
>  			       struct sk_buff *skb)
>  {
> -	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH &&
> -			     skb->ip_summed == CHECKSUM_PARTIAL)) {
> +	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH) &&
> +		(skb->ip_summed == CHECKSUM_PARTIAL)) {
>  		++dev->stats.tx_packets_csum;
>  		return EMAC_TX_CTRL_TAH_CSUM;

applied
