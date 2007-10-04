From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: fix debugging printout code
Date: Thu, 04 Oct 2007 11:38:43 -0700
Message-ID: <20071004183843.31540.23710.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28309 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbXJDSj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 14:39:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A small bug crawled in the -DDEBUG enabled code. Fix this to
properly call the backreference device name.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/hw.h     |    2 +-
 drivers/net/e1000e/netdev.c |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 848217a..aa82f1a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -852,7 +852,7 @@ struct e1000_hw {
 
 #ifdef DEBUG
 #define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG, "%s: " format, e1000_get_hw_dev_name(hw), ##arg);
+	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
 #else
 static inline int __attribute__ ((format (printf, 2, 3)))
 hw_dbg(struct e1000_hw *hw, const char *format, ...)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4a21d7d..3a0bb2a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -66,9 +66,7 @@ static const struct e1000_info *e1000_info_tbl[] = {
  **/
 char *e1000e_get_hw_dev_name(struct e1000_hw *hw)
 {
-	struct e1000_adapter *adapter = hw->back;
-	struct net_device *netdev = adapter->netdev;
-	return netdev->name;
+	return hw->adapter->netdev->name;
 }
 #endif
 
