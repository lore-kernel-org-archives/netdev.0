From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] mwifiex: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 14:54:29 +0800
Message-ID: <CAPgLHd9iXQf3_W5b4kO1Mv68udqnmfFO8n+R-0ZqzCrhg1Z_WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: bzhao@marvell.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43534 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757927Ab2HWGya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:54:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is all
zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/mwifiex/sta_cmdresp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index 0b09004..a2a33dc 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -17,6 +17,8 @@
  * this warranty disclaimer.
  */
 
+#include <linux/etherdevice.h>
+
 #include "decl.h"
 #include "ioctl.h"
 #include "util.h"
@@ -736,7 +738,6 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 {
 	struct host_cmd_ds_802_11_ibss_status *ibss_coal_resp =
 					&(resp->params.ibss_coalescing);
-	u8 zero_mac[ETH_ALEN] = { 0, 0, 0, 0, 0, 0 };
 
 	if (le16_to_cpu(ibss_coal_resp->action) == HostCmd_ACT_GEN_SET)
 		return 0;
@@ -745,7 +746,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 		"info: new BSSID %pM\n", ibss_coal_resp->bssid);
 
 	/* If rsp has NULL BSSID, Just return..... No Action */
-	if (!memcmp(ibss_coal_resp->bssid, zero_mac, ETH_ALEN)) {
+	if (is_zero_ether_addr(ibss_coal_resp->bssid)) {
 		dev_warn(priv->adapter->dev, "new BSSID is NULL\n");
 		return 0;
 	}
