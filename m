From: Mark Bloch <markb@mellanox.com>
Subject: [net-next] vxlan: use a more suitable function when assigning NULL
Date: Wed,  7 Jun 2017 14:36:58 +0300
Message-ID: <1496835418-22723-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40089.outbound.protection.outlook.com ([40.107.4.89]:28000
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751476AbdFGLhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 07:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When stopping the vxlan interface we detach it from the socket.
Use RCU_INIT_POINTER() and not rcu_assign_pointer() to do so.

Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Mark Bloch <markb@mellanox.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a6b5052..7cb21a0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1077,10 +1077,10 @@ static void vxlan_sock_release(struct vxlan_dev *vxlan)
 #if IS_ENABLED(CONFIG_IPV6)
 	struct vxlan_sock *sock6 = rtnl_dereference(vxlan->vn6_sock);
 
-	rcu_assign_pointer(vxlan->vn6_sock, NULL);
+	RCU_INIT_POINTER(vxlan->vn6_sock, NULL);
 #endif
 
-	rcu_assign_pointer(vxlan->vn4_sock, NULL);
+	RCU_INIT_POINTER(vxlan->vn4_sock, NULL);
 	synchronize_net();
 
 	vxlan_vs_del_dev(vxlan);
-- 
1.8.4.3
