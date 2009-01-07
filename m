From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] powerpc: cleanup from l64 to ll64 change: drivers/net
Date: Wed, 7 Jan 2009 11:40:06 +1100
Message-ID: <20090107114006.336cfad0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>,
	Santiago Leon <santil@us.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:57099 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbZAGAkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:40:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are powerpc specific drivers.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ehea/ehea_main.c |    8 ++++----
 drivers/net/ehea/ehea_qmr.c  |   18 +++++++++---------
 drivers/net/ibmveth.c        |   16 ++++++++--------
 drivers/net/iseries_veth.c   |    2 +-
 4 files changed, 22 insertions(+), 22 deletions(-)

This patch on its own will generate several warnings - it depends on
the actual l64 to ll64 patch that is pending in the powerpc queue.  It
may be easier for someone to ack this and for it to actually be fed
through the powerpc tree.

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index e3131ea..dfe9226 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -132,7 +132,7 @@ void ehea_dump(void *adr, int len, char *msg)
 	int x;
 	unsigned char *deb = adr;
 	for (x = 0; x < len; x += 16) {
-		printk(DRV_NAME " %s adr=%p ofs=%04x %016lx %016lx\n", msg,
+		printk(DRV_NAME " %s adr=%p ofs=%04x %016llx %016llx\n", msg,
 			  deb, x, *((u64 *)&deb[0]), *((u64 *)&deb[8]));
 		deb += 16;
 	}
@@ -883,7 +883,7 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 
 	while (eqe) {
 		qp_token = EHEA_BMASK_GET(EHEA_EQE_QP_TOKEN, eqe->entry);
-		ehea_error("QP aff_err: entry=0x%lx, token=0x%x",
+		ehea_error("QP aff_err: entry=0x%llx, token=0x%x",
 			   eqe->entry, qp_token);
 
 		qp = port->port_res[qp_token].qp;
@@ -1159,7 +1159,7 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 		netif_stop_queue(port->netdev);
 		break;
 	default:
-		ehea_error("unknown event code %x, eqe=0x%lX", ec, eqe);
+		ehea_error("unknown event code %x, eqe=0x%llX", ec, eqe);
 		break;
 	}
 }
@@ -1971,7 +1971,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 		}
 
 		if (dev->mc_count > port->adapter->max_mc_mac) {
-			ehea_info("Mcast registration limit reached (0x%lx). "
+			ehea_info("Mcast registration limit reached (0x%llx). "
 				  "Use ALLMULTI!",
 				  port->adapter->max_mc_mac);
 			goto out;
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 225c692..49d766e 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -168,7 +168,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 					     cq->fw_handle, rpage, 1);
 		if (hret < H_SUCCESS) {
 			ehea_error("register_rpage_cq failed ehea_cq=%p "
-				   "hret=%lx counter=%i act_pages=%i",
+				   "hret=%llx counter=%i act_pages=%i",
 				   cq, hret, counter, cq->attr.nr_pages);
 			goto out_kill_hwq;
 		}
@@ -178,13 +178,13 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 
 			if ((hret != H_SUCCESS) || (vpage)) {
 				ehea_error("registration of pages not "
-					   "complete hret=%lx\n", hret);
+					   "complete hret=%llx\n", hret);
 				goto out_kill_hwq;
 			}
 		} else {
 			if (hret != H_PAGE_REGISTERED) {
 				ehea_error("CQ: registration of page failed "
-					   "hret=%lx\n", hret);
+					   "hret=%llx\n", hret);
 				goto out_kill_hwq;
 			}
 		}
@@ -986,15 +986,15 @@ void print_error_data(u64 *data)
 		length = EHEA_PAGESIZE;
 
 	if (type == 0x8) /* Queue Pair */
-		ehea_error("QP (resource=%lX) state: AER=0x%lX, AERR=0x%lX, "
-			   "port=%lX", resource, data[6], data[12], data[22]);
+		ehea_error("QP (resource=%llX) state: AER=0x%llX, AERR=0x%llX, "
+			   "port=%llX", resource, data[6], data[12], data[22]);
 
 	if (type == 0x4) /* Completion Queue */
