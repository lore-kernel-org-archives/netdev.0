From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/6] dccp: do not assume DCCP code is non preemptible
Date: Wed, 27 Apr 2016 22:25:49 -0700
Message-ID: <1461821152-23200-4-git-send-email-edumazet@google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33407 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcD1F0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 01:26:05 -0400
Received: by mail-pf0-f178.google.com with SMTP id 206so29375428pfu.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 22:26:05 -0700 (PDT)
In-Reply-To: <1461821152-23200-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCCP uses the generic backlog code, and this will soon
be changed to not disable BH when protocol is called back.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/input.c   | 2 +-
 net/dccp/ipv4.c    | 4 ++--
 net/dccp/ipv6.c    | 4 ++--
 net/dccp/options.c | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index 2437ecc13b82..ba347184bda9 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -359,7 +359,7 @@ send_sync:
 		goto discard;
 	}
 
-	__DCCP_INC_STATS(DCCP_MIB_INERRS);
+	DCCP_INC_STATS(DCCP_MIB_INERRS);
 discard:
 	__kfree_skb(skb);
 	return 0;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a8164272e0f4..5c7e413a3ae4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -533,8 +533,8 @@ static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 	bh_unlock_sock(ctl_sk);
 
 	if (net_xmit_eval(err) == 0) {
-		__DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
-		__DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
+		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
+		DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 	}
 out:
 	 dst_release(dst);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 0f4eb4ea57a5..d176f4e66369 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -277,8 +277,8 @@ static void dccp_v6_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
 		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
-		__DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
-		__DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
+		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
+		DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 		return;
 	}
 
diff --git a/net/dccp/options.c b/net/dccp/options.c
index b82b7ee9a1d2..74d29c56c367 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -253,7 +253,7 @@ out_nonsensical_length:
 	return 0;
 
 out_invalid_option:
-	__DCCP_INC_STATS(DCCP_MIB_INVALIDOPT);
+	DCCP_INC_STATS(DCCP_MIB_INVALIDOPT);
 	rc = DCCP_RESET_CODE_OPTION_ERROR;
 out_featneg_failed:
 	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
-- 
2.8.0.rc3.226.g39d4020
