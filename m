From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH v2] mwifiex: use is_zero_ether_addr() instead of memcmp()
Date: Fri, 24 Aug 2012 13:27:10 +0800
Message-ID: <CAPgLHd8+H415tRqvyM1SXQCSC6savCakuFLdjM1ebWvjikd5NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: bzhao@marvell.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:59923 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab2HXF1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 01:27:11 -0400
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
 drivers/net/wireless/mwifiex/sta_cmdresp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index 0b09004..62223ab 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -736,7 +736,6 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 {
 	struct host_cmd_ds_802_11_ibss_status *ibss_coal_resp =
 					&(resp->params.ibss_coalescing);
-	u8 zero_mac[ETH_ALEN] = { 0, 0, 0, 0, 0, 0 };
 
 	if (le16_to_cpu(ibss_coal_resp->action) == HostCmd_ACT_GEN_SET)
 		return 0;
@@ -745,7 +744,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
 		"info: new BSSID %pM\n", ibss_coal_resp->bssid);
 
 	/* If rsp has NULL BSSID, Just return..... No Action */
-	if (!memcmp(ibss_coal_resp->bssid, zero_mac, ETH_ALEN)) {
+	if (is_zero_ether_addr(ibss_coal_resp->bssid)) {
 		dev_warn(priv->adapter->dev, "new BSSID is NULL\n");
 		return 0;
 	}
