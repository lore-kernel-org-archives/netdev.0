From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] vxlan: remove unused variable saddr in neigh_reduce
Date: Mon, 20 Feb 2017 08:41:16 -0800
Message-ID: <1487608876-4873-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34355 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdBTQlX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:41:23 -0500
Received: by mail-pg0-f53.google.com with SMTP id 1so2943514pgi.1
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 08:41:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

silences the below warning:
    drivers/net/vxlan.c: In function ‘neigh_reduce’:
    drivers/net/vxlan.c:1599:25: warning: variable ‘saddr’ set but not used
    [-Wunused-but-set-variable]

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/vxlan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 87f63f6..556953f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1596,7 +1596,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct nd_msg *msg;
 	const struct ipv6hdr *iphdr;
-	const struct in6_addr *saddr, *daddr;
+	const struct in6_addr *daddr;
 	struct neighbour *n;
 	struct inet6_dev *in6_dev;
 
@@ -1605,7 +1605,6 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 		goto out;
 
 	iphdr = ipv6_hdr(skb);
-	saddr = &iphdr->saddr;
 	daddr = &iphdr->daddr;
 
 	msg = (struct nd_msg *)skb_transport_header(skb);
-- 
1.7.10.4
