From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/17] [IPV4]: Consolidate masq_inet_event and masq_device_event.
Date: Wed,  6 Feb 2008 13:53:23 +0300
Message-ID: <1202295217-22769-3-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:52557 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758059AbYBFKxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:14 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They do exactly the same job.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/netfilter/ipt_MASQUERADE.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index d80fee8..313b3fc 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -139,18 +139,8 @@ static int masq_inet_event(struct notifier_block *this,
 			   unsigned long event,
 			   void *ptr)
 {
-	const struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
-
-	if (event == NETDEV_DOWN) {
-		/* IP address was deleted.  Search entire table for
-		   conntracks which were associated with that device,
-		   and forget them. */
-		NF_CT_ASSERT(dev->ifindex != 0);
-
-		nf_ct_iterate_cleanup(device_cmp, (void *)(long)dev->ifindex);
-	}
-
-	return NOTIFY_DONE;
+	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
+	return masq_device_event(this, event, dev);
 }
 
 static struct notifier_block masq_dev_notifier = {
-- 
1.5.3.rc5

