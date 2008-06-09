From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/macsonic.c: make functions static
Date: Tue, 10 Jun 2008 01:23:47 +0300
Message-ID: <20080609222347.GR1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:54001 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760259AbYFIWYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:24:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the following needlessly global functions static:
- macsonic_init()
- mac_onboard_sonic_ethernet_addr()
- mac_onboard_sonic_probe()
- mac_nubus_sonic_ethernet_addr()
- macsonic_ident()
- mac_nubus_sonic_probe()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/macsonic.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

f9b145f054e5cee5822cf0ffb7cb3eae49ba104c diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index b267161..e64c208 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -83,9 +83,6 @@ static unsigned int sonic_debug = 1;
 
 static int sonic_version_printed;
 
-extern int mac_onboard_sonic_probe(struct net_device* dev);
-extern int mac_nubus_sonic_probe(struct net_device* dev);
-
 /* For onboard SONIC */
 #define ONBOARD_SONIC_REGISTERS	0x50F0A000
 #define ONBOARD_SONIC_PROM_BASE	0x50f08000
@@ -170,7 +167,7 @@ static int macsonic_close(struct net_device* dev)
 	return err;
 }
 
-int __init macsonic_init(struct net_device* dev)
+static int __init macsonic_init(struct net_device *dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
 
@@ -218,7 +215,7 @@ int __init macsonic_init(struct net_device* dev)
 	return 0;
 }
 
-int __init mac_onboard_sonic_ethernet_addr(struct net_device* dev)
+static int __init mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	const int prom_addr = ONBOARD_SONIC_PROM_BASE;
@@ -284,7 +281,7 @@ int __init mac_onboard_sonic_ethernet_addr(struct net_device* dev)
 	} else return 0;
 }
 
-int __init mac_onboard_sonic_probe(struct net_device* dev)
+static int __init mac_onboard_sonic_probe(struct net_device *dev)
 {
 	/* Bwahahaha */
 	static int once_is_more_than_enough;
@@ -405,9 +402,9 @@ int __init mac_onboard_sonic_probe(struct net_device* dev)
 	return macsonic_init(dev);
 }
 
-int __init mac_nubus_sonic_ethernet_addr(struct net_device* dev,
-					 unsigned long prom_addr,
-					 int id)
+static int __init mac_nubus_sonic_ethernet_addr(struct net_device *dev,
+						unsigned long prom_addr,
+						int id)
 {
 	int i;
 	for(i = 0; i < 6; i++)
@@ -420,7 +417,7 @@ int __init mac_nubus_sonic_ethernet_addr(struct net_device* dev,
 	return 0;
 }
 
-int __init macsonic_ident(struct nubus_dev* ndev)
+static int __init macsonic_ident(struct nubus_dev *ndev)
 {
 	if (ndev->dr_hw == NUBUS_DRHW_ASANTE_LC &&
 	    ndev->dr_sw == NUBUS_DRSW_SONIC_LC)
@@ -445,7 +442,7 @@ int __init macsonic_ident(struct nubus_dev* ndev)
 	return -1;
 }
 
-int __init mac_nubus_sonic_probe(struct net_device* dev)
+static int __init mac_nubus_sonic_probe(struct net_device *dev)
 {
 	static int slots;
 	struct nubus_dev* ndev = NULL;

