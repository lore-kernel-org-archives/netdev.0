From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH] uwb: use '%pM' format to print MAC address
Date: Sat, 11 Sep 2010 18:05:46 +0300
Message-ID: <1284217546-29934-1-git-send-email-andy.shevchenko@gmail.com>
Cc: David Vrabel <david.vrabel@csr.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Andy Shevchenko <andy.shevchenko@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:46982 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059Ab0IKPGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 11:06:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/uwb/address.c    |    5 +----
 drivers/uwb/wlp/wss-lc.c |    8 +++-----
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/uwb/address.c b/drivers/uwb/address.c
index 9733213..0336eab 100644
--- a/drivers/uwb/address.c
+++ b/drivers/uwb/address.c
@@ -363,10 +363,7 @@ size_t __uwb_addr_print(char *buf, size_t buf_size, const unsigned char *addr,
 {
 	size_t result;
 	if (type)
-		result = scnprintf(buf, buf_size,
-				  "%02x:%02x:%02x:%02x:%02x:%02x",
-				  addr[0], addr[1], addr[2],
-				  addr[3], addr[4], addr[5]);
+		result = scnprintf(buf, buf_size, "%pM", &addr[0]);
 	else
 		result = scnprintf(buf, buf_size, "%02x:%02x",
 				  addr[1], addr[0]);
diff --git a/drivers/uwb/wlp/wss-lc.c b/drivers/uwb/wlp/wss-lc.c
index a005d2a..bb5d2ae 100644
--- a/drivers/uwb/wlp/wss-lc.c
+++ b/drivers/uwb/wlp/wss-lc.c
@@ -791,11 +791,9 @@ int wlp_wss_prep_hdr(struct wlp *wlp, struct wlp_eda_node *eda_entry,
 	} else {
 		if (printk_ratelimit())
 			dev_err(dev, "WLP: Destination neighbor (Ethernet: "
-				"%02x:%02x:%02x:%02x:%02x:%02x, Dev: "
-				"%02x:%02x) is not connected. \n", eth_addr[0],
-				eth_addr[1], eth_addr[2], eth_addr[3],
-				eth_addr[4], eth_addr[5], dev_addr->data[1],
-				dev_addr->data[0]);
+				"%pM, Dev: %02x:%02x) is not connected.\n",
+				&eth_addr[0],
+				dev_addr->data[1], dev_addr->data[0]);
 		result = -EINVAL;
 	}
 	return result;
-- 
1.7.2.2

