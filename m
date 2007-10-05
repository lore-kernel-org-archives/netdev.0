From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 18:49:49 +0200
Message-ID: <200710051849.50091.netdev@axxeo.de>
References: <20071005.031209.57156822.davem@davemloft.net> <200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:4258 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756520AbXJEQuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 12:50:00 -0400
In-Reply-To: <200710051846.19965.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser schrieb:
> > +static void niu_init_xif(struct niu *);
> > +
> > +static int link_status_10g(struct niu *np, int *link_up_p)
> > +{
> > +	unsigned long flags;
> > +	int err, link_up;
> > +
> > +	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
> > +		return -EINVAL;
> > +
> > +	link_up = 0;
> > +
> > +	spin_lock_irqsave(&np->lock, flags);
> > +
> > +	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
> > +			BCM8704_PMD_RCV_SIGDET);
> > +	if (err < 0)
> > +		return err;
> 
> missing spin_unlock_irqsave()?

I mean spin_unlock_irqrestore()

> > +	if (!(err & PMD_RCV_SIGDET_GLOBAL))
> > +		goto out;
> > +
> > +	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
> > +			BCM8704_PCS_10G_R_STATUS);
> > +	if (err < 0)
> > +		return err;
> missing spin_unlock_irqsave()?

I mean spin_unlock_irqrestore()
 
> > +	if (!(err & PCS_10G_R_STATUS_BLK_LOCK))
> > +		goto out;
> > +
> > +	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
> > +			BCM8704_PHYXS_XGXS_LANE_STAT);
> > +	if (err < 0)
> > +		return err;
> > +
> > +	if (err != (PHYXS_XGXS_LANE_STAT_ALINGED |
> > +		    PHYXS_XGXS_LANE_STAT_MAGIC |
> > +		    PHYXS_XGXS_LANE_STAT_LANE3 |
> > +		    PHYXS_XGXS_LANE_STAT_LANE2 |
> > +		    PHYXS_XGXS_LANE_STAT_LANE1 |
> > +		    PHYXS_XGXS_LANE_STAT_LANE0))
> > +		goto out;
> > +
> > +	link_up = 1;
> > +	np->link_config.active_speed = SPEED_10000;
> > +	np->link_config.active_duplex = DUPLEX_FULL;
> > +
> > +out:
> > +	spin_unlock_irqrestore(&np->lock, flags);
> > +
> > +	*link_up_p = link_up;
> > +	return 0;
> > +}
> 

Ok, enough for today...

Best Regards

Ingo Oeser
