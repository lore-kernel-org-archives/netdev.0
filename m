From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] Fix 82598 premature copper PHY link
 indicatation
Date: Sun, 13 Dec 2009 19:18:58 -0800 (PST)
Message-ID: <20091213.191858.71104129.davem@davemloft.net>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
	<20091212075200.10952.13217.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155AbZLNDS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:18:56 -0500
In-Reply-To: <20091212075200.10952.13217.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Dec 2009 23:52:01 -0800

> +	for (timeout = 0;
> +	     timeout < IXGBE_VALIDATE_LINK_READY_TIMEOUT; timeout++) {
> +		hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN, &an_reg);
> +
> +		if ((an_reg & MDIO_AN_STAT1_COMPLETE) &&
> +		    (an_reg & MDIO_STAT1_LSTATUS))
> +			break;
> +
> +		mdelay(100);
> +	}

An up to 5000 msec non-preemptable spin loop.

If this used "msleep()" that would make it OK.

But as it is, sorry, no way.
