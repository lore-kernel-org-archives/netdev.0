From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e100 2.6] fix stray skb pointer
Date: Fri, 12 Mar 2004 15:52:24 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403121546120.1550-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>,
        <dsaxena@plexity.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Not setting cb->skb = NULL after releasing skb to OS or during
  initialization of cbs.  Reported by Deepak Saxena
  [dsaxena@plexity.net].

----------

--- linux-2.5/drivers/net/e100.c	2004-03-12 15:32:07.000000000 -0800
+++ linux-2.5/drivers/net/e100.c.mod	2004-03-12 15:32:31.000000000 -0800
@@ -158,7 +158,7 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.16"
+#define DRV_VERSION		"3.0.17"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1285,6 +1285,7 @@ static inline int e100_tx_clean(struct n
 				le16_to_cpu(cb->u.tcb.tbd.size),
 				PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(cb->skb);
+			cb->skb = NULL;
 			tx_cleaned = 1;
 		}
 		cb->status = 0;
@@ -1347,6 +1348,7 @@ static int e100_alloc_cbs(struct nic *ni
 		cb->dma_addr = nic->cbs_dma_addr + i * sizeof(struct cb);
 		cb->link = cpu_to_le32(nic->cbs_dma_addr +
 			((i+1) % count) * sizeof(struct cb));
+		cb->skb = NULL;
 	}
 
 	nic->cb_to_use = nic->cb_to_send = nic->cb_to_clean = nic->cbs;
