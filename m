From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 17/17 net-2.6.26] [NETNS]: Process inet_select_addr inside a namespace.
Date: Tue, 19 Feb 2008 10:31:37 +0300
Message-ID: <1203406297-32725-17-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:54484 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755426AbYBSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:16 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The context is available from a network device passed in.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index aa23d10..033670d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -871,6 +871,7 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
 	struct in_device *in_dev;
+	struct net *net = dev->nd_net;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -899,7 +900,7 @@ no_in_dev:
 	 */
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if ((in_dev = __in_dev_get_rcu(dev)) == NULL)
 			continue;
 
-- 
1.5.3.rc5

