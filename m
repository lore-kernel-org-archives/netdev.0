From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bcmgenet: enable MoCA link state
 change detection
Date: Wed, 01 Apr 2015 13:40:37 -0400 (EDT)
Message-ID: <20150401.134037.1631948165977093044.davem@davemloft.net>
References: <20150401074000.CD2CD2203CD@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbbDARkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 13:40:42 -0400
In-Reply-To: <20150401074000.CD2CD2203CD@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed,  1 Apr 2015 00:40:00 -0700 (PDT)

> Currently, MoCA fixed PHYs are always in link-up state, regardless of
> whether the link is actually up or not.
> 
> Add code to properly detect MoCA link state changes and to reflect the
> new state in MoCA fixed PHY. Only GENET V3 and V4 MACs are capable of
> detecting MoCA link state changes.
> 
> The code works as follows:
> 1. GENET MAC detects MoCA link state change and issues UMAC_IRQ_LINK_UP
>    or UMAC_IRQ_LINK_DOWN interrupt.
> 2. Link up/down interrupt is processed in bcmgenet_irq_task(), which
>    calls phy_mac_interrupt().
> 3. phy_mac_interrupt() updates the fixed PHY phydev->link and kicks
>    the PHY state machine.
> 4. PHY state machine proceeds to read the fixed PHY link status
>    register.
> 5. When the fixed PHY link status register is being read, the new
>    function bcmgenet_fixed_phy_link_update() gets called. It copies
>    the fixed PHY phydev->link value to the fixed PHY status->link.
> 6. PHY state machine receives the new link state of the fixed PHY.
> 7. MoCA fixed PHY link state now correctly reflects the real MoCA
>    hardware link state.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
