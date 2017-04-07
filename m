From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Fri, 7 Apr 2017 16:29:43 +0200
Message-ID: <20170407142943.GC23415@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-3-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49734 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932873AbdDGO3p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:29:45 -0400
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-3-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Juergen

> +static int lan9303_virt_phy_reg_read(struct lan9303 *chip, int regnum)
> +{
> +	int ret;
> +	u32 val;
> +
> +	if (regnum > MII_EXPANSION) {
> +		if (regnum == MII_LAN911X_SPECIAL_CONTROL_STATUS)
> +			regnum = 7; /* map to LAN9303_VIRT_SPECIAL_CTRL */
> +		else
> +			return -EINVAL;
> +	}

What PHY ID does the virtual PHY use? The same as the LAN911X? Or
something different. I'm just wondering if this should be in the PHY
driver. But that only works if you can differentiate the virtual PHY
from the real PHYs in the PHY driver.

     Andrew
