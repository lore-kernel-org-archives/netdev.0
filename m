From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] vxlan: hide unused local variable
Date: Mon,  7 Nov 2016 22:09:07 +0100
Message-ID: <20161107211017.857340-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        pravin shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A bugfix introduced a harmless warning in v4.9-rc4:

drivers/net/vxlan.c: In function 'vxlan_group_used':
drivers/net/vxlan.c:947:21: error: unused variable 'sock6' [-Werror=unused-variable]

This hides the variable inside of the same #ifdef that is
around its user. The extraneous initialization is removed
at the same time, it was accidentally introduced in the
same commit.

Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/vxlan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index cb5cc7c03160..5264c1a49d86 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -944,7 +944,9 @@ static bool vxlan_group_used(struct vxlan_net *vn, struct vxlan_dev *dev)
 {
 	struct vxlan_dev *vxlan;
 	struct vxlan_sock *sock4;
-	struct vxlan_sock *sock6 = NULL;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct vxlan_sock *sock6;
+#endif
 	unsigned short family = dev->default_dst.remote_ip.sa.sa_family;
 
 	sock4 = rtnl_dereference(dev->vn4_sock);
-- 
2.9.0
