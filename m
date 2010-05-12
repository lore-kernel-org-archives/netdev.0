From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] pfkey: add severity to printk
Date: Wed, 12 May 2010 09:37:07 -0700
Message-ID: <20100512163719.580801468@vyatta.com>
References: <20100512163704.780058547@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36022 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756528Ab0ELQlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 12:41:21 -0400
Content-Disposition: inline; filename=key-message.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put severity level on pfkey printk messages

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/key/af_key.c	2010-05-11 21:08:49.617719992 -0700
+++ b/net/key/af_key.c	2010-05-11 21:12:46.399325172 -0700
@@ -99,7 +99,7 @@ static void pfkey_sock_destruct(struct s
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive pfkey socket: %p\n", sk);
+		pr_err("Attempt to release alive pfkey socket: %p\n", sk);
 		return;
 	}
 
@@ -1402,7 +1402,7 @@ static inline int event2poltype(int even
 	case XFRM_MSG_POLEXPIRE:
 	//	return SADB_X_SPDEXPIRE;
 	default:
-		printk("pfkey: Unknown policy event %d\n", event);
+		pr_err("pfkey: Unknown policy event %d\n", event);
 		break;
 	}
 
@@ -1421,7 +1421,7 @@ static inline int event2keytype(int even
 	case XFRM_MSG_EXPIRE:
 		return SADB_EXPIRE;
 	default:
-		printk("pfkey: Unknown SA event %d\n", event);
+		pr_err("pfkey: Unknown SA event %d\n", event);
 		break;
 	}
 
@@ -2969,7 +2969,7 @@ static int pfkey_send_notify(struct xfrm
 	case XFRM_MSG_NEWAE: /* not yet supported */
 		break;
 	default:
-		printk("pfkey: Unknown SA event %d\n", c->event);
+		pr_err("pfkey: Unknown SA event %d\n", c->event);
 		break;
 	}
 
@@ -2993,7 +2993,7 @@ static int pfkey_send_policy_notify(stru
 			break;
 		return key_notify_policy_flush(c);
 	default:
-		printk("pfkey: Unknown policy event %d\n", c->event);
+		pr_err("pfkey: Unknown policy event %d\n", c->event);
 		break;
 	}
 


