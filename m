From: Fabian Frederick <fabf@skynet.be>
Subject: [RFC 1/1] drivers/net: fix eisa_driver probe section mismatch
Date: Tue,  8 Dec 2015 18:36:25 +0100
Message-ID: <1449596185-5339-1-git-send-email-fabf@skynet.be>
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabian Frederick <fabf@skynet.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay116.isp.belgacom.be ([195.238.20.143]:20205 "EHLO
	mailrelay116.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410AbbLHRgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:36:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some eisa_driver structures use __init probe functions which generates
a warning and could crash if function is called after being deleted.
I guess we can remove __init from the 5 functions below in
separate patches ?

__init:
hp100_eisa_probe()
vortex_eisa_probe()
el3_eisa_probe()
sim710_eisa_probe()
de4x5_eisa_probe()

__maybe_unused:
dfx_dev_register()

default:
advansys_eisa_probe()
aic7770_probe()
aha1740_probe()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/3com/3c509.c      | 2 +-
 drivers/net/ethernet/3com/3c59x.c      | 2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
 drivers/net/ethernet/hp/hp100.c        | 2 +-
 drivers/scsi/sim710.c                  | 3 +--
 5 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 4547a1b..aadaab5 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -562,7 +562,7 @@ static void el3_common_remove (struct net_device *dev)
 }
 
 #ifdef CONFIG_EISA
-static int __init el3_eisa_probe (struct device *device)
+static int el3_eisa_probe (struct device *device)
 {
 	short i;
 	int ioaddr, irq, if_port;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 2839af0..1c5f3b2 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -907,7 +907,7 @@ static struct eisa_device_id vortex_eisa_ids[] = {
 };
 MODULE_DEVICE_TABLE(eisa, vortex_eisa_ids);
 
-static int __init vortex_eisa_probe(struct device *device)
+static int vortex_eisa_probe(struct device *device)
 {
 	void __iomem *ioaddr;
 	struct eisa_device *edev;
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 8966f31..13ee4c7 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1990,7 +1990,7 @@ SetMulticastFilter(struct net_device *dev)
 
 static u_char de4x5_irq[] = EISA_ALLOWED_IRQ_LIST;
 
-static int __init de4x5_eisa_probe (struct device *gendev)
+static int de4x5_eisa_probe (struct device *gendev)
 {
 	struct eisa_device *edev;
 	u_long iobase;
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index ae6e30d..daa9b50 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -2843,7 +2843,7 @@ static void cleanup_dev(struct net_device *d)
 }
 
 #ifdef CONFIG_EISA
-static int __init hp100_eisa_probe (struct device *gendev)
+static int hp100_eisa_probe (struct device *gendev)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
 	struct eisa_device *edev = to_eisa_device(gendev);
diff --git a/drivers/scsi/sim710.c b/drivers/scsi/sim710.c
index 3b3b56f..82ed998 100644
--- a/drivers/scsi/sim710.c
+++ b/drivers/scsi/sim710.c
@@ -176,8 +176,7 @@ static struct eisa_device_id sim710_eisa_ids[] = {
 };
 MODULE_DEVICE_TABLE(eisa, sim710_eisa_ids);
 
-static __init int
-sim710_eisa_probe(struct device *dev)
+static int sim710_eisa_probe(struct device *dev)
 {
 	struct eisa_device *edev = to_eisa_device(dev);
 	unsigned long io_addr = edev->base_addr;
-- 
2.1.4
