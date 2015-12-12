From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] drivers/net: fix eisa_driver probe section mismatch
Date: Sat, 12 Dec 2015 18:24:38 +0100
Message-ID: <1449941078-15854-1-git-send-email-fabf@skynet.be>
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jaroslav Kysela <perex@perex.cz>, linux-parisc@vger.kernel.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some eisa_driver structures used __init probe functions which generates
a warning and could crash if function is called after being deleted.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2:
	-Remove scsi occurence for net-next(suggested by David S. Miller)
	-Fix checkpatch warnings(space prohibited between function name
	 and parenthesis).

 drivers/net/ethernet/3com/3c509.c      | 2 +-
 drivers/net/ethernet/3com/3c59x.c      | 2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
 drivers/net/ethernet/hp/hp100.c        | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 4547a1b..7677c74 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -562,7 +562,7 @@ static void el3_common_remove (struct net_device *dev)
 }
 
 #ifdef CONFIG_EISA
-static int __init el3_eisa_probe (struct device *device)
+static int el3_eisa_probe(struct device *device)
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
index 8966f31..3acde3b 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1990,7 +1990,7 @@ SetMulticastFilter(struct net_device *dev)
 
 static u_char de4x5_irq[] = EISA_ALLOWED_IRQ_LIST;
 
-static int __init de4x5_eisa_probe (struct device *gendev)
+static int de4x5_eisa_probe(struct device *gendev)
 {
 	struct eisa_device *edev;
 	u_long iobase;
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index ae6e30d..1d5c3e1 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -2843,7 +2843,7 @@ static void cleanup_dev(struct net_device *d)
 }
 
 #ifdef CONFIG_EISA
-static int __init hp100_eisa_probe (struct device *gendev)
+static int hp100_eisa_probe(struct device *gendev)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
 	struct eisa_device *edev = to_eisa_device(gendev);
-- 
2.1.4

