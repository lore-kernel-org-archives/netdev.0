From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 21/21] r8169: perform RX config change after mac filtering
Date: Fri, 29 Jun 2007 22:29:45 +0200
Message-ID: <20070629202945.GW3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32791 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbXF2UcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:32:22 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It does not really make sense to update the RX config register
before the mac filtering registers.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7aa9cf4..982a901 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2953,10 +2953,11 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = 0xffffffff;
 	}
 
-	RTL_W32(RxConfig, tmp);
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 	RTL_W32(MAR0 + 4, mc_filter[1]);
 
+	RTL_W32(RxConfig, tmp);
+
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-- 
1.4.4.2

