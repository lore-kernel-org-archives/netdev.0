From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: phy: marvell: logical vs bitwise OR typo
Date: Fri, 4 Aug 2017 14:54:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004B432@AcuExch.aculab.com>
References: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:57538 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbdHDOyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 10:54:51 -0400
In-Reply-To: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter
> Sent: 04 August 2017 09:17
> This was supposed to be a bitwise OR but there is a || vs | typo.
> 
> Fixes: 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay configuration")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 361fe9927ef2..15cbcdba618a 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -83,7 +83,7 @@
>  #define MII_88E1121_PHY_MSCR_REG	21
>  #define MII_88E1121_PHY_MSCR_RX_DELAY	BIT(5)
>  #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
> -#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(BIT(5) || BIT(4)))
> +#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(BIT(5) | BIT(4)))

Wouldn't:
+#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(MII_88E1121_PHY_MSCR_RX_DELAY | MII_88E1121_PHY_MSCR_TX_DELAY))
be more correct?
If a little long?
Actually the ~ looks odd here....
Reads code....
Kill the define and explicitly mask off the two values just before
conditionally setting them.

	David