-		ehea_error("CQ (resource=%lX) state: AER=0x%lX", resource,
+		ehea_error("CQ (resource=%llX) state: AER=0x%llX", resource,
 			   data[6]);
 
 	if (type == 0x3) /* Event Queue */
-		ehea_error("EQ (resource=%lX) state: AER=0x%lX", resource,
+		ehea_error("EQ (resource=%llX) state: AER=0x%llX", resource,
 			   data[6]);
 
 	ehea_dump(data, length, "error data");
@@ -1016,11 +1016,11 @@ void ehea_error_data(struct ehea_adapter *adapter, u64 res_handle)
 				rblock);
 
 	if (ret == H_R_STATE)
-		ehea_error("No error data is available: %lX.", res_handle);
+		ehea_error("No error data is available: %llX.", res_handle);
 	else if (ret == H_SUCCESS)
 		print_error_data(rblock);
 	else
-		ehea_error("Error data could not be fetched: %lX", res_handle);
+		ehea_error("Error data could not be fetched: %llX", res_handle);
 
 	kfree(rblock);
 }
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index ca3bb9f..dfa6348 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -602,7 +602,7 @@ static int ibmveth_open(struct net_device *netdev)
 
 	if(lpar_rc != H_SUCCESS) {
 		ibmveth_error_printk("h_register_logical_lan failed with %ld\n", lpar_rc);
-		ibmveth_error_printk("buffer TCE:0x%lx filter TCE:0x%lx rxq desc:0x%lx MAC:0x%lx\n",
+		ibmveth_error_printk("buffer TCE:0x%llx filter TCE:0x%llx rxq desc:0x%llx MAC:0x%llx\n",
 				     adapter->buffer_list_dma,
 				     adapter->filter_list_dma,
 				     rxq_desc.desc,
@@ -1378,13 +1378,13 @@ static int ibmveth_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "Firmware MAC:    %pM\n", firmware_mac);
 
 	seq_printf(seq, "\nAdapter Statistics:\n");
-	seq_printf(seq, "  TX:  vio_map_single failres:      %ld\n", adapter->tx_map_failed);
-	seq_printf(seq, "       send failures:               %ld\n", adapter->tx_send_failed);
-	seq_printf(seq, "  RX:  replenish task cycles:       %ld\n", adapter->replenish_task_cycles);
-	seq_printf(seq, "       alloc_skb_failures:          %ld\n", adapter->replenish_no_mem);
-	seq_printf(seq, "       add buffer failures:         %ld\n", adapter->replenish_add_buff_failure);
-	seq_printf(seq, "       invalid buffers:             %ld\n", adapter->rx_invalid_buffer);
-	seq_printf(seq, "       no buffers:                  %ld\n", adapter->rx_no_buffer);
+	seq_printf(seq, "  TX:  vio_map_single failres:      %lld\n", adapter->tx_map_failed);
+	seq_printf(seq, "       send failures:               %lld\n", adapter->tx_send_failed);
+	seq_printf(seq, "  RX:  replenish task cycles:       %lld\n", adapter->replenish_task_cycles);
+	seq_printf(seq, "       alloc_skb_failures:          %lld\n", adapter->replenish_no_mem);
+	seq_printf(seq, "       add buffer failures:         %lld\n", adapter->replenish_add_buff_failure);
+	seq_printf(seq, "       invalid buffers:             %lld\n", adapter->rx_invalid_buffer);
+	seq_printf(seq, "       no buffers:                  %lld\n", adapter->rx_no_buffer);
 
 	return 0;
 }
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index c7457f9..cb793c2 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -429,7 +429,7 @@ SIMPLE_PORT_ATTR(promiscuous);
 SIMPLE_PORT_ATTR(num_mcast);
 CUSTOM_PORT_ATTR(lpar_map, "0x%X\n", port->lpar_map);
 CUSTOM_PORT_ATTR(stopped_map, "0x%X\n", port->stopped_map);
-CUSTOM_PORT_ATTR(mac_addr, "0x%lX\n", port->mac_addr);
+CUSTOM_PORT_ATTR(mac_addr, "0x%llX\n", port->mac_addr);
 
 #define GET_PORT_ATTR(_name)	(&veth_port_attr_##_name.attr)
 static struct attribute *veth_port_default_attrs[] = {
-- 
1.6.0.5

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
