From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/25 DO NOT APPLY] netns nf: enable netfilter in netns
Date: Sun, 22 Jun 2008 05:00:05 +0400
Message-ID: <20080622010005.GB5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:4456 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbYFVBEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 21:04:16 -0400
Received: by ug-out-1314.google.com with SMTP id h2so243818ugf.16
        for <netdev@vger.kernel.org>; Sat, 21 Jun 2008 18:04:12 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch allows to manipulate netfilter rules and entry into actual filtering
code. Noticeable chunks of netfilter are still not netns-ready, so patch
is for testing only.
---

 net/netfilter/core.c       |    8 --------
 net/netfilter/nf_sockopt.c |    3 ---
 2 files changed, 11 deletions(-)

--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -165,14 +165,6 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 	unsigned int verdict;
 	int ret = 0;
 
-#ifdef CONFIG_NET_NS
-	struct net *net;
-
-	net = indev == NULL ? dev_net(outdev) : dev_net(indev);
-	if (net != &init_net)
-		return 1;
-#endif
-
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -65,9 +65,6 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, int pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (sock_net(sk) != &init_net)
-		return ERR_PTR(-ENOPROTOOPT);
-
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
 		return ERR_PTR(-EINTR);
 
-- 
1.5.4.5


