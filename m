From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/2][ATM]: Do not free already unregistered net device.
Date: Sun, 04 May 2008 11:37:43 +0400
Message-ID: <481D67C7.5050909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43760 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbYEDHk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 03:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both br2684_push and br2684_exit do so, but unregister_netdev()
releases the device itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/atm/br2684.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 1b22806..3a74ff8 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -350,7 +350,6 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			list_del(&brdev->br2684_devs);
 			read_unlock(&devs_lock);
 			unregister_netdev(net_dev);
-			free_netdev(net_dev);
 		}
 		return;
 	}
@@ -771,7 +770,6 @@ static void __exit br2684_exit(void)
 
 		list_del(&brdev->br2684_devs);
 		unregister_netdev(net_dev);
-		free_netdev(net_dev);
 	}
 }
 
-- 
1.5.3.4

