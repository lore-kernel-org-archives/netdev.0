From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 02/11] amd/hplance.c: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:53 +0100
Message-ID: <1330091162-8141-3-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/amd/hplance.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 86aa0d5..40f62e8 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -89,7 +89,6 @@ static int __devinit hplance_init_one(struct dio_dev *d,
 {
 	struct net_device *dev;
 	int err = -ENOMEM;
-	int i;
 
 	dev = alloc_etherdev(sizeof(struct hplance_private));
 	if (!dev)
@@ -107,13 +106,8 @@ static int __devinit hplance_init_one(struct dio_dev *d,
 
 	dio_set_drvdata(d, dev);
 
-	printk(KERN_INFO "%s: %s; select code %d, addr %2.2x", dev->name, d->name, d->scode, dev->dev_addr[0]);
-
-	for (i=1; i<6; i++) {
-		printk(":%2.2x", dev->dev_addr[i]);
-	}
-
-	printk(", irq %d\n", d->ipl);
+	printk(KERN_INFO "%s: %s; select code %d, addr %pM, irq %d\n",
+	       dev->name, d->name, d->scode, dev->dev_addr, d->ipl);
 
 	return 0;
 
-- 
1.7.8.3
