From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Tue, 19 Apr 2016 00:42:26 +0200
Message-ID: <20160418224226.GE25196@piout.net>
References: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
 <57114AA4.5080803@gmail.com>
 <20160415205613.GE25196@piout.net>
 <20160415220508.GC26665@lunn.ch>
 <20160415221711.GG25196@piout.net>
 <571169EB.4090300@gmail.com>
 <20160418221433.GX25196@piout.net>
 <57155D16.2080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S . Miller" <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:35280 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752049AbcDRWmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:42:38 -0400
Content-Disposition: inline
In-Reply-To: <57155D16.2080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/2016 at 15:17:58 -0700, Florian Fainelli wrote :
> Yes, seems like it, how about adding this:
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c
> b/drivers/net/ethernet/cadence/macb.c
> index 98b99149ce0b..21096dfb0e83 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -440,7 +440,7 @@ static int macb_mii_init(struct macb *bp)
>         snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
>                  bp->pdev->name, bp->pdev->id);
>         bp->mii_bus->priv = bp;
> -       bp->mii_bus->parent = &bp->dev->dev;
> +       bp->mii_bus->parent = &bp->pdev->dev;
>         pdata = dev_get_platdata(&bp->pdev->dev);
> 
>         dev_set_drvdata(&bp->dev->dev, bp->mii_bus);

Works fine.

But still, this doesn't solve the phy issue ;)


-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
