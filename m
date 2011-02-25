From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH] davinci: da850/omap-l138: Add Carrier Link OK check in
 Davinci RX Handler
Date: Fri, 25 Feb 2011 08:16:18 -0500
Message-ID: <4D67ABA2.6060808@ti.com>
References: <1298627788-32339-1-git-send-email-vinay.hegde@ti.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Hegde, Vinay" <vinay.hegde@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:36088 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755669Ab1BYNQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 08:16:24 -0500
In-Reply-To: <1298627788-32339-1-git-send-email-vinay.hegde@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2011 04:56 AM, Hegde, Vinay wrote:
> This patch adds an additional check in the Davinci EMAC RX Handler,
> which tests the __LINK_STATE_NOCARRIER flag along with the
> __LINK_STATE_START flag as part EMAC shutting down procedure.
> 
> This avoids
> WARNING: at drivers/net/davinci_emac.c:1040 emac_rx_handler+0xf8/0x120()
> during rtcwake used to suspend the target for a specified duration.
> 
> Signed-off-by: Hegde, Vinay <vinay.hegde@ti.com>
> ---
>  drivers/net/davinci_emac.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 2a628d1..7018bfe 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1008,7 +1008,7 @@ static void emac_rx_handler(void *token, int len, int status)
>  	int			ret;
>  
>  	/* free and bail if we are shutting down */
> -	if (unlikely(!netif_running(ndev))) {
> +	if (unlikely(!netif_running(ndev) || !netif_carrier_ok(ndev))) {
>  		dev_kfree_skb_any(skb);
>  		return;
>  	}

Looks ok.

Acked-by: Cyril Chemparathy <cyril@ti.com>
