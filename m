From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 1/4] stmmac: replace all pr_xxx by their dev_xxx
 counterpart
Date: Thu, 10 Sep 2015 13:42:51 +0200
Message-ID: <20150910114251.GA11036@Red>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
 <1441815282.17219.51.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37075 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbbIJLm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 07:42:57 -0400
Content-Disposition: inline
In-Reply-To: <1441815282.17219.51.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 09, 2015 at 09:14:42AM -0700, Joe Perches wrote:
> On Wed, 2015-09-09 at 15:14 +0200, LABBE Corentin wrote:
> > The stmmac driver use lots of pr_xxx functions to print information.
> > This is bad since we cannot know which device logs the information.
> > (moreover if two stmmac device are present)
> []
> > So this patch replace all pr_xxx by their dev_xxx counterpart.
> 
> Using
> 	netdev_<level>(priv->dev, ...
> instead of
> 	dev_<level>(priv->device,
> 
> would be more consistent with other ethernet devices.
> 

Ok

> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> []
> > @@ -298,7 +298,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
> >  			 */
> >  			spin_lock_irqsave(&priv->lock, flags);
> >  			if (priv->eee_active) {
> > -				pr_debug("stmmac: disable EEE\n");
> > +				dev_dbg(priv->device, "disable EEE\n");
> 
> 				netdev_dbg(priv->dev, ...)
> 
> > @@ -657,10 +657,10 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
> >  		priv->adv_ts = 1;
> >  
> >  	if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
> > -		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
> > +		dev_dbg(priv->device, "IEEE 1588-2002 Time Stamp supported\n");
> 
> And these netif_msg_<foo> could be
> 
> 	if (priv->dma_cap.timestamp)
> 		netif_dbg(priv, hw, priv->dev, ...);
> 
> 
Thanks for the tip, I will add a patch for replacing that.

Regards
