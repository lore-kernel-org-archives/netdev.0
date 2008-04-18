From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] DM9000: improved/fixed dev_dbg() messages
Date: Fri, 18 Apr 2008 12:19:13 +0100
Message-ID: <20080418111913.GH15407@fluff.org.uk>
References: <1208512936-5897-3-git-send-email-enrico.scholz@sigma-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:63615 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751304AbYDRLTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 07:19:17 -0400
Content-Disposition: inline
In-Reply-To: <1208512936-5897-3-git-send-email-enrico.scholz@sigma-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 12:02:16PM +0200, Enrico Scholz wrote:
> There was a missing newline in a dev_dbg() message.  Values read
> from/written into PHY registers might be for interest too, so I added
> new dbg messages there.

The phy reads are going to be a problem as a previous patch i've
submitted adds a phy polling timer to keep track of the phy state
and keep the network layer aprised of the link status. This is going
to end up spamming the log.

I'd have prefered to see a seperate fix and then addition of features
as this often makes it easier to see what is going on (although this
is a fairly simple patch).
 
> Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
> ---
>  drivers/net/dm9000.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 7bc16d2..e4af7a9 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -525,7 +525,7 @@ dm9000_probe(struct platform_device *pdev)
>  
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
>  
> -	dev_dbg(&pdev->dev, "dm9000_probe()");
> +	dev_dbg(&pdev->dev, "dm9000_probe()\n");
>  
>  	/* setup board info structure */
>  	db = (struct board_info *) ndev->priv;
> @@ -1292,6 +1292,8 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
>  	spin_unlock_irqrestore(&db->lock,flags);
>  
>  	mutex_unlock(&db->addr_lock);
> +
> +	dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
>  	return ret;
>  }
>  
> @@ -1305,6 +1307,7 @@ dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
>  	unsigned long flags;
>  	unsigned long reg_save;
>  
> +	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
>  	mutex_lock(&db->addr_lock);
>  
>  	spin_lock_irqsave(&db->lock,flags);
> -- 
> 1.5.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
