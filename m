From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] vxlan: simplify if clause in dev_close
Date: Mon, 23 Mar 2015 16:23:12 -0300
Message-ID: <e902446603472e4ec42118b60f90444b1755501e.1427137720.git.marcelo.leitner@gmail.com>
References: <20150323155612.GD24038@mwanda>
Cc: dan.carpenter@oracle.com, kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150323155612.GD24038@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Carpenter's static checker warned that in vxlan_stop we are checking
if 'vs' can be NULL while later we simply derreference it.

As after commit 56ef9c909b40 ("vxlan: Move socket initialization to
within rtnl scope") 'vs' just cannot be NULL in vxlan_stop() anymore, as
the interface won't go up if the socket initialization fails. So we are
good to just remove the check and make it consistent.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 94603ee742eaea4443d8a3de005a622961d1ce4f..6080f8e7b0cd893c3fc05b288a16e3b383f5a14f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2254,7 +2254,7 @@ static int vxlan_stop(struct net_device *dev)
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	int ret = 0;
 
-	if (vs && vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
+	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
 	    !vxlan_group_used(vn, vxlan)) {
 		ret = vxlan_igmp_leave(vxlan);
 		if (ret)
-- 
2.3.3

