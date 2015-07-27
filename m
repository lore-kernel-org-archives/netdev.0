From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Register link_update callback
 for all MoCA PHYs
Date: Sun, 26 Jul 2015 20:54:15 -0700 (PDT)
Message-ID: <20150726.205415.573396781347754561.davem@davemloft.net>
References: <1437611393-6494-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbbG0Dyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 23:54:44 -0400
In-Reply-To: <1437611393-6494-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 22 Jul 2015 17:29:53 -0700

> Commit 8d88c6ebb34c ("net: bcmgenet: enable MoCA link state change
> detection") added a fixed PHY link_update callback for MoCA PHYs when
> registered using platform_data exclusively, this change is also
> applicable to systems using Device Tree as their primary configuration
> interface.
> 
> In order for this to work, move the link_update assignment into
> bcmgenet_moca_phy_setup() where we know for sure that we are running on
> a MoCA GENET instance, and do not override phydev->link since this is:
> 
> - properly taken care of by the PHY library by getting the link UP/DOWN
>   interrupts
> - this now runs everytime we call bcmgenet_open(), so we need to
>   preserve whatever we detected before we went administratively DOWN and
>   then UP
> - we need to make sure that MoCA PHYs start with a link DOWN during
>   probe in order to force a link transition to occur
> 
> To avoid a forward declaration, move bcmgenet_fixed_phy_link_update()
> above its caller.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
