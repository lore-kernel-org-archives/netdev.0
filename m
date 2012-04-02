From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 49/51] wl12xx: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:39 -0400
Message-ID: <1333335521-1348-50-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592Ab2DBDAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:47 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/wl12xx/testmode.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/testmode.c b/drivers/net/wireless/wl12xx/testmode.c
index 1e93bb9..b41428f 100644
--- a/drivers/net/wireless/wl12xx/testmode.c
+++ b/drivers/net/wireless/wl12xx/testmode.c
@@ -116,7 +116,8 @@ static int wl1271_tm_cmd_test(struct wl1271 *wl, struct nlattr *tb[])
 			goto out_sleep;
 		}
 
-		NLA_PUT(skb, WL1271_TM_ATTR_DATA, buf_len, buf);
+		if (nla_put(skb, WL1271_TM_ATTR_DATA, buf_len, buf))
+			goto nla_put_failure;
 		ret = cfg80211_testmode_reply(skb);
 		if (ret < 0)
 			goto out_sleep;
@@ -178,7 +179,8 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 		goto out_free;
 	}
 
-	NLA_PUT(skb, WL1271_TM_ATTR_DATA, sizeof(*cmd), cmd);
+	if (nla_put(skb, WL1271_TM_ATTR_DATA, sizeof(*cmd), cmd))
+		goto nla_put_failure;
 	ret = cfg80211_testmode_reply(skb);
 	if (ret < 0)
 		goto out_free;
@@ -297,7 +299,8 @@ static int wl12xx_tm_cmd_get_mac(struct wl1271 *wl, struct nlattr *tb[])
 		goto out;
 	}
 
-	NLA_PUT(skb, WL1271_TM_ATTR_DATA, ETH_ALEN, mac_addr);
+	if (nla_put(skb, WL1271_TM_ATTR_DATA, ETH_ALEN, mac_addr))
+		goto nla_put_failure;
 	ret = cfg80211_testmode_reply(skb);
 	if (ret < 0)
 		goto out;
-- 
1.7.7.6
