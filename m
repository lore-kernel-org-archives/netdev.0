From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] socket: sk_filter minor cleanups
Date: Mon, 31 Mar 2008 17:47:09 -0700
Message-ID: <20080401004724.454784783@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755414AbYDACbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:36 -0400
Content-Disposition: inline; filename=sk-filter-cleanup
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor style cleanups:
  * Move __KERNEL__ definitions to one place in filter.h
  * Use const for sk_filter_len
  * Line wrapping
  * Put EXPORT_SYMBOL next to function definition

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/linux/filter.h	2008-03-31 10:23:28.000000000 -0700
+++ b/include/linux/filter.h	2008-03-31 10:24:40.000000000 -0700
@@ -37,21 +37,6 @@ struct sock_fprog	/* Required for SO_ATT
 	struct sock_filter __user *filter;
 };
 
-#ifdef __KERNEL__
-struct sk_filter
-{
-	atomic_t		refcnt;
-	unsigned int         	len;	/* Number of filter blocks */
-	struct rcu_head		rcu;
-	struct sock_filter     	insns[0];
-};
-
-static inline unsigned int sk_filter_len(struct sk_filter *fp)
-{
-	return fp->len*sizeof(struct sock_filter) + sizeof(*fp);
-}
-#endif
-
 /*
  * Instruction classes
  */
@@ -141,10 +126,24 @@ static inline unsigned int sk_filter_len
 #define SKF_LL_OFF    (-0x200000)
 
 #ifdef __KERNEL__
+struct sk_filter
+{
+	atomic_t		refcnt;
+	unsigned int         	len;	/* Number of filter blocks */
+	struct rcu_head		rcu;
+	struct sock_filter     	insns[0];
+};
+
+static inline unsigned int sk_filter_len(const struct sk_filter *fp)
+{
+	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
+}
+
 struct sk_buff;
 struct sock;
 
-extern unsigned int sk_run_filter(struct sk_buff *skb, struct sock_filter *filter, int flen);
+extern unsigned int sk_run_filter(struct sk_buff *skb,
+				  struct sock_filter *filter, int flen);
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
 extern int sk_chk_filter(struct sock_filter *filter, int flen);
--- a/net/core/filter.c	2008-03-31 10:24:56.000000000 -0700
+++ b/net/core/filter.c	2008-03-31 10:25:29.000000000 -0700
@@ -275,6 +275,7 @@ load_b:
 
 	return 0;
 }
+EXPORT_SYMBOL(sk_run_filter);
 
 /**
  *	sk_chk_filter - verify socket filter code
@@ -385,6 +386,7 @@ int sk_chk_filter(struct sock_filter *fi
 
 	return (BPF_CLASS(filter[flen - 1].code) == BPF_RET) ? 0 : -EINVAL;
 }
+EXPORT_SYMBOL(sk_chk_filter);
 
 /**
  * 	sk_filter_rcu_release: Release a socket filter by rcu_head
@@ -467,6 +469,3 @@ int sk_detach_filter(struct sock *sk)
 	rcu_read_unlock_bh();
 	return ret;
 }
-
-EXPORT_SYMBOL(sk_chk_filter);
-EXPORT_SYMBOL(sk_run_filter);

-- 

