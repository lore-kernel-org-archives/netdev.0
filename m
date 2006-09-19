From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 3/9] NetXen: hw initilization routines
Date: Tue, 19 Sep 2006 08:23:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190821410.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151140360.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:33136 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750806AbWISPXE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:23:04 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151140360.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_init.c linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_init.c
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_init.c	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_init.c	2006-09-19 07:51:20.000000000 -0700
@@ -208,8 +208,8 @@
  		ops->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
  		ops->macaddr_set = netxen_niu_macaddr_set;
  		ops->set_mtu = netxen_nic_set_mtu_gb;
-		ops->set_promisc_mode = netxen_niu_set_promiscuous_mode;
-		ops->unset_promisc_mode = netxen_niu_set_promiscuous_mode;
+		ops->set_promisc = netxen_niu_set_promiscuous_mode;
+		ops->unset_promisc = netxen_niu_set_promiscuous_mode;
  		ops->phy_read = netxen_niu_gbe_phy_read;
  		ops->phy_write = netxen_niu_gbe_phy_write;
  		ops->init_port = netxen_niu_gbe_init_port;
@@ -225,8 +225,8 @@
  		ops->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
  		ops->macaddr_set = netxen_niu_xg_macaddr_set;
  		ops->set_mtu = netxen_nic_set_mtu_xgb;
-		ops->set_promisc_mode = netxen_niu_xg_set_promiscuous_mode;
-		ops->unset_promisc_mode = netxen_niu_xg_set_promiscuous_mode;
+		ops->set_promisc = netxen_niu_xg_set_promiscuous_mode;
+		ops->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
  		ops->stop_port = netxen_niu_disable_xg_port;
  		break;

@@ -535,8 +535,8 @@
  		struct netxen_recv_context *recv_ctx =
  		    &(adapter->recv_ctx[ctx]);
  		u32 consumer;
-		struct status_desc_t *desc_head;
-		struct status_desc_t *desc;	/* used to read status desc here */
+		struct status_desc *desc_head;
+		struct status_desc *desc;	/* used to read status desc here */

  		consumer = recv_ctx->status_rx_consumer;
  		desc_head = recv_ctx->rcv_status_desc_head;
@@ -584,7 +584,7 @@
   */
  void
  netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
-		   struct status_desc_t *desc)
+		   struct status_desc *desc)
  {
  	struct netxen_port *port = adapter->port[STATUS_DESC_PORT(desc)];
  	struct pci_dev *pdev = port->pdev;
@@ -674,8 +674,8 @@
  u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
  {
  	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
-	struct status_desc_t *desc_head = recv_ctx->rcv_status_desc_head;
-	struct status_desc_t *desc;	/* used to read status desc here */
+	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
+	struct status_desc *desc;	/* used to read status desc here */
  	u32 consumer = recv_ctx->status_rx_consumer;
  	int count = 0, ring;

@@ -829,9 +829,9 @@
  		__FUNCTION__);
  }

-/**
+/*
   * netxen_post_rx_buffers puts buffer in the Phantom memory
- **/
+ */
  void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
  {
  	struct pci_dev *pdev = adapter->ahw.pdev;
@@ -841,7 +841,7 @@
  	struct netxen_recv_crb *crbarea = &recv_crb_registers[ctx];
  	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
  	u32 producer;
-	struct rcv_desc_t *pdesc;
+	struct rcv_desc *pdesc;
  	struct netxen_rx_buffer *buffer;
  	int count = 0;
  	int index = 0;

