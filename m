From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 2 Mar 2007 20:37:24 -0500
Message-ID: <20070303013724.GA10681@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34595 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992884AbXCCBh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:37:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixes du jour.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 arch/mips/jmr3927/rbhma3100/setup.c         |    4 -
 arch/mips/momentum/jaguar_atx/platform.c    |   20 +---
 arch/mips/momentum/ocelot_3/platform.c      |   20 +---
 arch/mips/momentum/ocelot_c/platform.c      |   12 +--
 drivers/net/cxgb3/version.h                 |    2 +-
 drivers/net/mv643xx_eth.c                   |    2 +-
 drivers/net/mv643xx_eth.h                   |    4 +-
 drivers/net/myri10ge/myri10ge.c             |   22 ++--
 drivers/net/netxen/netxen_nic.h             |    4 +-
 drivers/net/netxen/netxen_nic_ethtool.c     |  144 +++++----------------------
 drivers/net/netxen/netxen_nic_hw.c          |    5 +-
 drivers/net/netxen/netxen_nic_init.c        |   23 +++--
 drivers/net/netxen/netxen_nic_main.c        |   13 +--
 drivers/net/netxen/netxen_nic_phan_reg.h    |    3 +
 drivers/net/qla3xxx.c                       |    2 +-
 drivers/net/tc35815.c                       |   13 ---
 drivers/net/tulip/de2104x.c                 |    2 +-
 drivers/net/tulip/tulip_core.c              |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |    5 +-
 include/linux/mv643xx.h                     |    2 +-
 20 files changed, 87 insertions(+), 217 deletions(-)

Brice Goglin (1):
      myri10ge: fix copyright and license

Dale Farnsworth (1):
      mv643xx_eth: move mac_addr inside mv643xx_eth_platform_data

Dave Jones (1):
      Fix mv643xx_eth compilation.

Divy Le Ray (1):
      cxgb3 - Tag driver version

Jeff Garzik (1):
      [netdrvr] tulip, de2104x: fix typo: s/__sparc_/__sparc__/

Linsys Contractor Mithlesh Thukral (2):
      NetXen: Updates, removal of unsupported features and minor bug fixes.
      NetXen: Fix second rmmod failure observed on PowerPC machines.

Ralf Baechle (1):
      jmr3927: do not call tc35815_killall().

Ron Mercer (1):
      qla3xxx: bugfix for line omitted in previous patch.

Stefano Brivio (1):
      bcm43xx: fix for 4309

diff --git a/arch/mips/jmr3927/rbhma3100/setup.c b/arch/mips/jmr3927/rbhma3100/setup.c
index 7ca3d6d..ecabe5b 100644
--- a/arch/mips/jmr3927/rbhma3100/setup.c
+++ b/arch/mips/jmr3927/rbhma3100/setup.c
@@ -137,10 +137,6 @@ int jmr3927_ccfg_toeon = 0;
 
 static inline void do_reset(void)
 {
-#ifdef CONFIG_TC35815
-	extern void tc35815_killall(void);
-	tc35815_killall();
-#endif
 #if 1	/* Resetting PCI bus */
 	jmr3927_ioc_reg_out(0, JMR3927_IOC_RESET_ADDR);
 	jmr3927_ioc_reg_out(JMR3927_IOC_RESET_PCI, JMR3927_IOC_RESET_ADDR);
diff --git a/arch/mips/momentum/jaguar_atx/platform.c b/arch/mips/momentum/jaguar_atx/platform.c
index 3df36ed..771e55f 100644
--- a/arch/mips/momentum/jaguar_atx/platform.c
+++ b/arch/mips/momentum/jaguar_atx/platform.c
@@ -47,11 +47,7 @@ static struct resource mv64x60_eth0_resources[] = {
 	},
 };
 
-static char eth0_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth0_pd = {
-	.mac_addr	= eth0_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -80,11 +76,7 @@ static struct resource mv64x60_eth1_resources[] = {
 	},
 };
 
-static char eth1_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth1_pd = {
-	.mac_addr	= eth1_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -113,11 +105,7 @@ static struct resource mv64x60_eth2_resources[] = {
 	},
 };
 
-static char eth2_mac_addr[ETH_ALEN];
-
-static struct mv643xx_eth_platform_data eth2_pd = {
-	.mac_addr	= eth2_mac_addr,
-};
+static struct mv643xx_eth_platform_data eth2_pd;
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -200,9 +188,9 @@ static int __init mv643xx_eth_add_pds(void)
 	int ret;
 
 	get_mac(mac);
