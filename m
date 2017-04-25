From: gfree.wind@foxmail.com
Subject: [PATCH net] net: batman-adv: Fix possible memleaks when fail to register_netdevice
Date: Tue, 25 Apr 2017 20:03:20 +0800
Message-ID: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg298.qq.com ([184.105.67.102]:52940 "EHLO smtpbg298.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758708AbdDYMEE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 08:04:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Because the func batadv_softif_init_late allocate some resources and
it would be invoked in register_netdevice. So we need to invoke the
func batadv_softif_free instead of free_netdev to cleanup when fail
to register_netdevice.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/batman-adv/soft-interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d042c99..90bf990 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1011,7 +1011,7 @@ struct net_device *batadv_softif_create(struct net *net, const char *name)
 	if (ret < 0) {
 		pr_err("Unable to register the batman interface '%s': %i\n",
 		       name, ret);
-		free_netdev(soft_iface);
+		batadv_softif_free(soft_iface);
 		return NULL;
 	}
 
-- 
1.9.1
