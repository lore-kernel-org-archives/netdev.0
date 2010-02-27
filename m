From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: [PATCH net-next-2.6 1/2] mq: support for bonding
Date: Sat, 27 Feb 2010 16:27:40 +0300
Message-ID: <310461267277260@webmail48.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward12.mail.yandex.net ([95.108.130.94]:48587 "EHLO
	forward12.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968299Ab0B0N1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 08:27:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Make bonding driver multiqueue aware.

Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru> 

---

 drivers/net/bonding/bond_main.c |    5 +++--
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 430c022..ea4ff33 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4928,8 +4928,9 @@ int bond_create(struct net *net, const char *name)
 
 	rtnl_lock();
 
-	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev = alloc_netdev_mq(sizeof(struct bonding), name ? name : "",
+				bond_setup,
+				min_t(u32, BOND_MAX_TX_QUEUES, num_online_cpus()));
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		res = -ENOMEM;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 257a7a4..4a6cfb4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -29,6 +29,7 @@
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 #define BOND_MAX_ARP_TARGETS	16
+#define BOND_MAX_TX_QUEUES	8 
 
 #define IS_UP(dev)					   \
 	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \

---

-- 
wbr, Oleg.
