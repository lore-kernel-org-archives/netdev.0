From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [net-next] net/ipv4/ip_vti.c: Fix __rcu warnings detected by
 sparse.
Date: Mon, 23 Jul 2012 10:52:04 -0700
Message-ID: <20120723175204.GA2762@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57104 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754473Ab2GWRxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 13:53:02 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 1F16514101E0
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 10:53:00 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1McTfZV7IC3d for <netdev@vger.kernel.org>;
	Mon, 23 Jul 2012 10:52:55 -0700 (PDT)
Received: from localhost (eng-dhcp-126.vyatta.com [10.3.0.126])
	by mail.vyatta.com (Postfix) with ESMTP id C379914101DE
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 10:52:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



With CONFIG_SPARSE_RCU_POINTER=y sparse identified references which did not
specificy __rcu in ip_vti.c

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>

---
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index c41b5c3..3511ffb 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -55,7 +55,7 @@ struct vti_net {
 	struct ip_tunnel __rcu *tunnels_r[HASH_SIZE];
 	struct ip_tunnel __rcu *tunnels_l[HASH_SIZE];
 	struct ip_tunnel __rcu *tunnels_wc[1];
-	struct ip_tunnel **tunnels[4];
+	struct ip_tunnel __rcu **tunnels[4];
 
 	struct net_device *fb_tunnel_dev;
 };
@@ -160,8 +160,8 @@ static struct ip_tunnel *vti_tunnel_lookup(struct net *net,
 	return NULL;
 }
 
-static struct ip_tunnel **__vti_bucket(struct vti_net *ipn,
-				       struct ip_tunnel_parm *parms)
+static struct ip_tunnel __rcu **__vti_bucket(struct vti_net *ipn,
+					     struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
@@ -179,8 +179,8 @@ static struct ip_tunnel **__vti_bucket(struct vti_net *ipn,
 	return &ipn->tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **vti_bucket(struct vti_net *ipn,
-					    struct ip_tunnel *t)
+static inline struct ip_tunnel __rcu **vti_bucket(struct vti_net *ipn,
+						  struct ip_tunnel *t)
 {
 	return __vti_bucket(ipn, &t->parms);
 }
