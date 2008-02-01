From: Doug Maxey <dwm@austin.ibm.com>
Subject: [PATCH 3/5] ehea: fix main checkpatch complaints
Date: Thu, 31 Jan 2008 20:20:49 -0600
Message-ID: <1201832451-23634-4-git-send-email-dwm@austin.ibm.com>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux PowerPC List <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>, Jan-Bernd Themann <themann@de.ibm.com>
To: Jeff Garzik <jgarzik@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Cc: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Doug Maxey <dwm@austin.ibm.com>
---
 drivers/net/ehea/ehea_main.c |   87 ++++++++++++++++++++++--------------------
 1 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 869e160..99ea46a 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -6,9 +6,9 @@
  *  (C) Copyright IBM Corp. 2006
  *
  *  Authors:
- *       Christoph Raisch <raisch@de.ibm.com>
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Thomas Klein <tklein@de.ibm.com>
+ *	 Christoph Raisch <raisch@de.ibm.com>
+ *	 Jan-Bernd Themann <themann@de.ibm.com>
+ *	 Thomas Klein <tklein@de.ibm.com>
  *
  *
  * This program is free software; you can redistribute it and/or modify
@@ -54,11 +54,11 @@ static int rq1_entries = EHEA_DEF_ENTRIES_RQ1;
 static int rq2_entries = EHEA_DEF_ENTRIES_RQ2;
 static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
-static int use_mcs = 0;
-static int use_lro = 0;
+static int use_mcs;
+static int use_lro;
 static int lro_max_aggr = EHEA_LRO_MAX_AGGR;
 static int num_tx_qps = EHEA_NUM_TX_QP;
-static int prop_carrier_state = 0;
+static int prop_carrier_state;
 
 module_param(msg_level, int, 0);
 module_param(rq1_entries, int, 0);
@@ -94,9 +94,9 @@ MODULE_PARM_DESC(lro_max_aggr, " LRO: Max packets to be aggregated. Default = "
 MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 		 "Default = 0");
 
-static int port_name_cnt = 0;
+static int port_name_cnt;
 static LIST_HEAD(adapter_list);
-u64 ehea_driver_flags = 0;
+u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
 
 struct semaphore dlpar_mem_lock;
@@ -121,12 +121,13 @@ static struct of_platform_driver ehea_driver = {
 	.remove = ehea_remove,
 };
 
-void ehea_dump(void *adr, int len, char *msg) {
+void ehea_dump(void *adr, int len, char *msg)
+{
 	int x;
 	unsigned char *deb = adr;
 	for (x = 0; x < len; x += 16) {
 		printk(DRV_NAME " %s adr=%p ofs=%04x %016lx %016lx\n", msg,
-			  deb, x, *((u64*)&deb[0]), *((u64*)&deb[8]));
+			  deb, x, *((u64 *)&deb[0]), *((u64 *)&deb[8]));
 		deb += 16;
 	}
 }
