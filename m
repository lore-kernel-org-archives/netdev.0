From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2] phy: fix crash in fixed_phy_add()
Date: Tue, 17 May 2016 15:15:42 +0200
Message-ID: <20160517131542.GA25024@lunn.ch>
References: <1463475710-15869-1-git-send-email-rabin.vincent@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, f.fainelli@gmail.com,
	netdev@vger.kernel.org, Rabin Vincent <rabinv@axis.com>
To: Rabin Vincent <rabin.vincent@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40411 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427AbcEQNPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 09:15:46 -0400
Content-Disposition: inline
In-Reply-To: <1463475710-15869-1-git-send-email-rabin.vincent@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 11:01:50AM +0200, Rabin Vincent wrote:

Hi Rabin

Thanks for v2. This is a lot better

> @@ -314,6 +315,9 @@ struct phy_device *fixed_phy_register(unsigned int irq,
>  	int phy_addr;
>  	int ret;
>  
> +	if (!fmb->mii_bus)
> +		return ERR_PTR(-EPROBE_DEFER);

Better still:

       if (!fmb->mii_bus || fmb->mii_bus->state != MDIOBUS_REGISTERED)
		return ERR_PTR(-EPROBE_DEFER);

Thanks
	Andrew
