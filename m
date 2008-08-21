From: adobriyan@gmail.com
Subject: [PATCH 33/38] netns nat: fix ipt_MASQUERADE in netns
Date: Fri, 22 Aug 2008 02:09:32 +0400
Message-ID: <20080821220932.GG31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:39320 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759121AbYHUWIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:08:07 -0400
Received: by yx-out-2324.google.com with SMTP id 8so103025yxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:08:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/ipt_MASQUERADE.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -120,16 +120,13 @@ static int masq_device_event(struct notifier_block *this,
 {
 	const struct net_device *dev = ptr;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
 	if (event == NETDEV_DOWN) {
 		/* Device was downed.  Search entire table for
 		   conntracks which were associated with that device,
 		   and forget them. */
 		NF_CT_ASSERT(dev->ifindex != 0);
 
-		nf_ct_iterate_cleanup(&init_net, device_cmp, (void *)(long)dev->ifindex);
+		nf_ct_iterate_cleanup(dev_net(dev), device_cmp, (void *)(long)dev->ifindex);
 	}
 
 	return NOTIFY_DONE;
-- 
1.5.6.3


