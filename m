From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 46/51] ath6kl: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:36 -0400
Message-ID: <1333335521-1348-47-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab2DBDAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:41 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/ath/ath6kl/testmode.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/testmode.c b/drivers/net/wireless/ath/ath6kl/testmode.c
index 6675c92..acc9aa8 100644
--- a/drivers/net/wireless/ath/ath6kl/testmode.c
+++ b/drivers/net/wireless/ath/ath6kl/testmode.c
@@ -55,8 +55,9 @@ void ath6kl_tm_rx_event(struct ath6kl *ar, void *buf, size_t buf_len)
 		ath6kl_warn("failed to allocate testmode rx skb!\n");
 		return;
 	}
-	NLA_PUT_U32(skb, ATH6KL_TM_ATTR_CMD, ATH6KL_TM_CMD_TCMD);
-	NLA_PUT(skb, ATH6KL_TM_ATTR_DATA, buf_len, buf);
+	if (nla_put_u32(skb, ATH6KL_TM_ATTR_CMD, ATH6KL_TM_CMD_TCMD) ||
+	    nla_put(skb, ATH6KL_TM_ATTR_DATA, buf_len, buf))
+		goto nla_put_failure;
 	cfg80211_testmode_event(skb, GFP_KERNEL);
 	return;
 
-- 
1.7.7.6
