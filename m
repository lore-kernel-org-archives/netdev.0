From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Make sure phy_start() always re-enables the
 phy interrupts
Date: Thu, 21 May 2015 16:50:12 -0400 (EDT)
Message-ID: <20150521.165012.2187615495132464149.davem@davemloft.net>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
	<1431920318-7157-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: tim.beale@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756137AbbEUUuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:50:16 -0400
In-Reply-To: <1431920318-7157-1-git-send-email-tim.beale@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Beale <tim.beale@alliedtelesis.co.nz>
Date: Mon, 18 May 2015 15:38:38 +1200

> This is an alternative way of fixing:
>  commit db9683fb412d ("net: phy: Make sure PHY_RESUMING state change
>                       is always processed")
> 
> When the PHY state transitions from PHY_HALTED to PHY_RESUMING, there are
> two things we need to do:
> 1). Re-enable interrupts (and power up the physical link, if powered down)
> 2). Update the PHY state and net-device based on the link status.
> 
> There's no strict reason why #1 has to be done from within the main
> phy_state_machine() function. There is a risk that other changes to the
> PHY (e.g. setting speed/duplex, which calls phy_start_aneg()) could cause
> a subsequent state transition before phy_state_machine() has processed
> the PHY_RESUMING state change. This would leave the PHY with interrupts
> disabled and/or still in the BMCR_PDOWN/low-power mode.
> 
> Moving enabling the interrupts and phy_resume() into phy_start() will
> guarantee this work always gets done. As the PHY is already in the HALTED
> state and interrupts are disabled, it shouldn't conflict with any work
> being done in phy_state_machine(). The downside of this change is that if
> the PHY_RESUMING state is ever entered from anywhere else, it'll also have
> to repeat this work.
> 
> Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>

Applied.
