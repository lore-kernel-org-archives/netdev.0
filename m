From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] vti: remove duplicated code to fix a memory leak
Date: Sat, 29 Jun 2013 13:00:57 +0800
Message-ID: <1372482057-12412-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814Ab3F2FBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 01:01:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

vti module allocates dev->tstats twice: in vti_fb_tunnel_init()
and in vti_tunnel_init(), this lead to a memory leak of 
dev->tstats.

Just remove the duplicated operations in vti_fb_tunnel_init().

(candidate for -stable)

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index c118f6b..17cc0ff 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -606,17 +606,10 @@ static int __net_init vti_fb_tunnel_init(struct net_device *dev)
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct vti_net *ipn = net_generic(dev_net(dev), vti_net_id);
 
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
-
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_IPIP;
 	iph->ihl		= 5;
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
 	dev_hold(dev);
 	rcu_assign_pointer(ipn->tunnels_wc[0], tunnel);
 	return 0;
