From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 05/11] batman-adv: use unregister_netdevice() when softif_create fails
Date: Mon, 12 Dec 2011 19:31:49 +0800
Message-ID: <1323689516-24427-6-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm24-vm5.bullet.mail.ukl.yahoo.com ([217.146.176.179]:42264
	"HELO nm24-vm5.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752131Ab1LLLck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:40 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

When entering softif_create(), the rtnl lock has already been acquired
by store_mesh_iface().
(store_mesh_iface() -> hardif_enable_interface() -> softif_create)

In case of an error, we should therefore call unregister_netdevice()
instead of unregister_netdev().

unregister_netdev() tries to acquire the rtnl lock itself and deadlocks
in this situation. unregister_netdevice() assumes that the rtnl lock
is already been held.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 45297c8..987c75a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -874,7 +874,7 @@ unreg_debugfs:
 unreg_sysfs:
 	sysfs_del_meshif(soft_iface);
 unreg_soft_iface:
-	unregister_netdev(soft_iface);
+	unregister_netdevice(soft_iface);
 	return NULL;
 
 free_soft_iface:
-- 
1.7.5.4
