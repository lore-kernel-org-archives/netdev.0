From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: properly propagate carrier
 down state for MoCA
Date: Sun, 17 May 2015 23:40:55 -0400 (EDT)
Message-ID: <20150517.234055.677371627234815683.davem@davemloft.net>
References: <1431718681-8925-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbbERDk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:40:57 -0400
In-Reply-To: <1431718681-8925-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 May 2015 12:38:01 -0700

> MoCA interfaces require the use of an user-space daemon (mocad) which
> will typically use cmd->autoneg to force the link. This is causing other
> network manager applications not to get proper carrier down
> notifications because of the following sequence of events:
> 
> - link down interrupt is received, link is set to 0 by the interrupt
>   handler
> - fixed_link update callback runs and updates the BMSR register
>   accordingly
> - PHY library polls the PHY for link status, sees the link is down,
>   proceeds with reporting that
> - mocad gets notified of the link state and call phy_ethtool_sset()
>   with cmd->autoneg set to the link status (0)
> - phy_start_aneg() is called at the end of phy_ethtool_sset() and sets
>   the PHY state to PHY_FORCING
> 
> Just make sure we notify the interface carrier appropriately when we
> detect that the link is down in our fixed_link update callback. This is
> made local to the bcm_sf2 driver as the PHY library does the right thing
> in any case. This is similar to the GENET change introduced in
> 54d7c01d3ed699cfc213115eaecfe1175cfaff8f ("net: bcmgenet: enable MoCA
> link state change detection").
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thank you.
