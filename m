From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1] ethtool : added
 get_phy_stats,get_strings,get_sset_count
Date: Mon, 27 Mar 2017 19:26:57 +0200
Message-ID: <20170327172657.GB17041@lunn.ch>
References: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
 <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Scariah <thomasscariah@gmail.com>, nsekhar@ti.com,
        grygorii.strashko@ti.com, davem@davemloft.net,
        drivshin@allworx.com, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org, thomas.scariah@harman.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35689 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751385AbdC0R1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 13:27:12 -0400
Content-Disposition: inline
In-Reply-To: <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  static int cpsw_get_sset_count(struct net_device *ndev, int sset)
> >  {
> > +	struct cpsw_priv *priv = netdev_priv(ndev);
> > +	int slave_no = cpsw_slave_index(priv);
> > +	int count;
> > +
> >  	switch (sset) {
> >  	case ETH_SS_STATS:
> > -		return CPSW_STATS_LEN;
> > +		count = CPSW_STATS_LEN;
> > +		count += phy_ethtool_get_sset_count(priv->slaves[slave_no].phy,
> > +						    sset);
> > +		return count;
> >  	default:
> >  		return -EOPNOTSUPP;
> >  	}
> 
> We already have a way to obtain PHY specific statistics through the
> ETH_SS_PHY_STATS string set, cannot we use that here too? It certainly
> makes it easier to overlay cpsw statistics with PHY device statistics,
> but when Andrew added support for that, AFAIR this was made
> intentionally separate.

I don't particularly like this. It makes the cpsw driver different to
all other drivers, in that it returns both MAC and PHY statistics.

If you are going to do this, please do it a higher level so that it
applies to all Ethernet drivers, not just cpsw.

But personally, i don't see the point of this change. What is wrong
with ethtool --phy-statistics?

     Andrew
