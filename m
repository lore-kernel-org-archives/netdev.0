From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Subject: [PATCH] smsc: replace WARN_ON() with WARN_ON_SMP()
Date: Mon, 11 Aug 2014 13:46:23 +0530
Message-ID: <1407744983-29289-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sanjeev Sharma <sanjeev_sharma@mentor.com>,
	Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
To: <gregkh@linuxfoundation.org>, <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

spin_is_locked() always return false in uniprocessor configuration and therefore it
would be advise to repalce with WARN_ON_SMP().

Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
---
 drivers/net/ethernet/smsc/smsc911x.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
index 2395395..54d6489 100644
--- a/drivers/net/ethernet/smsc/smsc911x.h
+++ b/drivers/net/ethernet/smsc/smsc911x.h
@@ -51,7 +51,7 @@
 
 #ifdef CONFIG_DEBUG_SPINLOCK
 #define SMSC_ASSERT_MAC_LOCK(pdata) \
-		WARN_ON(!spin_is_locked(&pdata->mac_lock))
+		WARN_ON_SMP(!spin_is_locked(&pdata->mac_lock))
 #else
 #define SMSC_ASSERT_MAC_LOCK(pdata) do {} while (0)
 #endif				/* CONFIG_DEBUG_SPINLOCK */
-- 
1.7.11.7
