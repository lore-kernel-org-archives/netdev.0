From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/16] batman-adv: call unregister_netdev() to have it handle the locking for us
Date: Sat, 22 Mar 2014 09:56:06 +0100
Message-ID: <1395478576-10999-7-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24555 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaCVI4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:55 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index db3e467..633e9d6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -652,10 +652,7 @@ static void batadv_softif_destroy_finish(struct work_struct *work)
 	}
 
 	batadv_sysfs_del_meshif(soft_iface);
-
-	rtnl_lock();
-	unregister_netdevice(soft_iface);
-	rtnl_unlock();
+	unregister_netdev(soft_iface);
 }
 
 /**
-- 
1.8.3.2
