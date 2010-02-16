From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 22/62: xtables: CONFIG_COMPAT redux
Date: Tue, 16 Feb 2010 15:55:50 +0100 (MET)
Message-ID: <20100216145547.2796.21728.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932417Ab0BPOzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:51 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c30f540b63047437ffa894b5353216410c480d1a
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Feb 2 15:03:24 2010 +0100

    netfilter: xtables: CONFIG_COMPAT redux
    
    Ifdef out
    	struct nf_sockopt_ops::compat_set
    	struct nf_sockopt_ops::compat_get
    	struct xt_match::compat_from_user
    	struct xt_match::compat_to_user
    	struct xt_match::compatsize
    to make structures smaller on COMPAT=n kernels.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 48c5496..78f33d2 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -114,15 +114,17 @@ struct nf_sockopt_ops {
 	int set_optmin;
 	int set_optmax;
 	int (*set)(struct sock *sk, int optval, void __user *user, unsigned int len);
+#ifdef CONFIG_COMPAT
 	int (*compat_set)(struct sock *sk, int optval,
 			void __user *user, unsigned int len);
-
+#endif
 	int get_optmin;
 	int get_optmax;
 	int (*get)(struct sock *sk, int optval, void __user *user, int *len);
+#ifdef CONFIG_COMPAT
 	int (*compat_get)(struct sock *sk, int optval,
 			void __user *user, int *len);
-
+#endif
 	/* Use the module struct to lock set/get code in place */
 	struct module *owner;
 };
@@ -222,11 +224,12 @@ int nf_setsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
 		  unsigned int len);
 int nf_getsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
 		  int *len);
-
+#ifdef CONFIG_COMPAT
 int compat_nf_setsockopt(struct sock *sk, u_int8_t pf, int optval,
 		char __user *opt, unsigned int len);
 int compat_nf_getsockopt(struct sock *sk, u_int8_t pf, int optval,
 		char __user *opt, int *len);
+#endif
 
 /* Call this before modifying an existing packet: ensures it is
    modifiable and linear to the point you care about (writable_len).
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 3caf5e1..026eb78 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -283,11 +283,11 @@ struct xt_match {
 
 	/* Called when entry of this type deleted. */
 	void (*destroy)(const struct xt_mtdtor_param *);
-
+#ifdef CONFIG_COMPAT
 	/* Called when userspace align differs from kernel space one */
 	void (*compat_from_user)(void *dst, void *src);
 	int (*compat_to_user)(void __user *dst, void *src);
-
+#endif
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
 
@@ -296,7 +296,9 @@ struct xt_match {
 
 	const char *table;
 	unsigned int matchsize;
+#ifdef CONFIG_COMPAT
 	unsigned int compatsize;
+#endif
 	unsigned int hooks;
 	unsigned short proto;
 
@@ -323,17 +325,19 @@ struct xt_target {
 
 	/* Called when entry of this type deleted. */
 	void (*destroy)(const struct xt_tgdtor_param *);
-
+#ifdef CONFIG_COMPAT
 	/* Called when userspace align differs from kernel space one */
 	void (*compat_from_user)(void *dst, void *src);
 	int (*compat_to_user)(void __user *dst, void *src);
-
+#endif
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
 
 	const char *table;
 	unsigned int targetsize;
+#ifdef CONFIG_COMPAT
 	unsigned int compatsize;
+#endif
 	unsigned int hooks;
 	unsigned short proto;
 
