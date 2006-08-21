From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 1/9] NetXen: Makefile and driver main file (name
 prefix change)
Date: Mon, 21 Aug 2006 03:01:57 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608210259170.22771@dut39>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608180739290.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	"rob@netxen.com" <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:37748 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1751068AbWHUKB7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 06:01:59 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608180739290.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.17/drivers/net/netxen/netxen_nic_main.c linux-2.6.17/drivers/net/netxen/netxen_nic_main.c
--- linux-2.6.17/drivers/net/netxen/netxen_nic_main.c	2006-08-17 07:12:34.000000000 -0700
+++ linux-2.6.17/drivers/net/netxen/netxen_nic_main.c	2006-08-21 02:20:00.000000000 -0700
@@ -211,8 +211,8 @@
  	adapter->ahw.pci_base = mem_ptr;
  	spin_lock_init(&adapter->tx_lock);
  	spin_lock_init(&adapter->lock);
-
-	initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
+	/* initialize the buffers in adapter */
+	netxen_initialize_adapter_sw(adapter);
  	/*
  	 * Set the CRB window to invalid. If any register in window 0 is
  	 * accessed it should set the window to 0 and then reset it to 1.
@@ -222,7 +222,7 @@
  	 *  Adapter in our case is quad port so initialize it before
  	 *  initializing the ports
  	 */
-	initialize_adapter_hw(adapter);	/* initialize the adapter */
+	netxen_initialize_adapter_hw(adapter);	/* initialize the adapter */

  	init_timer(&adapter->watchdog_timer);
  	adapter->ahw.xg_linkup = 0;
@@ -243,8 +243,8 @@
  		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
  #endif

-	if (is_flash_supported(adapter) == 0 &&
-	    get_flash_mac_addr(adapter, mac_addr) == 0)
+	if (netxen_is_flash_supported(adapter) == 0 &&
+	    netxen_get_flash_mac_addr(adapter, mac_addr) == 0)
  		valid_mac = 1;
  	else
  		valid_mac = 0;
@@ -345,7 +345,7 @@
  	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
  	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));

-	phantom_init(adapter);
+	netxen_phantom_init(adapter);
  	/*
  	 * delay a while to ensure that the Pegs are up & running.
  	 * Otherwise, we might see some flaky behaviour.
@@ -423,9 +423,9 @@

  	netxen_nic_stop_all_ports(adapter);
  	/* leave the hw in the same state as reboot */
-	pinit_from_rom(adapter, 0);
+	netxen_pinit_from_rom(adapter, 0);
  	udelay(500);
-	load_firmware(adapter);
+	netxen_load_firmware(adapter);

  	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
  		netxen_nic_disable_int(adapter);
@@ -486,7 +486,7 @@
  	int ctx, ring;

  	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
-		err = init_firmware(adapter);
+		err = netxen_init_firmware(adapter);
  		if (err != 0) {
  			printk(KERN_ERR "Failed to init firmware\n");
  			return -EIO;

