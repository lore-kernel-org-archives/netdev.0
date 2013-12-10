From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2 net-next 1/2] vxlan: remove vxlan_group_used in vxlan_open
Date: Tue, 10 Dec 2013 16:37:32 +0800
Message-ID: <1386664653-27082-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:13094 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755820Ab3LJIgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 03:36:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vxlan_open, vxlan_group_used always returns true,
because the state of the vxlan deivces which we want
to open has alreay been running. and it has already
in vxlan_list.

Since ip_mc_join_group takes care of the reference
of struct ip_mc_list. removing vxlan_group_used here
is safe.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
Change from v1:
 remove unused var vn.
 change changelog, remove the confused "reference problem".

 drivers/net/vxlan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0358c07..43dc9ee 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1935,7 +1935,6 @@ static void vxlan_uninit(struct net_device *dev)
 /* Start ageing timer and join group when device is brought up */
 static int vxlan_open(struct net_device *dev)
 {
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
@@ -1943,8 +1942,7 @@ static int vxlan_open(struct net_device *dev)
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
