From: Stafford Horne <shorne@gmail.com>
Subject: [PATCH] 3c59x: Ensure to apply the expires time
Date: Sun, 28 Feb 2016 16:49:29 +0900
Message-ID: <1456645769-2959-1-git-send-email-shorne@gmail.com>
References: <CA+5yK5GF4mCZe8xeDwnj7QOz1m2xz2HOVkO59wdsBktZ3kmzYA@mail.gmail.com>
Cc: shorne@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, amitoj1606@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35772 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcB1HuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 02:50:19 -0500
In-Reply-To: <CA+5yK5GF4mCZe8xeDwnj7QOz1m2xz2HOVkO59wdsBktZ3kmzYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 5b6490def9168af6a ("3c59x: Use setup_timer()") Amitoj
removed add_timer which sets up the epires timer.  In this patch
the behavior is restore but it uses mod_timer which is a bit more
compact.

Signed-off-by: Stafford Horne <shorne@gmail.com>
---

I think a patch like this will help restore the behavior. Also, 
its small cleanup since we dont need to do separate set to expire
and call to add_timer. But thats a style preference. 

 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index c377607..7b881ed 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1602,7 +1602,7 @@ vortex_up(struct net_device *dev)
 	}
 
 	setup_timer(&vp->timer, vortex_timer, (unsigned long)dev);
-	vp->timer.expires = RUN_AT(media_tbl[dev->if_port].wait);
+	mod_timer(&vp->timer, RUN_AT(media_tbl[dev->if_port].wait));
 	setup_timer(&vp->rx_oom_timer, rx_oom_timer, (unsigned long)dev);
 
 	if (vortex_debug > 1)
-- 
2.5.0
