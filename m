From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2/2 2.6] e100: whitespace and DPRINTKS
Date: Wed, 22 Sep 2004 12:27:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409221226020.7544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a short patch to add a couple of new DPRINTKS and fix some 
whitespace issues.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

--- netdev-2.6/drivers/net/e100.c	2004-09-21 13:54:33.000000000 -0700
+++ /home/jbrandeb/netdev-2.6/drivers/net/e100.c.msg.patch	2004-09-22 11:55:01.000000000 -0700
@@ -1305,6 +1305,7 @@ static int e100_xmit_frame(struct sk_buf
 	switch(err) {
 	case -ENOSPC:
 		/* We queued the skb, but now we're out of space. */
+		DPRINTK(TX_ERR, DEBUG, "No space for CB\n");
 		netif_stop_queue(netdev);
 		break;
 	case -ENOMEM:
@@ -1469,7 +1470,7 @@ static inline int e100_rx_indicate(struc
 
 	/* If data isn't ready, nothing to indicate */
 	if(unlikely(!(rfd_status & cb_complete)))
-       		return -EAGAIN;
+		return -EAGAIN;
 
 	/* Get actual data size */
 	actual_size = le16_to_cpu(rfd->actual_size) & 0x3FFF;
@@ -1761,7 +1762,7 @@ static int e100_loopback_test(struct nic
 
 	if(memcmp(nic->rx_to_clean->skb->data + sizeof(struct rfd),
 	   skb->data, ETH_DATA_LEN))
-       		err = -EAGAIN;
+		err = -EAGAIN;
 
 err_loopback_none:
 	mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR, 0);
@@ -1960,6 +1961,8 @@ static int e100_set_ringparam(struct net
 	rfds->count = min(rfds->count, rfds->max);
 	cbs->count = max(ring->tx_pending, cbs->min);
 	cbs->count = min(cbs->count, cbs->max);
+	DPRINTK(DRV, INFO, "Ring Param settings: rx: %d, tx %d\n",
+	        rfds->count, cbs->count);
 	if(netif_running(netdev))
 		e100_up(nic);
 
@@ -2352,7 +2355,7 @@ static int __init e100_init_module(void)
 		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}
-        return pci_module_init(&e100_driver);
+	return pci_module_init(&e100_driver);
 }
 
 static void __exit e100_cleanup_module(void)
