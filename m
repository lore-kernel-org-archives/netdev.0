From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/2] NetXen: whitespace cleaup and more cleanup fixes
Date: Mon, 4 Dec 2006 09:18:00 -0800
Message-ID: <200612041718.kB4HI0L4021627@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	shemminger@osdl.org, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:4981 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757289AbWLDRSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:18:01 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic.h         |   56 ++++++++++++++++++++--------------------------
 netxen_nic_ethtool.c |   53 +++++++++++++++++++++-----------------------
 netxen_nic_hdr.h     |    6 ++---
 netxen_nic_hw.c      |   54 +++++++++++++++++++++------------------------
 netxen_nic_hw.h      |   10 ++++----
 netxen_nic_init.c    |   61 +++++++++++++++++++++++++--------------------------
 netxen_nic_ioctl.h   |    6 ++---
 netxen_nic_isr.c     |   48 +++++++++++++++++-----------------------
 netxen_nic_main.c    |   54 +++++++++++++++++----------------------------
 netxen_nic_niu.c     |   10 ++++----
 10 files changed, 165 insertions(+), 193 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d925053..d51f437 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1,25 +1,25 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -89,8 +89,8 @@
  * normalize a 64MB crb address to 32MB PCI window 
  * To use NETXEN_CRB_NORMALIZE, window _must_ be set to 1
  */
-#define NETXEN_CRB_NORMAL(reg)        \
-	(reg) - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST
+#define NETXEN_CRB_NORMAL(reg)	\
+	((reg) - NETXEN_CRB_PCIX_HOST2 + NETXEN_CRB_PCIX_HOST)
 
 #define NETXEN_CRB_NORMALIZE(adapter, reg) \
 	pci_base_offset(adapter, NETXEN_CRB_NORMAL(reg))
@@ -164,7 +164,7 @@ enum {
 
 #define MAX_CMD_DESCRIPTORS		1024
 #define MAX_RCV_DESCRIPTORS		32768
-#define MAX_JUMBO_RCV_DESCRIPTORS	1024
+#define MAX_JUMBO_RCV_DESCRIPTORS	4096
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
 #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
@@ -559,7 +559,7 @@ typedef enum {
 #define PRIMARY_START 		(BOOTLD_START)
 #define FLASH_CRBINIT_SIZE 	(0x4000)
 #define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define FLASH_USER_SIZE		(sizeof(netxen_user_info)/sizeof(u32))
+#define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
 #define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
 #define NUM_PRIMARY_SECTORS	(0x20)
 #define NUM_CONFIG_SECTORS 	(1)
@@ -572,7 +572,7 @@ typedef enum {
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
-		(adapter != NULL && adapter->port != NULL && \
+		(adapter != NULL && \
 		adapter->port[0] != NULL && \
 		adapter->port[0]->netdev != NULL) ? \
 		adapter->port[0]->netdev->name : NULL, \
@@ -703,8 +703,6 @@ struct netxen_recv_context {
 
 #define NETXEN_NIC_MSI_ENABLED 0x02
 
-struct netxen_drvops;
-
 struct netxen_adapter {
 	struct netxen_hardware_context ahw;
 	int port_count;		/* Number of configured ports  */
@@ -746,8 +744,21 @@ struct netxen_adapter {
 	struct netxen_recv_context recv_ctx[MAX_RCV_CTX];
 
 	int is_up;
-	int work_done;
-	struct netxen_drvops *ops;
+	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
+	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
+	void (*handle_phy_intr) (struct netxen_adapter *);
+	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
+	int (*set_mtu) (struct netxen_port *, int);
+	int (*set_promisc) (struct netxen_adapter *, int,
+			    netxen_niu_prom_mode_t);
+	int (*unset_promisc) (struct netxen_adapter *, int,
+			      netxen_niu_prom_mode_t);
+	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
+	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
+	int (*init_port) (struct netxen_adapter *, int);
+	void (*init_niu) (struct netxen_adapter *);
+	int (*stop_port) (struct netxen_adapter *, int);
+
 };				/* netxen_adapter structure */
 
 /* Max number of xmit producer threads that can run simultaneously */
@@ -829,23 +840,6 @@ static inline void __iomem *pci_base(str
 	return NULL;
 }
 
-struct netxen_drvops {
-	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
-	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
-	void (*handle_phy_intr) (struct netxen_adapter *);
-	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
-	int (*set_mtu) (struct netxen_port *, int);
-	int (*set_promisc) (struct netxen_adapter *, int,
-			    netxen_niu_prom_mode_t);
-	int (*unset_promisc) (struct netxen_adapter *, int,
-			      netxen_niu_prom_mode_t);
-	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
-	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
-	int (*init_port) (struct netxen_adapter *, int);
-	void (*init_niu) (struct netxen_adapter *);
-	int (*stop_port) (struct netxen_adapter *, int);
-};
-
 extern char netxen_nic_driver_name[];
 
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter,
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 9a914ae..c7fcbf3 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -1,25 +1,25 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -118,7 +118,7 @@ netxen_nic_get_drvinfo(struct net_device
 	u32 fw_minor = 0;
 	u32 fw_build = 0;
 
-	strncpy(drvinfo->driver, "netxen_nic", 32);
+	strncpy(drvinfo->driver, netxen_nic_driver_name, 32);
 	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
 	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
 					      NETXEN_FW_VERSION_MAJOR));
@@ -210,7 +210,6 @@ netxen_nic_get_settings(struct net_devic
 		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
 		       (netxen_brdtype_t) boardinfo->board_type);
 		return -EIO;
-
 	}
 
 	return 0;
@@ -226,18 +225,18 @@ netxen_nic_set_settings(struct net_devic
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
-					       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					       (__le32) ecmd->autoneg) != 0)
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
+					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+					  (__le32) ecmd->autoneg) != 0)
 			return -EIO;
 		else
 			port->link_autoneg = ecmd->autoneg;
 
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, port->portnum,
-					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					      &status) != 0)
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, port->portnum,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					 &status) != 0)
 			return -EIO;
 
 		/* speed */
