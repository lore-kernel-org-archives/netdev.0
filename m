From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/13] r8169: multicast register update (sync with Realtek's
	8.004.00 8168 driver)
Date: Sun, 29 Jun 2008 16:39:17 +0200
Message-ID: <20080629143917.GB1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52844 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761348AbYF2Ojj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:39:39 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The layout of the 8168 serie is different from that of the 8110 one.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6572425..9086e81 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3098,8 +3098,10 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	    (tp->mac_version == RTL_GIGA_MAC_VER_15) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_16) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		mc_filter[0] = 0xffffffff;
-		mc_filter[1] = 0xffffffff;
+		u32 data = mc_filter[0];
+
+		mc_filter[0] = swab32(mc_filter[1]);
+		mc_filter[1] = swab32(data);
 	}
 
 	RTL_W32(MAR0 + 0, mc_filter[0]);
-- 
1.5.3.3

