From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Update FarSync WAN driver in 2.4.25
Date: Wed, 4 Feb 2004 22:32:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204223258.A19321@electric-eye.fr.zoreil.com>
References: <7C078C66B7752B438B88E11E5E20E72E25CBB5@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "'davem@redhat.com'" <davem@redhat.com>,
        "'jgarzik@redhat.com'" <jgarzik@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Content-Disposition: inline
In-Reply-To: <7C078C66B7752B438B88E11E5E20E72E25CBB5@general.hq.farsitecommunications.com>; from kevin.curtis@farsite.co.uk on Wed, Feb 04, 2004 at 04:06:16PM -0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kevin Curtis <kevin.curtis@farsite.co.uk> :
[...]
diff -urN linux-2.4.25-orig/drivers/net/wan/farsync.c linux/drivers/net/wan/farsync.c
--- linux-2.4.25-orig/drivers/net/wan/farsync.c	2004-02-04 12:08:41.000000000 +0000
+++ linux/drivers/net/wan/farsync.c	2004-02-04 13:15:45.000000000 +0000
[...]
+fst_recover_rx_error ( struct fst_card_info *card, struct fst_port_info *port,
+		   unsigned char dmabits, int rxp, unsigned short len)
+{
[...]
+	    if ( ++rxp >= NUM_RX_BUFFER )
+	      rxp = 0;

-> rxp = (rxp + 1) % NUM_RX_BUFFER; ?

   There are a few of those.

[...]
+	if (card->family == FST_FAMILY_TXU)
+	  {
+	    /*
+	     * Allocate a dma buffer for transmit and receives
+	     */
+	    card->rx_dma_handle_host = 
+	      pci_alloc_consistent(card->device, FST_MAX_MTU, 
+				   &card->rx_dma_handle_card);
+	    if (card->rx_dma_handle_host == NULL)
+	      {
+		printk_err("Could not allocate rx dma buffer\n");
+		return;
+	      }
+	    card->tx_dma_handle_host = 
+	      pci_alloc_consistent(card->device, FST_MAX_MTU,
+				   &card->tx_dma_handle_card);
+	    if (card->tx_dma_handle_host == NULL)
+	      {
+		printk_err("Could not allocate tx dma buffer\n");
+		return;
+	      }
+	  }

-> The error logic is broken. An error code should be returned to the caller
   if the allocation fails. Otherwise, the kernel will crash on module removal
   or if the device is further used.


@@ -1516,16 +2648,39 @@
[...]
+	    for (i=0; i< fst_excluded_cards; i++)
+	      {
+		if ((pdev->devfn)>>3 == fst_excluded_list[i])
+		  {
+		    printk("FarSync PCI device %d not assigned\n", (pdev->devfn)>>3);

-> printk(KERN_xxx/printk_xxx

--
Ueimor
