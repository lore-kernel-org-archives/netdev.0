From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 4/9] NetXen: intr routines and niu handling
Date: Tue, 19 Sep 2006 08:25:18 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190823110.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151144070.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:53873 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1751144AbWISPZS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:25:18 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151144070.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_niu.c linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_niu.c
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_niu.c	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_niu.c	2006-09-19 07:51:20.000000000 -0700
@@ -34,7 +34,7 @@
  #include "netxen_nic.h"
  #include <linux/delay.h>

-/** 
+/*
   * netxen_niu_gbe_phy_read - read a register from the GbE PHY via
   * mii management interface.
   *
@@ -46,7 +46,7 @@
   * @returns  0 on success
   *          -1 on error
   *
- **/
+ */
  int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long phy,
  			    long reg, __le32 * readval)
  {
@@ -134,7 +134,7 @@
  	return result;
  }

-/** 
+/*
   * netxen_niu_gbe_phy_write - write a register to the GbE PHY via
   * mii management interface.
   *
@@ -146,7 +146,7 @@
   * @returns  0 on success
   *          -1 on error
   *
- **/
+ */
  int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
  			     long phy, long reg, __le32 val)
  {
@@ -282,10 +282,10 @@
  	return result;
  }

-/** 
+/*
   * netxen_niu_gbe_set_mii_mode- Set 10/100 Mbit Mode for GbE MAC
   *
- **/
+ */
  void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
  				 int port, long enable)
  {
@@ -321,9 +321,9 @@
  		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
  }

-/** 
+/*
   * netxen_niu_gbe_set_gmii_mode- Set GbE Mode for GbE MAC
- **/
+ */
  void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
  				  int port, long enable)
  {
@@ -407,11 +407,11 @@
  	return result;
  }

-/** 
+/*
   * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
   * @param enable 0 means don't enable the port
   *               1 means enable (or re-enable) the port
- **/
+ */
  int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
  					int port, long enable)
  {
@@ -500,10 +500,10 @@
  	return result;
  }

-/**
+/*
   * Return the current station MAC address.
   * Note that the passed-in value must already be in network byte order.
- **/
+ */
  int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
  			   int phy, netxen_ethernet_macaddr_t * addr)
  {
@@ -530,10 +530,10 @@
  	return 0;
  }

-/**
+/*
   * Set the station MAC address.
   * Note that the passed-in value must already be in network byte order.
- **/
+ */
  int netxen_niu_macaddr_set(struct netxen_port *port,
  			   netxen_ethernet_macaddr_t addr)
  {
@@ -680,7 +680,7 @@
  	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
  				  &reg, 4))
  		return -EIO;
-	if (mode == NETXEN_NIU_PROMISCOUS_MODE) {
+	if (mode == NETXEN_NIU_PROMISC_MODE) {
  		switch (port) {
  		case 0:
  			netxen_clear_gb_drop_gb0(reg);
@@ -721,10 +721,10 @@
  	return 0;
  }

-/**
+/*
   * Set the MAC address for an XG port
   * Note that the passed-in value must already be in network byte order.
- **/
+ */
  int netxen_niu_xg_macaddr_set(struct netxen_port *port,
  			      netxen_ethernet_macaddr_t addr)
  {
@@ -749,10 +749,10 @@
  	return 0;
  }

-/**
+/*
   * Return the current station MAC address.
   * Note that the passed-in value must already be in network byte order.
- **/
+ */
  int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
  			      netxen_ethernet_macaddr_t * addr)
  {
@@ -789,7 +789,7 @@

  	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1, &reg, 4))
  		return -EIO;
-	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
+	if (mode == NETXEN_NIU_PROMISC_MODE)
  		reg = (reg | 0x2000UL);
  	else
  		reg = (reg & ~0x2000UL);

