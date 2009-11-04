From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netlabel: remove dev_put() calls
Date: Wed, 04 Nov 2009 21:03:53 +0100
Message-ID: <4AF1DE29.7010408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46047 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758076AbZKDUDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 15:03:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_get_by_name_rcu() to avoid dev_put() calls,
in sections already inside a rcu_read_lock()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlabel/netlabel_unlabeled.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index fb357f0..3dfe2ba 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -472,13 +472,12 @@ int netlbl_unlhsh_add(struct net *net,
 
 	rcu_read_lock();
 	if (dev_name != NULL) {
-		dev = dev_get_by_name(net, dev_name);
+		dev = dev_get_by_name_rcu(net, dev_name);
 		if (dev == NULL) {
 			ret_val = -ENODEV;
 			goto unlhsh_add_return;
 		}
 		ifindex = dev->ifindex;
-		dev_put(dev);
 		iface = netlbl_unlhsh_search_iface(ifindex);
 	} else {
 		ifindex = 0;
@@ -737,13 +736,12 @@ int netlbl_unlhsh_remove(struct net *net,
 
 	rcu_read_lock();
 	if (dev_name != NULL) {
-		dev = dev_get_by_name(net, dev_name);
+		dev = dev_get_by_name_rcu(net, dev_name);
 		if (dev == NULL) {
 			ret_val = -ENODEV;
 			goto unlhsh_remove_return;
 		}
 		iface = netlbl_unlhsh_search_iface(dev->ifindex);
-		dev_put(dev);
 	} else
 		iface = rcu_dereference(netlbl_unlhsh_def);
 	if (iface == NULL) {
