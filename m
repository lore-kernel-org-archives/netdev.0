From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 1/2] vxlan: remove vxlan_group_used in vxlan_open
Date: Thu, 5 Dec 2013 17:01:35 +0800
Message-ID: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab3LEJPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 04:15:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vxlan_open, vxlan_group_used always returns true,
because the state of the vxlan deivces which we want
to open has alreay been running. and it has already
in vxlan_list.

Since ip_mc_join_group takes care of the reference
problem. we can remove vxlan_group_used here, let
ip_mc_join_group resolve the reference problem.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/vxlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0358c07..8c40254 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1943,8 +1943,7 @@ static int vxlan_open(struct net_device *dev)
 	if (!vs)
 		return -ENOTCONN;
 
-	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
-	    vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
+	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->igmp_join);
-- 
1.8.3.1
