From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] uwb: use the %pM formatting specifier in eda.c
Date: Tue, 28 Oct 2008 15:55:44 -0700
Message-ID: <1225234544.11483.65.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:22615 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbYJ1Wzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:55:49 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2967241rvb.1
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 15:55:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/uwb/wlp/eda.c |   38 +++++++++-----------------------------
 1 files changed, 9 insertions(+), 29 deletions(-)

diff --git a/drivers/uwb/wlp/eda.c b/drivers/uwb/wlp/eda.c
index cdfe8df..10985fa 100644
--- a/drivers/uwb/wlp/eda.c
+++ b/drivers/uwb/wlp/eda.c
@@ -313,12 +313,9 @@ int wlp_eda_for_virtual(struct wlp_eda *eda,
 	list_for_each_entry(itr, &eda->cache, list_node) {
 		if (!memcmp(itr->virt_addr, virt_addr,
 			   sizeof(itr->virt_addr))) {
-			d_printf(6, dev, "EDA: looking for "
-			       "%02x:%02x:%02x:%02x:%02x:%02x hit %02x:%02x "
+			d_printf(6, dev, "EDA: looking for %pM hit %02x:%02x "
 			       "wss %p tag 0x%02x state %u\n",
-			       virt_addr[0], virt_addr[1],
-			       virt_addr[2], virt_addr[3],
-			       virt_addr[4], virt_addr[5],
+			       virt_addr,
 			       itr->dev_addr.data[1],
 			       itr->dev_addr.data[0], itr->wss,
 			       itr->tag, itr->state);
@@ -327,24 +324,13 @@ int wlp_eda_for_virtual(struct wlp_eda *eda,
 			found = 1;
 			break;
 		} else
-			d_printf(6, dev, "EDA: looking for "
-			       "%02x:%02x:%02x:%02x:%02x:%02x "
-			       "against "
-			       "%02x:%02x:%02x:%02x:%02x:%02x miss\n",
-			       virt_addr[0], virt_addr[1],
-			       virt_addr[2], virt_addr[3],
-			       virt_addr[4], virt_addr[5],
-			       itr->virt_addr[0], itr->virt_addr[1],
-			       itr->virt_addr[2], itr->virt_addr[3],
-			       itr->virt_addr[4], itr->virt_addr[5]);
+			d_printf(6, dev, "EDA: looking for %pM against %pM miss\n",
+			         virt_addr, itr->virt_addr);
 	}
 	if (!found) {
 		if (printk_ratelimit())
-			dev_err(dev, "EDA: Eth addr %02x:%02x:%02x"
-				":%02x:%02x:%02x not found.\n",
-				virt_addr[0], virt_addr[1],
-				virt_addr[2], virt_addr[3],
-				virt_addr[4], virt_addr[5]);
+			dev_err(dev, "EDA: Eth addr %pM not found.\n",
+				virt_addr);
 		result = -ENODEV;
 	}
 	spin_unlock_irqrestore(&eda->lock, flags);
@@ -380,19 +366,13 @@ ssize_t wlp_eda_show(struct wlp *wlp, char *buf)
 			   "tag state virt_addr\n");
 	list_for_each_entry(entry, &eda->cache, list_node) {
 		result += scnprintf(buf + result, PAGE_SIZE - result,
-				    "%02x:%02x:%02x:%02x:%02x:%02x %02x:%02x "
-				    "%p 0x%02x %s "
-				    "%02x:%02x:%02x:%02x:%02x:%02x\n",
-				    entry->eth_addr[0], entry->eth_addr[1],
-				    entry->eth_addr[2], entry->eth_addr[3],
-				    entry->eth_addr[4], entry->eth_addr[5],
+				    "%pM %02x:%02x %p 0x%02x %s %pM\n",
+				    entry->eth_addr,
 				    entry->dev_addr.data[1],
 				    entry->dev_addr.data[0], entry->wss,
 				    entry->tag,
 				    wlp_wss_connect_state_str(entry->state),
-				    entry->virt_addr[0], entry->virt_addr[1],
-				    entry->virt_addr[2], entry->virt_addr[3],
-				    entry->virt_addr[4], entry->virt_addr[5]);
+				    entry->virt_addr);
 		if (result >= PAGE_SIZE)
 			break;
 	}
-- 
1.6.0.3.756.gb776d



