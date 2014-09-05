From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: update UMAC_CMD only when
 link is detected
Date: Thu, 04 Sep 2014 23:14:13 -0700 (PDT)
Message-ID: <20140904.231413.1123858399821566334.davem@davemloft.net>
References: <1409681827-5837-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaIEGOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 02:14:16 -0400
In-Reply-To: <1409681827-5837-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  2 Sep 2014 11:17:07 -0700

> When we bring the interface down, phy_stop() will schedule the PHY
> state machine to call our link adjustment callback. By the time we do so,
> we may have clock gated off the SYSTEMPORT hardware block, and this will
> cause bus errors to happen in bcm_sysport_adj_link():
> 
> Make sure that we only touch the UMAC_CMD register when there is an
> actual link. This is safe to do for two reasons:
> 
> - updating the Ethernet MAC registers only make sense when a physical
>   link is present
> - the PHY library state machine first set phydev->link = 0 before
>   invoking phydev->adjust_link in the PHY_HALTED case
> 
> This is a similar fix to the GENET one:
> c677ba8b3c47650358572091ed8a6af50bfca877 ("net: bcmgenet: update
> UMAC_CMD only when link is detected").
> 
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
