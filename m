From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Sat, 28 Oct 2017 21:01:39 +0200
Message-ID: <20171028190139.GA17645@lunn.ch>
References: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:60821 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751326AbdJ1TBr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 15:01:47 -0400
Content-Disposition: inline
In-Reply-To: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 03:28:36PM +0300, Aaro Koskinen wrote:
> Hi,
> 
> When upgrading from v4.13 to v4.14-rc6 on OpenRD Client, the box loses
> network connectivity.

Hi Aaro

What exactly is the PHY in the OpenRD?

>  
> -	mscr &= MII_88E1121_PHY_MSCR_DELAY_MASK;
> +	mscr &= ~MII_88E1121_PHY_MSCR_DELAY_MASK;

Please can you print the value of mscr before it is changed.

One possibility, is that the bootloader is setting the PHY to
rgmii-id. This is now getting cleared, where earlier it was
preserved. If this is true, it should be solved by adding

phy-mode = "rgmii-id" to the ethernet node in the device tree.

	 Andrew
