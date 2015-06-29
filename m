From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCHv4] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Mon, 29 Jun 2015 05:44:02 +0200
Message-ID: <20150629034402.GA30187@lunn.ch>
References: <1435512972-24014-1-git-send-email-andrew@lunn.ch>
 <BLUPR03MB373F2684A8C9BF38719B930F5AA0@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Cory Tusar <cory.tusar@pid1solutions.com>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59011 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbbF2DuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 23:50:09 -0400
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373F2684A8C9BF38719B930F5AA0@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > @@ -3496,10 +3523,11 @@ static int __maybe_unused fec_suspend(struct
> > device *dev)
> >  		netif_device_detach(ndev);
> >  		netif_tx_unlock_bh(ndev);
> >  		fec_stop(ndev);
> > -		fec_enet_clk_enable(ndev, false);
> >  		if (!(fep->wol_flag & FEC_WOL_FLAG_ENABLE))
> >  			pinctrl_pm_select_sleep_state(&fep->pdev->dev);
> >  	}
> > +
> > +	fec_enet_clk_enable(ndev, false);
> 
> Why do you move out the api from netif runnig condition ?

Ah, read the documentation again. I see my error. I thought it would
call fec_suspend() and fec_resume(). But now i see there are separate
runtime suspend and resume functions.

I will fix this.

  Andrew
