From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 3/9] NetXen: hw initialization routines (name
 prefix change)
Date: Mon, 21 Aug 2006 03:04:10 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608210302120.22771@dut39>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608180758550.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	"rob@netxen.com" <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:3193 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1751834AbWHUKEM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 06:04:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608180758550.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.17/drivers/net/netxen/netxen_nic_init.c linux-2.6.17/drivers/net/netxen/netxen_nic_init.c
--- linux-2.6.17/drivers/net/netxen/netxen_nic_init.c	2006-08-17 07:12:34.000000000 -0700
+++ linux-2.6.17/drivers/net/netxen/netxen_nic_init.c	2006-08-21 02:20:00.000000000 -0700
@@ -103,7 +103,7 @@
  	crb_addr_transform(C2C0);
  }

-int init_firmware(struct netxen_adapter *adapter)
+int netxen_init_firmware(struct netxen_adapter *adapter)
  {
  	u32 state = 0, loops = 0, err = 0;

@@ -133,7 +133,7 @@
  	return err;
  }

-void initialize_adapter_sw(struct netxen_adapter *adapter)
+void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
  {
  	int ctxid, ring;
  	u32 i;
@@ -167,7 +167,7 @@
  		"adapter->free_cmd_buf_list", "adapter->free_rxbuf");
  }

-void initialize_adapter_hw(struct netxen_adapter *adapter)
+void netxen_initialize_adapter_hw(struct netxen_adapter *adapter)
  {
  	if (netxen_nic_get_board_info(adapter) != 0)
  		printk("%s: Error getting board config info.\n",
@@ -218,7 +218,7 @@
  static long rom_max_timeout = 10000;
  static long rom_lock_timeout = 1000000;

-int rom_lock(struct netxen_adapter *adapter)
+static inline int rom_lock(struct netxen_adapter *adapter)
  {
  	int iter;
  	u32 done = 0;
@@ -248,7 +248,7 @@
  	return 0;
  }

-void rom_unlock(struct netxen_adapter *adapter)
+static inline void rom_unlock(struct netxen_adapter *adapter)
  {
  	u32 val;

@@ -274,7 +274,8 @@
  	return 0;
  }

-int do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
+static inline int
+do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
  {
  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
@@ -314,7 +315,7 @@
  #define NETXEN_ROM_ROUNDUP		0x80000000ULL
  #define NETXEN_ROM_FOUND_INIT		0x400

-int pinit_from_rom(struct netxen_adapter *adapter, int verbose)
+int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
  {
  	int addr, val, status;
  	int n, i;
@@ -457,7 +458,7 @@
  	return 0;
  }

-void phantom_init(struct netxen_adapter *adapter)
+void netxen_phantom_init(struct netxen_adapter *adapter)
  {
  	u32 val = 0;
  	int loops = 0;

