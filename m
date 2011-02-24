From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] skge: don't mark carrier down at start
Date: Wed, 23 Feb 2011 16:44:49 -0800
Message-ID: <20110223164449.2a5206b8@nehalam>
References: <bug-29612-10286@https.bugzilla.kernel.org/>
	<20110223162156.17ab2bc5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, gbillios@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48665 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751173Ab1BXApr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 19:45:47 -0500
In-Reply-To: <20110223162156.17ab2bc5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The API for network devices has changed so that setting carrier
off at probe is no longer required. This should fix the IPv6 addrconf
issue.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/skge.c	2011-02-23 16:40:36.351045685 -0800
+++ b/drivers/net/skge.c	2011-02-23 16:40:48.315136410 -0800
@@ -3856,9 +3856,6 @@ static struct net_device *skge_devinit(s
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	/* device is off until link detection */
-	netif_carrier_off(dev);
-
 	return dev;
 }
 
