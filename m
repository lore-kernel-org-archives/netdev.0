From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Wed, 4 Jan 2012 00:30:46 +0100
Message-ID: <20120103233046.GD8563@electric-eye.fr.zoreil.com>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org> <20111230.172211.188260740088628815.davem@davemloft.net> <20111231121704.GA9842@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: tbroch@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53341 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab2ACXjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 18:39:51 -0500
Content-Disposition: inline
In-Reply-To: <20111231121704.GA9842@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> The description of the patch implies that the initial power management
> state is not right. I would be more inclined to set it correctly when
> the device goes up instead of checking repeatedly for a loss of sync
> through rtl8169_runtime_idle. Todd, any comment ?

... which could be as simple as (completely untested) :

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c8f47f1..e9fbd41 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4309,7 +4309,7 @@ static int rtl8169_open(struct net_device *dev)
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
 
-	rtl8169_check_link_status(dev, tp, ioaddr);
+	__rtl8169_check_link_status(dev, tp, ioaddr, true);
 out:
 	return retval;
 
