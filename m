From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 04/27] drivers/net: fix sparse warnings: make symbols static
Date: Mon, 22 Dec 2008 20:15:26 +0100
Message-ID: <20081222191526.11807.12081.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754976AbYLVTPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:15:32 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/3c523.c:350:6: warning: symbol 'alloc586' was not declared. Should it be static?
  drivers/net/cs89x0.c:1029:14: warning: symbol 'reset_chip' was not declared. Should it be static?
  drivers/net/eepro.c:1399:1: warning: symbol 'read_eeprom' was not declared. Should it be static?
  drivers/net/plip.c:1020:5: warning: symbol 'plip_hard_header_cache' was not declared. Should it be static?
  drivers/net/s2io.c:5116:6: warning: symbol 'do_s2io_store_unicast_mc' was not declared. Should it be static?
  drivers/net/smc9194.c:767:12: warning: symbol 'smc_findirq' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/3c523.c   |    2 +-
 drivers/net/cs89x0.c  |    2 +-
 drivers/net/eepro.c   |    2 +-
 drivers/net/plip.c    |    4 ++--
 drivers/net/s2io.c    |    2 +-
 drivers/net/smc9194.c |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index d9c9481..ff41e1f 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -347,7 +347,7 @@ static int __init check586(struct net_device *dev, unsigned long where, unsigned
  * set iscp at the right place, called by elmc_probe and open586.
  */
 
-void alloc586(struct net_device *dev)
+static void alloc586(struct net_device *dev)
 {
 	struct priv *p = netdev_priv(dev);
 
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index f0edb8b..ff64976 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1026,7 +1026,7 @@ skip_this_frame:
 
 #endif	/* ALLOW_DMA */
 
-void  __init reset_chip(struct net_device *dev)
+static void __init reset_chip(struct net_device *dev)
 {
 #if !defined(CONFIG_MACH_MX31ADS)
 #if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01)
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 0a98461..e187c88 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1395,7 +1395,7 @@ set_multicast_list(struct net_device *dev)
 #define eeprom_delay() { udelay(40); }
 #define EE_READ_CMD (6 << 6)
 
-int
+static int
 read_eeprom(int ioaddr, int location, struct net_device *dev)
 {
 	int i;
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index ed8582e..0c46d60 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1017,8 +1017,8 @@ plip_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return ret;
 }
 
-int plip_hard_header_cache(const struct neighbour *neigh,
-                           struct hh_cache *hh)
+static int plip_hard_header_cache(const struct neighbour *neigh,
+				  struct hh_cache *hh)
 {
 	int ret;
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 1b489df..4f6a452 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5113,7 +5113,7 @@ static void s2io_set_multicast(struct net_device *dev)
 /* read from CAM unicast & multicast addresses and store it in
  * def_mac_addr structure
  */
-void do_s2io_store_unicast_mc(struct s2io_nic *sp)
+static void do_s2io_store_unicast_mc(struct s2io_nic *sp)
 {
 	int offset;
 	u64 mac_addr = 0x0;
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index e7cc80f..18d653b 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -764,7 +764,7 @@ out:
  . interrupt, so an auto-detect routine can detect it, and find the IRQ,
  ------------------------------------------------------------------------
 */
-int __init smc_findirq( int ioaddr )
+static int __init smc_findirq(int ioaddr)
 {
 #ifndef NO_AUTOPROBE
 	int	timeout = 20;

