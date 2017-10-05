From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission (fwd)
Date: Thu, 5 Oct 2017 11:14:47 -0500
Message-ID: <55a2851f-d65d-b5a5-17d3-7c6aa5d5d8f0@ti.com>
References: <alpine.DEB.2.20.1710051809480.3168@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:58241 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751094AbdJEQPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:15:03 -0400
In-Reply-To: <alpine.DEB.2.20.1710051809480.3168@hadrien>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia

On 10/05/2017 11:10 AM, Julia Lawall wrote:
> DP83822_WOL_CLR_INDICATION appears twice on line 136.  Perhaps this is not
> what is wanted.
> 

That line is wrong it should have DP83822_WOL_INDICATION_SEL included as well.

Onto v3.

Dan

> julia
> 
> ---------- Forwarded message ----------
> Date: Thu, 5 Oct 2017 21:38:28 +0800
> From: kbuild test robot <fengguang.wu@intel.com>
> To: kbuild@01.org
> Cc: Julia Lawall <julia.lawall@lip6.fr>
> Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
> 
> CC: kbuild-all@01.org
> In-Reply-To: <20171003155316.12312-1-dmurphy@ti.com>
> TO: Dan Murphy <dmurphy@ti.com>
> CC: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org, Dan Murphy <dmurphy@ti.com>
> CC: netdev@vger.kernel.org, Dan Murphy <dmurphy@ti.com>
> 
> Hi Dan,
> 
> [auto build test WARNING on net-next/master]
> [also build test WARNING on v4.14-rc3 next-20170929]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Dan-Murphy/net-phy-DP83822-initial-driver-submission/20171005-165547
> :::::: branch date: 5 hours ago
> :::::: commit date: 5 hours ago
> 
>>> drivers/net/phy/dp83822.c:136:29-55: duplicated argument to & or |
> 
> # https://github.com/0day-ci/linux/commit/49190df6a2304f031dc2a6ac63710447db36bc23
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout 49190df6a2304f031dc2a6ac63710447db36bc23
> vim +136 drivers/net/phy/dp83822.c
> 
> 49190df6 Dan Murphy 2017-10-03   90
> 49190df6 Dan Murphy 2017-10-03   91  static int dp83822_set_wol(struct phy_device *phydev,
> 49190df6 Dan Murphy 2017-10-03   92  			   struct ethtool_wolinfo *wol)
> 49190df6 Dan Murphy 2017-10-03   93  {
> 49190df6 Dan Murphy 2017-10-03   94  	struct net_device *ndev = phydev->attached_dev;
> 49190df6 Dan Murphy 2017-10-03   95  	u16 value;
> 49190df6 Dan Murphy 2017-10-03   96  	const u8 *mac;
> 49190df6 Dan Murphy 2017-10-03   97
> 49190df6 Dan Murphy 2017-10-03   98  	if (wol->wolopts & (WAKE_MAGIC | WAKE_MAGICSECURE)) {
> 49190df6 Dan Murphy 2017-10-03   99  		mac = (const u8 *)ndev->dev_addr;
> 49190df6 Dan Murphy 2017-10-03  100
> 49190df6 Dan Murphy 2017-10-03  101  		if (!is_valid_ether_addr(mac))
> 49190df6 Dan Murphy 2017-10-03  102  			return -EFAULT;
> 49190df6 Dan Murphy 2017-10-03  103
> 49190df6 Dan Murphy 2017-10-03  104  		/* MAC addresses start with byte 5, but stored in mac[0].
> 49190df6 Dan Murphy 2017-10-03  105  		 * 822 PHYs store bytes 4|5, 2|3, 0|1
> 49190df6 Dan Murphy 2017-10-03  106  		 */
> 49190df6 Dan Murphy 2017-10-03  107  		phy_write_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  108  			      MII_DP83822_WOL_DA1, (mac[1] << 8) | mac[0]);
> 49190df6 Dan Murphy 2017-10-03  109  		phy_write_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  110  			      MII_DP83822_WOL_DA2, (mac[3] << 8) | mac[2]);
> 49190df6 Dan Murphy 2017-10-03  111  		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA3,
> 49190df6 Dan Murphy 2017-10-03  112  			      (mac[5] << 8) | mac[4]);
> 49190df6 Dan Murphy 2017-10-03  113
> 49190df6 Dan Murphy 2017-10-03  114  		value = phy_read_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  115  				     MII_DP83822_WOL_CFG);
> 49190df6 Dan Murphy 2017-10-03  116  		if (wol->wolopts & WAKE_MAGIC)
> 49190df6 Dan Murphy 2017-10-03  117  			value |= DP83822_WOL_MAGIC_EN;
> 49190df6 Dan Murphy 2017-10-03  118  		else
> 49190df6 Dan Murphy 2017-10-03  119  			value &= ~DP83822_WOL_MAGIC_EN;
> 49190df6 Dan Murphy 2017-10-03  120
> 49190df6 Dan Murphy 2017-10-03  121  		if (wol->wolopts & WAKE_MAGICSECURE) {
> 49190df6 Dan Murphy 2017-10-03  122  			value |= DP83822_WOL_SECURE_ON;
> 49190df6 Dan Murphy 2017-10-03  123  			phy_write_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  124  				      MII_DP83822_RXSOP1,
> 49190df6 Dan Murphy 2017-10-03  125  				      (wol->sopass[1] << 8) | wol->sopass[0]);
> 49190df6 Dan Murphy 2017-10-03  126  			phy_write_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  127  				      MII_DP83822_RXSOP2,
> 49190df6 Dan Murphy 2017-10-03  128  				      (wol->sopass[3] << 8) | wol->sopass[2]);
> 49190df6 Dan Murphy 2017-10-03  129  			phy_write_mmd(phydev, DP83822_DEVADDR,
> 49190df6 Dan Murphy 2017-10-03  130  				      MII_DP83822_RXSOP3,
> 49190df6 Dan Murphy 2017-10-03  131  				      (wol->sopass[5] << 8) | wol->sopass[4]);
> 49190df6 Dan Murphy 2017-10-03  132  		} else {
> 49190df6 Dan Murphy 2017-10-03  133  			value &= ~DP83822_WOL_SECURE_ON;
> 49190df6 Dan Murphy 2017-10-03  134  		}
> 49190df6 Dan Murphy 2017-10-03  135
> 49190df6 Dan Murphy 2017-10-03 @136  		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
> 49190df6 Dan Murphy 2017-10-03  137  			  DP83822_WOL_CLR_INDICATION);
> 49190df6 Dan Murphy 2017-10-03  138  		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> 49190df6 Dan Murphy 2017-10-03  139  			      value);
> 49190df6 Dan Murphy 2017-10-03  140  	} else {
> 49190df6 Dan Murphy 2017-10-03  141  		value =
> 49190df6 Dan Murphy 2017-10-03  142  		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> 49190df6 Dan Murphy 2017-10-03  143  		value &= (~DP83822_WOL_EN);
> 49190df6 Dan Murphy 2017-10-03  144  		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> 49190df6 Dan Murphy 2017-10-03  145  			      value);
> 49190df6 Dan Murphy 2017-10-03  146  	}
> 49190df6 Dan Murphy 2017-10-03  147
> 49190df6 Dan Murphy 2017-10-03  148  	return 0;
> 49190df6 Dan Murphy 2017-10-03  149  }
> 49190df6 Dan Murphy 2017-10-03  150
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


-- 
------------------
Dan Murphy
