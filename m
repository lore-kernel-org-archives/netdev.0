From: varkabhadram@gmail.com
Subject: [PATCH net-next] netlink: remove bool varible
Date: Wed, 16 Jul 2014 10:59:47 +0530
Message-ID: <1405488587-26119-1-git-send-email-varkabhadram@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch removes the bool variable 'pass'.
If the swith case exist return true or return false.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 net/netlink/af_netlink.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e8c9f97..5dd8193 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -170,7 +170,6 @@ EXPORT_SYMBOL_GPL(netlink_remove_tap);
 static bool netlink_filter_tap(const struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
-	bool pass = false;
 
 	/* We take the more conservative approach and
 	 * whitelist socket protocols that may pass.
@@ -184,11 +183,10 @@ static bool netlink_filter_tap(const struct sk_buff *skb)
 	case NETLINK_FIB_LOOKUP:
 	case NETLINK_NETFILTER:
 	case NETLINK_GENERIC:
-		pass = true;
-		break;
+		return true;
 	}
 
-	return pass;
+	return false;
 }
 
 static int __netlink_deliver_tap_skb(struct sk_buff *skb,
-- 
1.7.9.5
