From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: phy: re-apply PHY fixups during
 phy_register_device
Date: Tue, 29 Jul 2014 12:26:26 -0700 (PDT)
Message-ID: <20140729.122626.714394251453806579.davem@davemloft.net>
References: <1406590087-28446-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org, hauke@hauke-m.de
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbaG2T03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 15:26:29 -0400
In-Reply-To: <1406590087-28446-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 28 Jul 2014 16:28:07 -0700

> Commit 87aa9f9c61ad ("net: phy: consolidate PHY reset in phy_init_hw()")
> moved the call to phy_scan_fixups() in phy_init_hw() after a software
> reset is performed.
> 
> By the time phy_init_hw() is called in phy_device_register(), no driver
> has been bound to this PHY yet, so all the checks in phy_init_hw()
> against the PHY driver and the PHY driver's config_init function will
> return 0. We will therefore never call phy_scan_fixups() as we should.
> 
> Fix this by calling phy_scan_fixups() and check for its return value to
> restore the intended functionality.
> 
> This broke PHY drivers which do register an early PHY fixup callback to
> intercept the PHY probing and do things like changing the 32-bits unique
> PHY identifier when a pseudo-PHY address has been used, as well as
> board-specific PHY fixups that need to be applied during driver probe
> time.
> 
> Reported-by: Hauke Merthens <hauke-m@hauke-m.de>
> Reported-by: Jonas Gorski <jogo@openwrt.org>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> - call phy_scan_fixups directly since this is what we are interested in
> - check the phy_scan_fixups return value
> 
> Applicable for 3.14+

Applied and queued up for -stable, thanks.
