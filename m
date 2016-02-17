From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] phy: marvell: Add support for phy packet
 generator
Date: Wed, 17 Feb 2016 15:49:45 -0800
Message-ID: <56C50719.7070608@gmail.com>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
 <1455741127-25453-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34168 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965013AbcBQXts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:49:48 -0500
Received: by mail-ob0-f174.google.com with SMTP id wb13so41129155obb.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 15:49:47 -0800 (PST)
In-Reply-To: <1455741127-25453-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/2016 12:32, Andrew Lunn wrote:
> +static int marvell_pkt_gen(struct phy_device *phydev,
> +			   struct ethtool_phy_pkt_gen *pkt_gen)
> +{
> +	int err, oldpage, reg, max_loop = 100;
> +	u32 phy_id = phydev->drv->phy_id;
> +	bool has_ipg = false;

[snip]


> +
> +	do {
> +		usleep_range(3000, 4000);
> +		reg = phy_read(phydev, MII_88E1540_PKT_GEN);
> +	} while (max_loop-- && (reg & MII_88E1540_PKT_GEN_ENABLE));
> +
> +	if (!max_loop)
> +		err = -ETIMEDOUT;

If I am a HW engineer trying to qualify a PHY after enabling the random
packet generator built into it, I might prefer a "start generation" and
"stop generation" (this echoes back to Ben's comments on the ethtool
API) as opposed to calling the same function multiple times, because the
duration will vary based on link speed, and potentially models of PHYs too.
