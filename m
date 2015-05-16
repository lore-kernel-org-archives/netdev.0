From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Make sure PHY_RESUMING state change is
 always processed
Date: Sat, 16 May 2015 17:16:02 -0400 (EDT)
Message-ID: <20150516.171602.2037998130518497261.davem@davemloft.net>
References: <1431482104-1030-1-git-send-email-tim.beale@alliedtelesis.co.nz>
	<5556645D.4050202@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.beale@alliedtelesis.co.nz, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbEPVQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:16:03 -0400
In-Reply-To: <5556645D.4050202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 May 2015 14:25:49 -0700

> On 12/05/15 18:55, Tim Beale wrote:
>> If phy_start_aneg() was called while the phydev is in the PHY_RESUMING
>> state, then its state would immediately transition to PHY_AN (or
>> PHY_FORCING). This meant the phy_state_machine() never processed the
>> PHY_RESUMING state change, which meant interrupts weren't enabled for the
>> PHY. If the PHY used low-power mode (i.e. using BMCR_PDOWN), then the
>> physical link wouldn't get powered up again.
>> 
>> There seems no point for phy_start_aneg() to make the PHY_RESUMING -->
>> PHY_AN transition, as the state machine will do this anyway. I'm not sure
>> about the case where autoneg is disabled, as my patch will change
>> behaviour so that the PHY goes to PHY_NOLINK instead of PHY_FORCING. An
>> alternative solution would be to move the phy_config_interrupt() and
>> phy_resume() work out of the state machine and into phy_start().
> 
> Could you prepare a patch which does that? I do not have a setup where
> the PHY IRQ is a dedicated interrupt line, but I might be able to test
> something with a hack.
> 
>> 
>> The background behind this: we're running linux v3.16.7 and from user-space
>> we want to enable the eth port (i.e. do a SIOCSIFFLAGS ioctl with the
>> IFF_UP flag) and immediately afterward set the interface's speed/duplex.
>> Enabling the interface calls .ndo_open() then phy_start() and the PHY
>> transitions PHY_HALTED --> PHY_RESUMING. Setting the speed/duplex ends up
>> calling phy_ethtool_sset(), which calls phy_start_aneg() (meanwhile the
>> phy_state_machine() hasn't processed the PHY_RESUMING state change yet).
>> 
>> Signed-off-by: Tim Beale <tim.beale@alliedtelesis.co.nz>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks everyone.