@@ -257,10 +256,10 @@ netxen_nic_set_settings(struct net_devic
 			netxen_clear_phy_duplex(status);
 		if (ecmd->duplex == DUPLEX_FULL)
 			netxen_set_phy_duplex(status);
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
-					       NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					       *((int *)&status)) != 0)
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
+					  NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					  *((int *)&status)) != 0)
 			return -EIO;
 		else {
 			port->link_speed = ecmd->speed;
@@ -422,10 +421,10 @@ static u32 netxen_nic_get_link(struct ne
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, port->portnum,
-					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					      &status) != 0)
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, port->portnum,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					 &status) != 0)
 			return -EIO;
 		else
 			return (netxen_get_phy_link(status));
@@ -526,10 +525,10 @@ netxen_nic_set_pauseparam(struct net_dev
 				    *(u32 *) (&val));
 		/* set autoneg */
 		autoneg = pause->autoneg;
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
-					       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					       (__le32) autoneg) != 0)
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
+					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+					  (__le32) autoneg) != 0)
 			return -EIO;
 		else {
 			port->link_autoneg = pause->autoneg;
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 72c6ec4..fe8b675 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 105c24f..7470852 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -81,8 +81,8 @@ int netxen_nic_set_mac(struct net_device
 	DPRINTK(INFO, "valid ether addr\n");
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-	if (adapter->ops->macaddr_set)
-		adapter->ops->macaddr_set(port, addr->sa_data);
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(port, addr->sa_data);
 
 	return 0;
 }
@@ -99,17 +99,17 @@ void netxen_nic_set_multi(struct net_dev
 
 	mc_ptr = netdev->mc_list;
 	if (netdev->flags & IFF_PROMISC) {
-		if (adapter->ops->set_promisc)
-			adapter->ops->set_promisc(adapter,
-						  port->portnum,
-						  NETXEN_NIU_PROMISC_MODE);
+		if (adapter->set_promisc)
+			adapter->set_promisc(adapter,
+					     port->portnum,
+					     NETXEN_NIU_PROMISC_MODE);
 	} else {
-		if (adapter->ops->unset_promisc &&
+		if (adapter->unset_promisc &&
 		    adapter->ahw.boardcfg.board_type
 		    != NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
-			adapter->ops->unset_promisc(adapter,
-						    port->portnum,
-						    NETXEN_NIU_NON_PROMISC_MODE);
+			adapter->unset_promisc(adapter,
+					       port->portnum,
+					       NETXEN_NIU_NON_PROMISC_MODE);
 	}
 	if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
 		netxen_nic_mcr_set_mode_select(netxen_mac_addr_cntl_data, 0x03);
@@ -160,8 +160,8 @@ int netxen_nic_change_mtu(struct net_dev
 		return -EINVAL;
 	}
 
-	if (adapter->ops->set_mtu)
-		adapter->ops->set_mtu(port, mtu);
+	if (adapter->set_mtu)
+		adapter->set_mtu(port, mtu);
 	netdev->mtu = mtu;
 
 	return 0;
@@ -184,14 +184,12 @@ int netxen_nic_hw_resources(struct netxe
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 
-	DPRINTK(INFO, "crb_base: %lx %lx", NETXEN_PCI_CRBSPACE,
+	DPRINTK(INFO, "crb_base: %lx %x", NETXEN_PCI_CRBSPACE,
 		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
-	DPRINTK(INFO, "cam base: %lx %lx", NETXEN_CRB_CAM,
+	DPRINTK(INFO, "cam base: %lx %x", NETXEN_CRB_CAM,
 		pci_base_offset(adapter, NETXEN_CRB_CAM));
-	DPRINTK(INFO, "cam RAM: %lx %lx", NETXEN_CAM_RAM_BASE,
+	DPRINTK(INFO, "cam RAM: %lx %x", NETXEN_CAM_RAM_BASE,
 		pci_base_offset(adapter, NETXEN_CAM_RAM_BASE));
-	DPRINTK(INFO, "NIC base:%lx %lx\n", NIC_CRB_BASE_PORT1,
-		pci_base_offset(adapter, NIC_CRB_BASE_PORT1));
 
 	/* Window 1 call */
 	card_cmdring = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_CMDRING));
@@ -648,7 +646,7 @@ void netxen_nic_reg_write(struct netxen_
 
 	addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	DPRINTK(INFO, "writing to base %lx offset %llx addr %p data %x\n",
-		pci_base(adapter, off), off, addr);
+		pci_base(adapter, off), off, addr, val);
 	writel(val, addr);
 
 }
@@ -660,7 +658,7 @@ int netxen_nic_reg_read(struct netxen_ad
 
 	addr = NETXEN_CRB_NORMALIZE(adapter, off);
 	DPRINTK(INFO, "reading from base %lx offset %llx addr %p\n",
-		adapter->ahw.pci_base, off, addr);
+		pci_base(adapter, off), off, addr);
 	val = readl(addr);
 	writel(val, addr);
 
@@ -848,8 +846,8 @@ void netxen_nic_stop_all_ports(struct ne
 
 	for (port_nr = 0; port_nr < adapter->ahw.max_ports; port_nr++) {
 		port = adapter->port[port_nr];
-		if (adapter->ops->stop_port)
-			adapter->ops->stop_port(adapter, port->portnum);
+		if (adapter->stop_port)
+			adapter->stop_port(adapter, port->portnum);
 	}
 }
 
@@ -878,8 +876,8 @@ void netxen_nic_set_link_parameters(stru
 
 	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
-		if (adapter->ops->phy_read
-		    && adapter->ops->
+		if (adapter->phy_read
+		    && adapter->
 		    phy_read(adapter, port->portnum,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
@@ -909,8 +907,8 @@ void netxen_nic_set_link_parameters(stru
 					port->link_duplex = -1;
 					break;
 				}
-				if (adapter->ops->phy_read
-				    && adapter->ops->
+				if (adapter->phy_read
+				    && adapter->
 				    phy_read(adapter, port->portnum,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					     (__le32 *) & autoneg) != 0)
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 201a636..0685633 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -83,8 +83,8 @@ struct netxen_adapter;
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
 
 #define NETXEN_NIC_LOCKED_READ_REG(X, Y)	\
-	addr = pci_base_offset(adapter, (X));	\
-	*(u32 *)Y = readl(addr);
+	addr = pci_base_offset(adapter, X);	\
+	*(u32 *)Y = readl((void __iomem*) addr);
 
 struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_port *port);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0dca029..deac1a3 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1,25 +1,25 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -212,37 +212,36 @@ void netxen_initialize_adapter_hw(struct
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
-	struct netxen_drvops *ops = adapter->ops;
 	switch (adapter->ahw.board_type) {
 	case NETXEN_NIC_GBE:
-		ops->enable_phy_interrupts =
+		adapter->enable_phy_interrupts =
 		    netxen_niu_gbe_enable_phy_interrupts;
-		ops->disable_phy_interrupts =
+		adapter->disable_phy_interrupts =
 		    netxen_niu_gbe_disable_phy_interrupts;
-		ops->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
-		ops->macaddr_set = netxen_niu_macaddr_set;
-		ops->set_mtu = netxen_nic_set_mtu_gb;
-		ops->set_promisc = netxen_niu_set_promiscuous_mode;
-		ops->unset_promisc = netxen_niu_set_promiscuous_mode;
-		ops->phy_read = netxen_niu_gbe_phy_read;
-		ops->phy_write = netxen_niu_gbe_phy_write;
-		ops->init_port = netxen_niu_gbe_init_port;
-		ops->init_niu = netxen_nic_init_niu_gb;
-		ops->stop_port = netxen_niu_disable_gbe_port;
+		adapter->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
+		adapter->macaddr_set = netxen_niu_macaddr_set;
+		adapter->set_mtu = netxen_nic_set_mtu_gb;
+		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
+		adapter->unset_promisc = netxen_niu_set_promiscuous_mode;
+		adapter->phy_read = netxen_niu_gbe_phy_read;
+		adapter->phy_write = netxen_niu_gbe_phy_write;
+		adapter->init_port = netxen_niu_gbe_init_port;
+		adapter->init_niu = netxen_nic_init_niu_gb;
+		adapter->stop_port = netxen_niu_disable_gbe_port;
 		break;
 
 	case NETXEN_NIC_XGBE:
-		ops->enable_phy_interrupts =
+		adapter->enable_phy_interrupts =
 		    netxen_niu_xgbe_enable_phy_interrupts;
-		ops->disable_phy_interrupts =
+		adapter->disable_phy_interrupts =
 		    netxen_niu_xgbe_disable_phy_interrupts;
-		ops->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
-		ops->macaddr_set = netxen_niu_xg_macaddr_set;
-		ops->set_mtu = netxen_nic_set_mtu_xgb;
-		ops->init_port = netxen_niu_xg_init_port;
-		ops->set_promisc = netxen_niu_xg_set_promiscuous_mode;
-		ops->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
-		ops->stop_port = netxen_niu_disable_xg_port;
+		adapter->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
+		adapter->macaddr_set = netxen_niu_xg_macaddr_set;
+		adapter->set_mtu = netxen_nic_set_mtu_xgb;
+		adapter->init_port = netxen_niu_xg_init_port;
+		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
+		adapter->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
+		adapter->stop_port = netxen_niu_disable_xg_port;
 		break;
 
 	default:
@@ -383,8 +382,8 @@ int netxen_rom_wip_poll(struct netxen_ad
 	return 0;
 }
 
-static inline int do_rom_fast_write(struct netxen_adapter *adapter,
-				    int addr, int data)
+static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
+				    int data)
 {
 	if (netxen_rom_wren(adapter)) {
 		return -1;
@@ -734,8 +733,8 @@ void netxen_watchdog_task(unsigned long
 			netif_wake_queue(netdev);
 	}
 
-	if (adapter->ops->handle_phy_intr)
-		adapter->ops->handle_phy_intr(adapter);
+	if (adapter->handle_phy_intr)
+		adapter->handle_phy_intr(adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
diff --git a/drivers/net/netxen/netxen_nic_ioctl.h b/drivers/net/netxen/netxen_nic_ioctl.h
index 23e53ad..8eef139 100644
--- a/drivers/net/netxen/netxen_nic_ioctl.h
+++ b/drivers/net/netxen/netxen_nic_ioctl.h
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index ae180fe..0f6e7b8 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -84,46 +84,41 @@ void netxen_handle_port_int(struct netxe
 	struct netxen_port *port;
 
 	/*  This should clear the interrupt source */
-	if (adapter->ops->phy_read)
-		adapter->ops->phy_read(adapter, portno,
-				       NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
-				       &int_src);
+	if (adapter->phy_read)
+		adapter->phy_read(adapter, portno,
+				  NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
+				  &int_src);
 	if (int_src == 0) {
 		DPRINTK(INFO, "No phy interrupts for port #%d\n", portno);
 		return;
 	}
-	if (adapter->ops->disable_phy_interrupts)
-		adapter->ops->disable_phy_interrupts(adapter, portno);
+	if (adapter->disable_phy_interrupts)
+		adapter->disable_phy_interrupts(adapter, portno);
 
 	port = adapter->port[portno];
 
 	if (netxen_get_phy_int_jabber(int_src))
-		DPRINTK(INFO, "NetXen: %s Jabber interrupt \n",
-			port->netdev->name);
+		DPRINTK(INFO, "Jabber interrupt \n");
 
 	if (netxen_get_phy_int_polarity_changed(int_src))
-		DPRINTK(INFO, "NetXen: %s POLARITY CHANGED int \n",
-			port->netdev->name);
+		DPRINTK(INFO, "POLARITY CHANGED int \n");
 
 	if (netxen_get_phy_int_energy_detect(int_src))
-		DPRINTK(INFO, "NetXen: %s ENERGY DETECT INT \n",
-			port->netdev->name);
+		DPRINTK(INFO, "ENERGY DETECT INT \n");
 
 	if (netxen_get_phy_int_downshift(int_src))
-		DPRINTK(INFO, "NetXen: %s DOWNSHIFT INT \n",
-			port->netdev->name);
+		DPRINTK(INFO, "DOWNSHIFT INT \n");
 	/* write it down later.. */
 	if ((netxen_get_phy_int_speed_changed(int_src))
 	    || (netxen_get_phy_int_link_status_changed(int_src))) {
 		__le32 status;
 
-		DPRINTK(INFO, "NetXen: %s SPEED CHANGED OR"
-			" LINK STATUS CHANGED \n", port->netdev->name);
+		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
 
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, portno,
-					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					      &status) == 0) {
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, portno,
+					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+					 &status) == 0) {
 			if (netxen_get_phy_int_link_status_changed(int_src)) {
 				if (netxen_get_phy_link(status)) {
 					netxen_niu_gbe_init_port(adapter,
@@ -143,8 +138,8 @@ void netxen_handle_port_int(struct netxe
 			}
 		}
 	}
-	if (adapter->ops->enable_phy_interrupts)
-		adapter->ops->enable_phy_interrupts(adapter, portno);
+	if (adapter->enable_phy_interrupts)
+		adapter->enable_phy_interrupts(adapter, portno);
 }
 
 void netxen_nic_isr_other(struct netxen_adapter *adapter)
@@ -159,8 +154,7 @@ void netxen_nic_isr_other(struct netxen_
 
 	qg_linksup = adapter->ahw.qg_linksup;
 	adapter->ahw.qg_linksup = val;
-	DPRINTK(1, INFO, "%s: link update 0x%08x\n", netxen_nic_driver_name,
-		val);
+	DPRINTK(INFO, "link update 0x%08x\n", val);
 	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
 		linkup = val & 1;
 		if (linkup != (qg_linksup & 1)) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1cb662d..6dbdc8b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1,25 +1,25 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -233,16 +233,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 
 	}
 
-	adapter->ops = kzalloc(sizeof(struct netxen_drvops), GFP_KERNEL);
-	if (adapter->ops == NULL) {
-		printk(KERN_ERR
-		       "%s: Could not allocate memory for adapter->ops:%d\n",
-		       netxen_nic_driver_name,
-		       (int)sizeof(struct netxen_adapter));
-		err = -ENOMEM;
-		goto err_out_free_rx_buffer;
-	}
-
 	adapter->cmd_buf_arr = cmd_buf_arr;
 	adapter->ahw.pci_base0 = mem_ptr0;
 	adapter->ahw.pci_base1 = mem_ptr1;
@@ -373,10 +363,9 @@ netxen_nic_probe(struct pci_dev *pdev, c
 				       netdev->dev_addr[4],
 				       netdev->dev_addr[5]);
 			} else {
-				if (adapter->ops->macaddr_set)
-					adapter->ops->macaddr_set(port,
-								  netdev->
-								  dev_addr);
+				if (adapter->macaddr_set)
+					adapter->macaddr_set(port,
+							     netdev->dev_addr);
 			}
 		}
 		INIT_WORK(&adapter->tx_timeout_task,
@@ -427,7 +416,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 			free_netdev(port->netdev);
 		}
 	}
-	kfree(adapter->ops);
 
       err_out_free_rx_buffer:
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
@@ -525,7 +513,6 @@ static void __devexit netxen_nic_remove(
 	}
 
 	vfree(adapter->cmd_buf_arr);
-	kfree(adapter->ops);
 	kfree(adapter);
 }
 
@@ -557,15 +544,15 @@ static int netxen_nic_open(struct net_de
 			       err);
 			return err;
 		}
-		if (adapter->ops->init_port
-		    && adapter->ops->init_port(adapter, port->portnum) != 0) {
+		if (adapter->init_port
+		    && adapter->init_port(adapter, port->portnum) != 0) {
 			printk(KERN_ERR "%s: Failed to initialize port %d\n",
 			       netxen_nic_driver_name, port->portnum);
 			netxen_free_hw_resources(adapter);
 			return -EIO;
 		}
-		if (adapter->ops->init_niu)
-			adapter->ops->init_niu(adapter);
+		if (adapter->init_niu)
+			adapter->init_niu(adapter);
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
@@ -591,8 +578,8 @@ static int netxen_nic_open(struct net_de
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
-	if (adapter->ops->macaddr_set)
-		adapter->ops->macaddr_set(port, netdev->dev_addr);
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(port, netdev->dev_addr);
 	netxen_nic_set_link_parameters(port);
 
 	netxen_nic_set_multi(netdev);
@@ -1039,11 +1026,12 @@ static int netxen_nic_poll(struct net_de
 	int done = 1;
 	int ctx;
 	int this_work_done;
+	int work_done = 0;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
 	port->stats.polled++;
 
-	adapter->work_done = 0;
+	work_done = 0;
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 		/*
 		 * Fairness issue. This will give undue weight to the
@@ -1060,20 +1048,20 @@ static int netxen_nic_poll(struct net_de
 		this_work_done = netxen_process_rcv_ring(adapter, ctx,
 							 work_to_do /
 							 MAX_RCV_CTX);
-		adapter->work_done += this_work_done;
+		work_done += this_work_done;
 	}
 
-	netdev->quota -= adapter->work_done;
-	*budget -= adapter->work_done;
+	netdev->quota -= work_done;
+	*budget -= work_done;
 
-	if (adapter->work_done >= work_to_do
+	if (work_done >= work_to_do
 	    && netxen_nic_rx_has_work(adapter) != 0)
 		done = 0;
 
 	netxen_process_cmd_ring((unsigned long)adapter);
 
 	DPRINTK(INFO, "new work_done: %d work_to_do: %d\n",
-		adapter->work_done, work_to_do);
+		work_done, work_to_do);
 	if (done) {
 		netif_rx_complete(netdev);
 		netxen_nic_enable_int(adapter);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 7950a04..ff74f1e 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2003 - 2006 NetXen, Inc.
  * All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -16,10 +16,10 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  * MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution
  * in the file called LICENSE.
- * 
+ *
  * Contact Information:
  *    info@netxen.com
  * NetXen,
@@ -399,8 +399,8 @@ int netxen_niu_gbe_init_port(struct netx
 {
 	int result = 0;
 	__le32 status;
-	if (adapter->ops->disable_phy_interrupts)
-		adapter->ops->disable_phy_interrupts(adapter, port);
+	if (adapter->disable_phy_interrupts)
+		adapter->disable_phy_interrupts(adapter, port);
 	mdelay(2);
 
 	if (0 ==
