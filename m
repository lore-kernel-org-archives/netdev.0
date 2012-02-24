From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 04/11] dec/tulip/de4x5: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:55 +0100
Message-ID: <1330091162-8141-5-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/dec/tulip/de4x5.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 9358340..18b106c 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -5234,11 +5234,7 @@ de4x5_dbg_open(struct net_device *dev)
 
     if (de4x5_debug & DEBUG_OPEN) {
 	printk("%s: de4x5 opening with irq %d\n",dev->name,dev->irq);
-	printk("\tphysical address: ");
-	for (i=0;i<6;i++) {
-	    printk("%2.2x:",(short)dev->dev_addr[i]);
-	}
-	printk("\n");
+	printk("\tphysical address: %pM\n", dev->dev_addr);
 	printk("Descriptor head addresses:\n");
 	printk("\t0x%8.8lx  0x%8.8lx\n",(u_long)lp->rx_ring,(u_long)lp->tx_ring);
 	printk("Descriptor addresses:\nRX: ");
-- 
1.7.8.3
