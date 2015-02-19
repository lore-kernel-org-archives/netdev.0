From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] dsa: mv88e6131: support fixed PHYs
Date: Thu, 19 Feb 2015 15:19:38 -0500 (EST)
Message-ID: <20150219.151938.2124980198109409450.davem@davemloft.net>
References: <20150212141317.GB12318@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias@waldekranz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbBSUTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:19:41 -0500
In-Reply-To: <20150212141317.GB12318@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Waldekranz <tobias@waldekranz.com>
Date: Thu, 12 Feb 2015 15:13:17 +0100

> Statically setup the PCS Control on the MAC to match the fixed PHY.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
 ...
> +	/* PPU will configure MACs with physical PHYs */
> +	if (!fixed_phy_get_status(phy))
> +		return;

I kind of agree with Florian that you probably don't need this.

And furthermore, this fixed_phy_get_status() interface you created
isn't even used for what it's designed for.

As coded, fixed_phy_get_status() returns the link status structure,
but here you are only interested in whether a phy is fixed or not
because you're simply making a boolean test upon whether you were
given a non-NULL fixed phy status or not.