-	eth_mac_add(eth0_mac_addr, mac, 0);
-	eth_mac_add(eth1_mac_addr, mac, 1);
-	eth_mac_add(eth2_mac_addr, mac, 2);
+	eth_mac_add(eth0_pd.mac_addr, mac, 0);
+	eth_mac_add(eth1_pd.mac_addr, mac, 1);
+	eth_mac_add(eth2_pd.mac_addr, mac, 2);
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
diff --git a/arch/mips/momentum/ocelot_3/platform.c b/arch/mips/momentum/ocelot_3/platform.c
index 024aef2..b80733f 100644
--- a/arch/mips/momentum/ocelot_3/platform.c
+++ b/arch/mips/momentum/ocelot_3/platform.c
@@ -47,11 +47,7 @@ static struct resource mv64x60_eth0_resources[] = {
 	},
 };
 
-static char eth0_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth0_pd = {
-	.mac_addr	= eth0_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -80,11 +76,7 @@ static struct resource mv64x60_eth1_resources[] = {
 	},
 };
 
-static char eth1_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth1_pd = {
-	.mac_addr	= eth1_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -113,11 +105,7 @@ static struct resource mv64x60_eth2_resources[] = {
 	},
 };
 
-static char eth2_mac_addr[ETH_ALEN];
-
-static struct mv643xx_eth_platform_data eth2_pd = {
-	.mac_addr	= eth2_mac_addr,
-};
+static struct mv643xx_eth_platform_data eth2_pd;
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -200,9 +188,9 @@ static int __init mv643xx_eth_add_pds(void)
 	int ret;
 
 	get_mac(mac);
-	eth_mac_add(eth0_mac_addr, mac, 0);
-	eth_mac_add(eth1_mac_addr, mac, 1);
-	eth_mac_add(eth2_mac_addr, mac, 2);
+	eth_mac_add(eth0_pd.mac_addr, mac, 0);
+	eth_mac_add(eth1_pd.mac_addr, mac, 1);
+	eth_mac_add(eth2_pd.mac_addr, mac, 2);
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
diff --git a/arch/mips/momentum/ocelot_c/platform.c b/arch/mips/momentum/ocelot_c/platform.c
index fac8b24..f7cd303 100644
--- a/arch/mips/momentum/ocelot_c/platform.c
+++ b/arch/mips/momentum/ocelot_c/platform.c
@@ -46,11 +46,7 @@ static struct resource mv64x60_eth0_resources[] = {
 	},
 };
 
-static char eth0_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth0_pd = {
-	.mac_addr	= eth0_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -79,11 +75,7 @@ static struct resource mv64x60_eth1_resources[] = {
 	},
 };
 
