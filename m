From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: [net-next-2.6 PATCH] Multiqueue support for bonding devices
Date: Tue, 23 Feb 2010 18:16:28 +0300
Message-ID: <597071266938188@webmail90.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward15.mail.yandex.net ([95.108.130.119]:52386 "EHLO
	forward15.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab0BWPQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 10:16:30 -0500
Received: from webmail90.yandex.ru (webmail90.yandex.ru [77.88.47.164])
	by forward15.mail.yandex.net (Yandex) with ESMTP id A7D09C0A6A
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 18:16:28 +0300 (MSK)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail90.yandex.ru (Yandex) with ESMTP id 8F6CB4540F8
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 18:16:28 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Make bonding driver multiqueue aware.

Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1787e3c..f54f590 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4928,8 +4928,9 @@ int bond_create(struct net *net, const char *name)

        rtnl_lock();

-       bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-                               bond_setup);
+       bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
+                               bond_setup,
+                               min_t(u32, BOND_MAX_TX_QUEUES, num_online_cpus()));
        if (!bond_dev) {
                pr_err("%s: eek! can't alloc netdev!\n", name);
                res = -ENOMEM;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 257a7a4..eab3239 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -29,6 +29,7 @@
 #define DRV_DESCRIPTION        "Ethernet Channel Bonding Driver"

 #define BOND_MAX_ARP_TARGETS   16
+#define BOND_MAX_TX_QUEUES      8

 #define IS_UP(dev)                                        \
              ((((dev)->flags & IFF_UP) == IFF_UP)      && \
---

-- 
wbr, Oleg.
