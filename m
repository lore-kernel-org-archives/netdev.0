From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 17/17] [NETNS]: Process inet_select_addr inside a namespace.
Date: Wed,  6 Feb 2008 13:53:37 +0300
Message-ID: <1202295217-22769-17-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:55053 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758829AbYBFKxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:53:16 -0500
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The context is available from a network device passed in.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index aa23d10..d06a4e6 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -871,12 +871,14 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
 	struct in_device *in_dev;
+	struct net *net;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (!in_dev)
 		goto no_in_dev;
 
+	net = dev->nd_net;
 	for_primary_ifa(in_dev) {
 		if (ifa->ifa_scope > scope)
 			continue;
@@ -899,7 +901,7 @@ no_in_dev:
 	 */
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if ((in_dev = __in_dev_get_rcu(dev)) == NULL)
 			continue;
 
-- 
1.5.3.rc5