-static char eth1_mac_addr[ETH_ALEN];
-
 static struct mv643xx_eth_platform_data eth1_pd = {
-	.mac_addr	= eth1_mac_addr,
-
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -174,8 +166,8 @@ static int __init mv643xx_eth_add_pds(void)
 	int ret;
 
 	get_mac(mac);
-	eth_mac_add(eth0_mac_addr, mac, 0);
-	eth_mac_add(eth1_mac_addr, mac, 1);
+	eth_mac_add(eth0_pd.mac_addr, mac, 0);
+	eth_mac_add(eth1_pd.mac_addr, mac, 1);
 	ret = platform_add_devices(mv643xx_eth_pd_devs,
 			ARRAY_SIZE(mv643xx_eth_pd_devs));
 
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 782a6cf..82278f8 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -35,7 +35,7 @@
 #define DRV_DESC "Chelsio T3 Network Driver"
 #define DRV_NAME "cxgb3"
 /* Driver version */
-#define DRV_VERSION "1.0"
+#define DRV_VERSION "1.0-ko"
 #define FW_VERSION_MAJOR 3
 #define FW_VERSION_MINOR 2
 #endif				/* __CHELSIO_VERSION_H */
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3e045a6..be2ddbb 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1380,7 +1380,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	pd = pdev->dev.platform_data;
 	if (pd) {
-		if (pd->mac_addr)
+		if (is_valid_ether_addr(pd->mac_addr))
 			memcpy(dev->dev_addr, pd->mac_addr, 6);
 
 		if (pd->phy_addr || pd->force_phy_addr)
diff --git a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
index 7cb0a41..7d4e90c 100644
--- a/drivers/net/mv643xx_eth.h
+++ b/drivers/net/mv643xx_eth.h
@@ -9,6 +9,8 @@
 
 #include <linux/mv643xx.h>
 
+#include <asm/dma-mapping.h>
+
 /* Checksum offload for Tx works for most packets, but
  * fails if previous packet sent did not use hw csum
  */
@@ -47,7 +49,7 @@
 #define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
 #define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
 					ETH_VLAN_HLEN + ETH_FCS_LEN)
-#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + ETH_DMA_ALIGN)
+#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + dma_get_cache_alignment())
 
 #define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
 #define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 954842e..b05dc6e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1,7 +1,7 @@
 /*************************************************************************
  * myri10ge.c: Myricom Myri-10G Ethernet driver.
  *
- * Copyright (C) 2005, 2006 Myricom, Inc.
+ * Copyright (C) 2005 - 2007 Myricom, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -16,17 +16,17 @@
  *    may be used to endorse or promote products derived from this software
  *    without specific prior written permission.
  *
- * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
- * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
- * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
- * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
- * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
- * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
- * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
- * SUCH DAMAGE.
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
  *
  *
  * If the eeprom on your board is not recent enough, you will need to get a
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2807ef4..81742e4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -72,6 +72,8 @@
 #define FLASH_SECTOR_SIZE (64 * 1024)
 #define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
 
+#define PHAN_VENDOR_ID 0x4040
+
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
 #define STATUS_DESC_RINGSIZE	\
@@ -82,7 +84,7 @@
 	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
 #define RCV_BUFFSIZE	\
 	(sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
-#define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
+#define find_diff_among(a,b,range) ((a)<=(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_NETDEV_STATUS		0x1
 #define NETXEN_RCV_PRODUCER_OFFSET	0
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6252e9a..986ef98 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -82,8 +82,7 @@ static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
 #define NETXEN_NIC_STATS_LEN	ARRAY_SIZE(netxen_nic_gstrings_stats)
 
 static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
-	"Register_Test_offline", "EEPROM_Test_offline",
-	"Interrupt_Test_offline", "Loopback_Test_offline",
+	"Register_Test_on_offline",
 	"Link_Test_on_offline"
 };
 
@@ -394,19 +393,12 @@ netxen_nic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 	}
 }
 
-static void
-netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
-	/* options can be added depending upon the mode */
-	wol->wolopts = 0;
-}
-
 static u32 netxen_nic_test_link(struct net_device *dev)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
 	__u32 status;
+	int val;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -415,11 +407,13 @@ static u32 netxen_nic_test_link(struct net_device *dev)
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
-		else
-			return (netxen_get_phy_link(status));
+		else {
+			val = netxen_get_phy_link(status);
+			return !val;
+		}
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
-		int val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-		return val == XG_LINK_UP;
+		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+		return (val == XG_LINK_UP) ? 0 : 1;
 	}
 	return -EIO;
 }
@@ -606,100 +600,21 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 
 static int netxen_nic_reg_test(struct net_device *dev)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
-	u32 data_read, data_written, save;
-	__u32 mode;
-
-	/* 
-	 * first test the "Read Only" registers by writing which mode
-	 */
-	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
-	if (netxen_get_niu_enable_ge(mode)) {	/* GB Mode */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
-				   &data_read);
-
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
-								  portnum),
-				    data_written);
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
-				   &data_read);
-
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
-									  portnum),
-					    save);
-
-			return 0;
-		}
-
-		/* netxen_niu_gb_mii_mgmt_indicators is read only */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								   portnum),
-				   &data_read);
-
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								    portnum),
-				    data_written);
-
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								   portnum),
-				   &data_read);
-
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_MII_MGMT_INDICATE
-					    (port->portnum), save);
-			return 0;
-		}
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	u32 data_read, data_written;
 
-		/* netxen_niu_gb_interface_status is read only */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								  portnum),
-				   &data_read);
+	netxen_nic_read_w0(adapter, NETXEN_PCIX_PH_REG(0), &data_read);
+	if ((data_read & 0xffff) != PHAN_VENDOR_ID)
+	return 1;
 
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								   portnum),
-				    data_written);
+	data_written = (u32)0xa5a5a5a5;
 
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								  portnum),
-				   &data_read);
+	netxen_nic_reg_write(adapter, CRB_SCRATCHPAD_TEST, data_written);
+	data_read = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_SCRATCHPAD_TEST));
+	if (data_written != data_read)
+		return 1;
 
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_INTERFACE_STATUS
-					    (port->portnum), save);
-
-			return 0;
-		}
-	}			/* GB Mode */
-	return 1;
+	return 0;
 }
 
 static int netxen_nic_diag_test_count(struct net_device *dev)
