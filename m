From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 1/9] NetXen: Makefile and driver main file
Date: Tue, 19 Sep 2006 08:18:59 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190814350.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151134120.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:54126 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750806AbWISPTA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:19:00 -0400
To: Randy Dunlap <rdunlap@xenotime.net>
In-Reply-To: <Pine.LNX.4.64.0609151134120.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy,

Thanks for feedback. We have incorporated all of the suggestions.

--
pradeep

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_main.c linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_main.c	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_main.c	2006-09-19 07:51:20.000000000 -0700
@@ -561,9 +561,9 @@
  	return 0;
  }

-/**
+/*
   * netxen_nic_close - Disables a network interface entry point
- **/
+ */
  static int netxen_nic_close(struct net_device *netdev)
  {
  	struct netxen_port *port = netdev_priv(netdev);
@@ -628,7 +628,7 @@

  	u32 producer = 0;
  	u32 saved_producer = 0;
-	struct cmd_desc_type0_t *hwdesc;
+	struct cmd_desc_type0 *hwdesc;
  	int k;
  	struct netxen_cmd_buffer *pbuf = NULL;
  	unsigned int tries = 0;
@@ -691,7 +691,7 @@
  		if (((skb->nh.iph)->ihl * sizeof(u32)) +
  		    ((skb->h.th)->doff * sizeof(u32)) +
  		    sizeof(struct ethhdr) >
-		    (sizeof(struct cmd_desc_type0_t) - NET_IP_ALIGN)) {
+		    (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
  			no_of_desc++;
  		}
  	}
@@ -733,7 +733,7 @@
  	producer = local_producer;
  	saved_producer = producer;
  	hwdesc = &hw->cmd_desc_head[producer];
-	memset(hwdesc, 0, sizeof(struct cmd_desc_type0_t));
+	memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
  	/* Take skb->data itself */
  	pbuf = &adapter->cmd_buf_arr[producer];
  	if (skb_shinfo(skb)->gso_size > 0) {
@@ -773,7 +773,7 @@
  			producer = get_next_index(producer,
  						  adapter->max_tx_desc_count);
  			hwdesc = &hw->cmd_desc_head[producer];
-			memset(hwdesc, 0, sizeof(struct cmd_desc_type0_t));
+			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
  		}
  		frag = &skb_shinfo(skb)->frags[i - 1];
  		len = frag->size;
@@ -819,9 +819,9 @@
  	if (hw->cmd_desc_head[saved_producer].opcode == TX_TCP_LSO) {
  		int hdr_len, first_hdr_len, more_hdr;
  		hdr_len = hw->cmd_desc_head[saved_producer].total_hdr_length;
-		if (hdr_len > (sizeof(struct cmd_desc_type0_t) - NET_IP_ALIGN)) {
+		if (hdr_len > (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
  			first_hdr_len =
-			    sizeof(struct cmd_desc_type0_t) - NET_IP_ALIGN;
+			    sizeof(struct cmd_desc_type0) - NET_IP_ALIGN;
  			more_hdr = 1;
  		} else {
  			first_hdr_len = hdr_len;
@@ -964,11 +964,11 @@
  	return ret;
  }

-/**
+/*
   * netxen_intr - Interrupt Handler
   * @irq: interrupt number
   * data points to adapter stucture (which may be handling more than 1 port
- **/
+ */
  irqreturn_t netxen_intr(int irq, void *data, struct pt_regs * regs)
  {
  	struct netxen_adapter *adapter;

