From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] stmmac: replace all pr_xxx by their dev_xxx
 counterpart
Date: Wed, 09 Sep 2015 09:14:42 -0700
Message-ID: <1441815282.17219.51.camel@perches.com>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0028.hostedemail.com ([216.40.44.28]:40791 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751390AbbIIQOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 12:14:45 -0400
In-Reply-To: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-09 at 15:14 +0200, LABBE Corentin wrote:
> The stmmac driver use lots of pr_xxx functions to print information.
> This is bad since we cannot know which device logs the information.
> (moreover if two stmmac device are present)
[]
> So this patch replace all pr_xxx by their dev_xxx counterpart.

Using
	netdev_<level>(priv->dev, ...
instead of
	dev_<level>(priv->device,

would be more consistent with other ethernet devices.

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[]
> @@ -298,7 +298,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>  			 */
>  			spin_lock_irqsave(&priv->lock, flags);
>  			if (priv->eee_active) {
> -				pr_debug("stmmac: disable EEE\n");
> +				dev_dbg(priv->device, "disable EEE\n");

				netdev_dbg(priv->dev, ...)

> @@ -657,10 +657,10 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
>  		priv->adv_ts = 1;
>  
>  	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
> -		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
> +		dev_dbg(priv->device, "IEEE 1588-2002 Time Stamp supported\n");

And these netif_msg_<foo> could be

	if (priv->dma_cap.timestamp)
		netif_dbg(priv, hw, priv->dev, ...);
