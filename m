From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] tun: Turn tun_flow_init() into void fn
Date: Tue, 11 Jun 2013 17:01:08 +0400
Message-ID: <51B71F94.6020507@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7758 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab3FKNBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 09:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This routine doesn't fail since 9fdc6bef (tuntap: dont use a private kmem_cache)
so it makes sense to compact the code a little bit.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 89776c5..544021e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -841,7 +841,7 @@ static const struct net_device_ops tap_netdev_ops = {
 #endif
 };
 
-static int tun_flow_init(struct tun_struct *tun)
+static void tun_flow_init(struct tun_struct *tun)
 {
 	int i;
 
@@ -852,8 +852,6 @@ static int tun_flow_init(struct tun_struct *tun)
 	setup_timer(&tun->flow_gc_timer, tun_flow_cleanup, (unsigned long)tun);
 	mod_timer(&tun->flow_gc_timer,
 		  round_jiffies_up(jiffies + tun->ageing_time));
-
-	return 0;
 }
 
 static void tun_flow_uninit(struct tun_struct *tun)
@@ -1659,10 +1657,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto err_free_dev;
 
 		tun_net_init(dev);
-
-		err = tun_flow_init(tun);
-		if (err < 0)
-			goto err_free_dev;
+		tun_flow_init(tun);
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 			TUN_USER_FEATURES;
