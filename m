From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 5/11] ixgb: Reset status in the Rx
 descriptor prior to handing it to the controller (fwd)
Date: Wed, 27 Apr 2005 10:49:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271048460.16913-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Reset status in the Rx descriptor prior to handing it to the controller.
Leave three Rx descriptors unused

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c
net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c        2005-04-05
23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c    2005-04-05
23:06:38.283932752 -0700
@@ -1977,8 +1977,8 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte

        num_group_tail_writes = IXGB_RX_BUFFER_WRITE;

-       /* leave one descriptor unused */
-       while(--cleancount > 0) {
+       /* leave three descriptors unused */
+       while(--cleancount > 2) {
                rx_desc = IXGB_RX_DESC(*rx_ring, i);

                skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
@@ -2005,6 +1933,10 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
                                   PCI_DMA_FROMDEVICE);

                rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
+               /* guarantee DD bit not set now before h/w gets descriptor
+                * this is the rest of the workaround for h/w double
+                * writeback. */
+               rx_desc->status = 0;

                if((i & ~(num_group_tail_writes- 1)) == i) {
                        /* Force memory writes to complete before letting  h/w
