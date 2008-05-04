From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][ATM]: Bad locking on br2684_devs modifications.
Date: Sun, 04 May 2008 11:39:00 +0400
Message-ID: <481D6814.6050801@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43774 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbYEDHlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 03:41:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The list_del happens under read-locked devs_lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/atm/br2684.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 3a74ff8..13858e2 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -346,9 +346,9 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 		/* skb==NULL means VCC is being destroyed */
 		br2684_close_vcc(brvcc);
 		if (list_empty(&brdev->brvccs)) {
-			read_lock(&devs_lock);
+			write_lock_irq(&devs_lock);
 			list_del(&brdev->br2684_devs);
-			read_unlock(&devs_lock);
+			write_unlock_irq(&devs_lock);
 			unregister_netdev(net_dev);
 		}
 		return;
-- 
1.5.3.4

