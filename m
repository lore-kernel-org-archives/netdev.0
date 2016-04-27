From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/17] dccp: rename DCCP_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:28 -0700
Message-ID: <1461800683-25034-3-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34165 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbcD0Xo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:44:56 -0400
Received: by mail-pf0-f176.google.com with SMTP id y69so26272339pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:44:56 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename DCCP_INC_STATS_BH() to __DCCP_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/dccp.h      | 6 +++---
 net/dccp/input.c     | 2 +-
 net/dccp/ipv4.c      | 8 ++++----
 net/dccp/ipv6.c      | 8 ++++----
 net/dccp/minisocks.c | 2 +-
 net/dccp/options.c   | 2 +-
 net/dccp/timer.c     | 4 ++--
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b0e28d24e1a7..a4c6e2fed91c 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -198,9 +198,9 @@ struct dccp_mib {
 };
 
 DECLARE_SNMP_STAT(struct dccp_mib, dccp_statistics);
-#define DCCP_INC_STATS(field)	    SNMP_INC_STATS(dccp_statistics, field)
-#define DCCP_INC_STATS_BH(field)    SNMP_INC_STATS_BH(dccp_statistics, field)
-#define DCCP_DEC_STATS(field)	    SNMP_DEC_STATS(dccp_statistics, field)
+#define DCCP_INC_STATS(field)	SNMP_INC_STATS(dccp_statistics, field)
+#define __DCCP_INC_STATS(field)	SNMP_INC_STATS_BH(dccp_statistics, field)
+#define DCCP_DEC_STATS(field)	SNMP_DEC_STATS(dccp_statistics, field)
 
 /*
  * 	Checksumming routines
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 3bd14e885396..2437ecc13b82 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -359,7 +359,7 @@ send_sync:
 		goto discard;
 	}
 
-	DCCP_INC_STATS_BH(DCCP_MIB_INERRS);
+	__DCCP_INC_STATS(DCCP_MIB_INERRS);
 discard:
 	__kfree_skb(skb);
 	return 0;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f6d183f8f332..4b78067669d6 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -318,7 +318,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	case DCCP_REQUESTING:
 	case DCCP_RESPOND:
 		if (!sock_owned_by_user(sk)) {
-			DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
+			__DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
 			sk->sk_err = err;
 
 			sk->sk_error_report(sk);
@@ -533,8 +533,8 @@ static void dccp_v4_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 	bh_unlock_sock(ctl_sk);
 
 	if (net_xmit_eval(err) == 0) {
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 	}
 out:
 	 dst_release(dst);
@@ -637,7 +637,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 drop_and_free:
 	reqsk_free(req);
 drop:
-	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
+	__DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
 	return -1;
 }
 EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 8ceb3cebcad4..e175b8fe1a87 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -156,7 +156,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	case DCCP_RESPOND:  /* Cannot happen.
 			       It can, it SYNs are crossed. --ANK */
 		if (!sock_owned_by_user(sk)) {
-			DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
+			__DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
 			sk->sk_err = err;
 			/*
 			 * Wake people up to see the error
@@ -277,8 +277,8 @@ static void dccp_v6_ctl_send_reset(const struct sock *sk, struct sk_buff *rxskb)
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
 		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
+		__DCCP_INC_STATS(DCCP_MIB_OUTRSTS);
 		return;
 	}
 
@@ -378,7 +378,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 drop_and_free:
 	reqsk_free(req);
 drop:
-	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
+	__DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
 	return -1;
 }
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 1994f8af646b..53eddf99e4f6 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -127,7 +127,7 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
 		}
 		dccp_init_xmit_timers(newsk);
 
-		DCCP_INC_STATS_BH(DCCP_MIB_PASSIVEOPENS);
+		__DCCP_INC_STATS(DCCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
 }
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 9bce31886bda..b82b7ee9a1d2 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -253,7 +253,7 @@ out_nonsensical_length:
 	return 0;
 
 out_invalid_option:
-	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
+	__DCCP_INC_STATS(DCCP_MIB_INVALIDOPT);
 	rc = DCCP_RESET_CODE_OPTION_ERROR;
 out_featneg_failed:
 	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 3ef7acef3ce8..4ff22c24ff14 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -28,7 +28,7 @@ static void dccp_write_err(struct sock *sk)
 
 	dccp_send_reset(sk, DCCP_RESET_CODE_ABORTED);
 	dccp_done(sk);
-	DCCP_INC_STATS_BH(DCCP_MIB_ABORTONTIMEOUT);
+	__DCCP_INC_STATS(DCCP_MIB_ABORTONTIMEOUT);
 }
 
 /* A write timeout has occurred. Process the after effects. */
@@ -100,7 +100,7 @@ static void dccp_retransmit_timer(struct sock *sk)
 	 * total number of retransmissions of clones of original packets.
 	 */
 	if (icsk->icsk_retransmits == 0)
-		DCCP_INC_STATS_BH(DCCP_MIB_TIMEOUTS);
+		__DCCP_INC_STATS(DCCP_MIB_TIMEOUTS);
 
 	if (dccp_retransmit_skb(sk) != 0) {
 		/*
-- 
2.8.0.rc3.226.g39d4020