@@ -713,26 +628,20 @@ netxen_nic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 {
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {	/* offline tests */
 		/* link test */
-		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
+		if ((data[1] = (u64) netxen_nic_test_link(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		if (netif_running(dev))
-			dev->stop(dev);
-
 		/* register tests */
-		if (!(data[0] = netxen_nic_reg_test(dev)))
+		if ((data[0] = netxen_nic_reg_test(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-		/* other tests pass as of now */
-		data[1] = data[2] = data[3] = 1;
-		if (netif_running(dev))
-			dev->open(dev);
 	} else {		/* online tests */
-		/* link test */
-		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
+		/* register tests */
+		if((data[0] = netxen_nic_reg_test(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* other tests pass by default */
-		data[0] = data[1] = data[2] = data[3] = 1;
+		/* link test */
+		if ((data[1] = (u64) netxen_nic_test_link(dev)))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
 
@@ -783,7 +692,6 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_drvinfo = netxen_nic_get_drvinfo,
 	.get_regs_len = netxen_nic_get_regs_len,
 	.get_regs = netxen_nic_get_regs,
-	.get_wol = netxen_nic_get_wol,
 	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index deec796..a2877f3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -508,8 +508,8 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 void netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	int i;
-	long data, size = 0;
-	long flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
+	u32 data, size = 0;
+	u32 flashaddr = NETXEN_FLASH_BASE, memaddr = NETXEN_PHANTOM_MEM_BASE;
 	u64 off;
 	void __iomem *addr;
 
@@ -951,6 +951,7 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 				       netxen_nic_driver_name);
 				return;
 			}
+			*ptr32 = le32_to_cpu(*ptr32);
 			ptr32++;
 			addr += sizeof(u32);
 		}
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 2f96570..586d32b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -38,13 +38,13 @@
 #include "netxen_nic_phan_reg.h"
 
 struct crb_addr_pair {
-	long addr;
-	long data;
+	u32 addr;
+	u32 data;
 };
 
 #define NETXEN_MAX_CRB_XFORM 60
 static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
-#define NETXEN_ADDR_ERROR ((unsigned long ) 0xffffffff )
+#define NETXEN_ADDR_ERROR (0xffffffff)
 
 #define crb_addr_transform(name) \
 	crb_addr_xform[NETXEN_HW_PX_MAP_CRB_##name] = \
@@ -252,10 +252,10 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
  * netxen_decode_crb_addr(0 - utility to translate from internal Phantom CRB
  * address to external PCI CRB address.
  */
-unsigned long netxen_decode_crb_addr(unsigned long addr)
+u32 netxen_decode_crb_addr(u32 addr)
 {
 	int i;
-	unsigned long base_addr, offset, pci_base;
+	u32 base_addr, offset, pci_base;
 
 	crb_addr_transform_setup();
 
@@ -756,7 +756,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 	int n, i;
 	int init_delay = 0;
 	struct crb_addr_pair *buf;
-	unsigned long off;
+	u32 off;
 
 	/* resetall */
 	status = netxen_nic_get_board_info(adapter);
@@ -813,14 +813,13 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			if (verbose)
 				printk("%s: PCI:     0x%08x == 0x%08x\n",
 				       netxen_nic_driver_name, (unsigned int)
-				       netxen_decode_crb_addr((unsigned long)
-							      addr), val);
+				       netxen_decode_crb_addr(addr), val);
 		}
 		for (i = 0; i < n; i++) {
 
-			off = netxen_decode_crb_addr((unsigned long)buf[i].addr);
+			off = netxen_decode_crb_addr(buf[i].addr);
 			if (off == NETXEN_ADDR_ERROR) {
-				printk(KERN_ERR"CRB init value out of range %lx\n",
+				printk(KERN_ERR"CRB init value out of range %x\n",
 					buf[i].addr);
 				continue;
 			}
@@ -927,6 +926,10 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
 	if (adapter->dummy_dma.addr) {
+		writel(0, NETXEN_CRB_NORMALIZE(adapter,
+			CRB_HOST_DUMMY_BUF_ADDR_HI));
+		writel(0, NETXEN_CRB_NORMALIZE(adapter,
+			CRB_HOST_DUMMY_BUF_ADDR_LO));
 		pci_free_consistent(adapter->ahw.pdev,
 				    NETXEN_HOST_DUMMY_DMA_SIZE,
 				    adapter->dummy_dma.addr,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1bf3d49..7d2525e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -42,8 +42,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
 
-#define PHAN_VENDOR_ID 0x4040
-
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
@@ -379,6 +377,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->tx_timeout = netxen_tx_timeout;
 		netdev->watchdog_timeo = HZ;
 
+		netxen_nic_change_mtu(netdev, netdev->mtu);
+
 		SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
 		netdev->poll = netxen_nic_poll;
 		netdev->weight = NETXEN_NETDEV_WEIGHT;
@@ -434,13 +434,11 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->port_count++;
 		adapter->port[i] = port;
 	}
-#ifndef CONFIG_PPC64
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_pinit_from_rom(adapter, 0);
 	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-#endif
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
@@ -529,12 +527,13 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		free_irq(adapter->irq, adapter);
 	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
-	netxen_pinit_from_rom(adapter, 0);
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	netxen_pinit_from_rom(adapter, 0);
+	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_free_adapter_offload(adapter);
 
-	udelay(500);		/* Delay for a while to drain the DMA engines */
+	mdelay(1000);		/* Delay for a while to drain the DMA engines */
 	for (i = 0; i < adapter->port_count; i++) {
 		port = adapter->port[i];
 		if ((port) && (port->netdev)) {
@@ -545,7 +544,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
 		pci_disable_msi(pdev);
-	pci_set_drvdata(pdev, NULL);
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		netxen_free_hw_resources(adapter);
 
@@ -556,6 +554,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
 
 	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
 		recv_ctx = &adapter->recv_ctx[ctxid];
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 7879f85..0c7c943 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -102,6 +102,9 @@
 #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
 #define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
 
+/* used for ethtool tests */
+#define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
+
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
  * which can be read by the Phantom host to get producer/consumer indexes from
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 3a14d19..d3f65da 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2210,7 +2210,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 {
 	struct oal *oal;
 	struct oal_entry *oal_entry;
-	int len = skb->len;
+	int len = skb_headlen(skb);
 	dma_addr_t map;
 	int err;
 	int completed_segs, i;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index eae2b63..e3a7e3c 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1703,19 +1703,6 @@ static void tc35815_chip_init(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-/* XXX */
-void
-tc35815_killall(void)
-{
-	struct net_device *dev;
-
-	for (dev = root_tc35815_dev; dev; dev = ((struct tc35815_local *)dev->priv)->next_module) {
-		if (dev->flags&IFF_UP){
-			dev->stop(dev);
-		}
-	}
-}
-
 static struct pci_driver tc35815_driver = {
 	.name = TC35815_MODULE_NAME,
 	.probe = tc35815_probe,
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9d67f11..dacea4f 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -63,7 +63,7 @@ MODULE_PARM_DESC (debug, "de2104x bitmapped message enable number");
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-        || defined(__sparc_) || defined(__ia64__) \
+        || defined(__sparc__) || defined(__ia64__) \
         || defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 5a35354..e3774a5 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -67,7 +67,7 @@ const char * const medianame[32] = {
 
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
-	|| defined(__sparc_) || defined(__ia64__) \
+	|| defined(__sparc__) || defined(__ia64__) \
 	|| defined(__sh__) || defined(__mips__)
 static int rx_copybreak = 1518;
 #else
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 73c831a..e594af4 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2733,8 +2733,9 @@ static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
 				 * dangling pins on the second core. Be careful
 				 * and ignore these cores here.
 				 */
-				if (bcm->pci_dev->device != 0x4324) {
-					dprintk(KERN_INFO PFX "Ignoring additional 802.11 core.\n");
+				if (1 /*bcm->pci_dev->device != 0x4324*/ ) {
+				/* TODO: A PHY */
+					dprintk(KERN_INFO PFX "Ignoring additional 802.11a core.\n");
 					continue;
 				}
 			}
diff --git a/include/linux/mv643xx.h b/include/linux/mv643xx.h
index aff25c0..e7d4da1 100644
--- a/include/linux/mv643xx.h
+++ b/include/linux/mv643xx.h
@@ -1288,7 +1288,6 @@ struct mv64xxx_i2c_pdata {
 #define MV643XX_ETH_NAME	"mv643xx_eth"
 
 struct mv643xx_eth_platform_data {
-	char		*mac_addr;	/* pointer to mac address */
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 
@@ -1303,6 +1302,7 @@ struct mv643xx_eth_platform_data {
 	u32		tx_sram_size;
 	u32		rx_sram_addr;
 	u32		rx_sram_size;
+	u8		mac_addr[6];	/* mac address if non-zero*/
 };
 
 #endif /* __ASM_MV643XX_H */