@@ -518,7 +519,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 		last_wqe_index = wqe_index;
 		rmb();
 		if (!ehea_check_cqe(cqe, &rq)) {
-			if (rq == 1) {	/* LL RQ1 */
+			if (rq == 1) {
+				/* LL RQ1 */
 				skb = get_skb_by_index_ll(skb_arr_rq1,
 							  skb_arr_rq1_len,
 							  wqe_index);
@@ -531,10 +533,11 @@ static int ehea_proc_rwqes(struct net_device *dev,
 					if (!skb)
 						break;
 				}
-				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
+				skb_copy_to_linear_data(skb, ((char *)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(dev, skb, cqe);
-			} else if (rq == 2) {  /* RQ2 */
+			} else if (rq == 2) {
+				/* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
 				if (unlikely(!skb)) {
@@ -544,7 +547,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 				}
 				ehea_fill_skb(dev, skb, cqe);
 				processed_rq2++;
-			} else {  /* RQ3 */
+			} else {
+				/* RQ3 */
 				skb = get_skb_by_index(skb_arr_rq3,
 						       skb_arr_rq3_len, cqe);
 				if (unlikely(!skb)) {
@@ -592,7 +596,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 	unsigned long flags;
 
 	cqe = ehea_poll_cq(send_cq);
-	while(cqe && (quota > 0)) {
+	while (cqe && (quota > 0)) {
 		ehea_inc_cq(send_cq);
 
 		cqe_counter++;
@@ -643,7 +647,8 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 
 static int ehea_poll(struct napi_struct *napi, int budget)
 {
-	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res, napi);
+	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res,
+						napi);
 	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
@@ -743,8 +748,9 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	u64 hret;
 	struct hcp_ehea_port_cb0 *cb0;
 
-	cb0 = kzalloc(PAGE_SIZE, GFP_ATOMIC);   /* May be called via */
-	if (!cb0) {                             /* ehea_neq_tasklet() */
+	/* may be called via ehea_neq_tasklet() */
+	cb0 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
+	if (!cb0) {
 		ehea_error("no mem for cb0");
 		ret = -ENOMEM;
 		goto out;
@@ -762,7 +768,7 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	/* MAC address */
 	port->mac_addr = cb0->port_mac_addr << 16;
 
-	if (!is_valid_ether_addr((u8*)&port->mac_addr)) {
+	if (!is_valid_ether_addr((u8 *)&port->mac_addr)) {
 		ret = -EADDRNOTAVAIL;
 		goto out_free;
 	}
@@ -994,7 +1000,7 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 
 static void ehea_neq_tasklet(unsigned long data)
 {
-	struct ehea_adapter *adapter = (struct ehea_adapter*)data;
+	struct ehea_adapter *adapter = (struct ehea_adapter *)data;
 	struct ehea_eqe *eqe;
 	u64 event_mask;
 
@@ -1204,7 +1210,7 @@ int ehea_rem_smrs(struct ehea_port_res *pr)
 
 static int ehea_init_q_skba(struct ehea_q_skb_arr *q_skba, int max_q_entries)
 {
-	int arr_size = sizeof(void*) * max_q_entries;
+	int arr_size = sizeof(void *) * max_q_entries;
 
 	q_skba->arr = vmalloc(arr_size);
 	if (!q_skba->arr)
@@ -1489,7 +1495,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	sg1entry = &swqe->u.immdata_desc.sg_entry;
-	sg_list = (struct ehea_vsgentry*)&swqe->u.immdata_desc.sg_list;
+	sg_list = (struct ehea_vsgentry *)&swqe->u.immdata_desc.sg_list;
 	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
@@ -1542,7 +1548,7 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
 		ehea_error("%sregistering bc address failed (tagged)",
-                           hcallid == H_REG_BCMC ? "" : "de");
+			   hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 		goto out_herr;
 	}
@@ -1732,7 +1738,7 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 		}
 }
 
-static void ehea_add_multicast_entry(struct ehea_port* port, u8* mc_mac_addr)
+static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
 {
 	struct ehea_mc_list *ehea_mcl_entry;
 	u64 hret;
@@ -1791,11 +1797,10 @@ static void ehea_set_multicast_list(struct net_device *dev)
 			goto out;
 		}
 
-		for (i = 0, k_mcl_entry = dev->mc_list;
-		     i < dev->mc_count;
-		     i++, k_mcl_entry = k_mcl_entry->next) {
+		for (i = 0, k_mcl_entry = dev->mc_list; i < dev->mc_count; i++,
+			     k_mcl_entry = k_mcl_entry->next)
 			ehea_add_multicast_entry(port, k_mcl_entry->dmi_addr);
-		}
+
 	}
 out:
 	return;
@@ -1925,12 +1930,12 @@ static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
 
 	if ((skb->protocol == htons(ETH_P_IP)) &&
 	    (ip_hdr(skb)->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr*)(skb_network_header(skb) + (ip_hdr(skb)->ihl * 4));
+		tcp = (struct tcphdr *)(skb_network_header(skb) +
+					(ip_hdr(skb)->ihl * 4));
 		tmp = (tcp->source + (tcp->dest << 16)) % 31;
 		tmp += ip_hdr(skb)->daddr % 31;
 		return tmp % num_qps;
-	}
-	else
+	} else
 		return 0;
 }
 
@@ -2122,7 +2127,7 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 	u64 hret;
 	u16 dummy16 = 0;
 	u64 dummy64 = 0;
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 
 	cb0 = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!cb0) {
@@ -2248,7 +2253,7 @@ static int ehea_clean_all_portres(struct ehea_port *port)
 	int ret = 0;
 	int i;
 
-	for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
 		ret |= ehea_clean_portres(port, &port->port_res[i]);
 
 	ret |= ehea_destroy_eq(port->qp_eq);
@@ -2300,7 +2305,7 @@ static int ehea_up(struct net_device *dev)
 		goto out_clean_pr;
 	}
 
-	for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		ret = ehea_activate_qp(port->adapter, port->port_res[i].qp);
 		if (ret) {
 			ehea_error("activate_qp failed");
@@ -2308,7 +2313,7 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	for(i = 0; i < port->num_def_qps; i++) {
+	for (i = 0; i < port->num_def_qps; i++) {
 		ret = ehea_fill_port_res(&port->port_res[i]);
 		if (ret) {
 			ehea_error("out_free_irqs");
@@ -2425,7 +2430,7 @@ int ehea_stop_qps(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 	int ret = -EIO;
 	int dret;
 	int i;
@@ -2490,7 +2495,7 @@ out:
 	return ret;
 }
 
-void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res * pr)
+void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res *pr)
 {
 	struct ehea_qp qp = *orig_qp;
 	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
@@ -2530,7 +2535,7 @@ int ehea_restart_qps(struct net_device *dev)
 	int ret = 0;
 	int i;
 
-	struct hcp_modify_qp_cb0* cb0;
+	struct hcp_modify_qp_cb0 *cb0;
 	u64 hret;
 	u64 dummy64 = 0;
 	u16 dummy16 = 0;
@@ -3109,7 +3114,7 @@ static ssize_t ehea_probe_port(struct device *dev,
 	of_node_put(eth_dn);
 
 	if (port) {
-		for (i=0; i < EHEA_MAX_PORTS; i++)
+		for (i = 0; i < EHEA_MAX_PORTS; i++)
 			if (!adapter->port[i]) {
 				adapter->port[i] = port;
 				break;
@@ -3144,7 +3149,7 @@ static ssize_t ehea_remove_port(struct device *dev,
 
 		ehea_shutdown_single_port(port);
 
-		for (i=0; i < EHEA_MAX_PORTS; i++)
+		for (i = 0; i < EHEA_MAX_PORTS; i++)
 			if (adapter->port[i] == port) {
 				adapter->port[i] = NULL;
 				break;
@@ -3313,7 +3318,7 @@ static int ehea_reboot_notifier(struct notifier_block *nb,
 }
 
 static struct notifier_block ehea_reboot_nb = {
-        .notifier_call = ehea_reboot_notifier,
+	.notifier_call = ehea_reboot_notifier,
 };
 
 static int check_module_parm(void)
-- 
1.5.3.8
