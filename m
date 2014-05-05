From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v4 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Mon,  5 May 2014 14:47:27 -0700
Message-ID: <1399326447-2329-5-git-send-email-isubramanian@apm.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com>
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399326447-2329-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds network driver for APM X-Gene SoC ethernet.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/apm/Kconfig                 |    1 +
 drivers/net/ethernet/apm/Makefile                |    5 +
 drivers/net/ethernet/apm/xgene/Kconfig           |    9 +
 drivers/net/ethernet/apm/xgene/Makefile          |    6 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  807 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |  353 ++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  936 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  131 +++
 10 files changed, 2250 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 39b26fe..871a438 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/ethernet/allwinner/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/altera/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
+source "drivers/net/ethernet/apm/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/arc/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 545d0b3..291df52 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_ALLWINNER) += allwinner/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_ALTERA_TSE) += altera/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
+obj-$(CONFIG_NET_XGENE) += apm/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ARC) += arc/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
diff --git a/drivers/net/ethernet/apm/Kconfig b/drivers/net/ethernet/apm/Kconfig
new file mode 100644
index 0000000..ec63d70
--- /dev/null
+++ b/drivers/net/ethernet/apm/Kconfig
@@ -0,0 +1 @@
+source "drivers/net/ethernet/apm/xgene/Kconfig"
diff --git a/drivers/net/ethernet/apm/Makefile b/drivers/net/ethernet/apm/Makefile
new file mode 100644
index 0000000..65ce32a
--- /dev/null
+++ b/drivers/net/ethernet/apm/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for APM X-GENE Ethernet driver.
+#
+
+obj-$(CONFIG_NET_XGENE) += xgene/
diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
new file mode 100644
index 0000000..616dff6
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/Kconfig
@@ -0,0 +1,9 @@
+config NET_XGENE
+	tristate "APM X-Gene SoC Ethernet Driver"
+	select PHYLIB
+	help
+	  This is the Ethernet driver for the on-chip ethernet interface on the
+	  APM X-Gene SoC.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called xgene_enet.
diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
new file mode 100644
index 0000000..60de5fa
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for APM X-Gene Ethernet Driver.
+#
+
+xgene-enet-objs := xgene_enet_hw.o xgene_enet_main.o
+obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
new file mode 100644
index 0000000..421a841
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -0,0 +1,807 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_hw.h"
+
+struct xgene_enet_desc_info desc_info[MAX_DESC_INFO_INDEX] = {
+	[USERINFO] = {0, USERINFO_POS, USERINFO_LEN},
+	[FPQNUM] = {0, FPQNUM_POS, FPQNUM_LEN},
+	[STASH] = {0, STASH_POS, STASH_LEN},
+	[DATAADDR] = {1, DATAADDR_POS, DATAADDR_LEN},
+	[BUFDATALEN] = {1, BUFDATALEN_POS, BUFDATALEN_LEN},
+	[BUFLEN] = {1, BUFLEN_POS, BUFLEN_LEN},
+	[COHERENT] = {1, COHERENT_POS, COHERENT_LEN},
+	[TCPHDR] = {3, TCPHDR_POS, TCPHDR_LEN},
+	[IPHDR] = {3, IPHDR_POS, IPHDR_LEN},
+	[ETHHDR] = {3, ETHHDR_POS, ETHHDR_LEN},
+	[EC] = {3, EC_POS, EC_LEN},
+	[IS] = {3, IS_POS, IS_LEN},
+	[IC] = {3, IC_POS, IC_LEN},
+	[TYPESEL] = {3, TYPESEL_POS, TYPESEL_LEN},
+	[HENQNUM] = {3, HENQNUM_POS, HENQNUM_LEN},
+};
+
+void set_desc(void *desc_ptr, enum desc_info_index index, u64 val)
+{
+	u64 *desc;
+	u8 i, start_bit, len;
+	u64 mask;
+
+	desc = desc_ptr;
+	i = desc_info[index].word_index;
+	start_bit = desc_info[index].start_bit;
+	len = desc_info[index].len;
+	mask = GENMASK_ULL((start_bit + len - 1), start_bit);
+	desc[i] = (desc[i] & ~mask) | ((val << start_bit) & mask);
+}
+
+u64 get_desc(void *desc_ptr, enum desc_info_index index)
+{
+	u64 *desc;
+	u8 i, start_bit, len;
+	u64 mask;
+
+	desc = desc_ptr;
+	i = desc_info[index].word_index;
+	start_bit = desc_info[index].start_bit;
+	len = desc_info[index].len;
+	mask = GENMASK_ULL((start_bit + len - 1), start_bit);
+
+	return (desc[i] & mask) >> start_bit;
+}
+
+static void xgene_enet_ring_init(struct xgene_enet_desc_ring *ring)
+{
+	u32 *ring_cfg = ring->state;
+	u64 addr = ring->dma;
+	enum xgene_enet_ring_cfgsize cfgsize = ring->cfgsize;
+
+	ring_cfg[4] |= (1 << SELTHRSH_POS) &
+			CREATE_MASK(SELTHRSH_POS, SELTHRSH_LEN);
+	ring_cfg[3] |= ACCEPTLERR;
+	ring_cfg[2] |= QCOHERENT;
+
+	addr >>= 8;
+	ring_cfg[2] |= (addr << RINGADDRL_POS) &
+			CREATE_MASK_ULL(RINGADDRL_POS, RINGADDRL_LEN);
+	addr >>= RINGADDRL_LEN;
+	ring_cfg[3] |= addr & CREATE_MASK_ULL(RINGADDRH_POS, RINGADDRH_LEN);
+	ring_cfg[3] |= ((u32) cfgsize << RINGSIZE_POS) &
+			CREATE_MASK(RINGSIZE_POS, RINGSIZE_LEN);
+}
+
+static void xgene_enet_ring_set_type(struct xgene_enet_desc_ring *ring)
+{
+	u32 *ring_cfg = ring->state;
+	bool is_bufpool = IS_FP(ring->id);
+	u32 val;
+
+	val = (is_bufpool) ? RING_BUFPOOL : RING_REGULAR;
+	ring_cfg[4] |= (val << RINGTYPE_POS) &
+			CREATE_MASK(RINGTYPE_POS, RINGTYPE_LEN);
+
+	if (is_bufpool) {
+		ring_cfg[3] |= (BUFPOOL_MODE << RINGMODE_POS) &
+				CREATE_MASK(RINGMODE_POS, RINGMODE_LEN);
+	}
+}
+
+static void xgene_enet_ring_set_recombbuf(struct xgene_enet_desc_ring *ring)
+{
+	u32 *ring_cfg = ring->state;
+
+	ring_cfg[3] |= RECOMBBUF;
+	ring_cfg[3] |= (0xf << RECOMTIMEOUTL_POS) &
+			CREATE_MASK(RECOMTIMEOUTL_POS, RECOMTIMEOUTL_LEN);
+	ring_cfg[4] |= 0x7 & CREATE_MASK(RECOMTIMEOUTH_POS, RECOMTIMEOUTH_LEN);
+}
+
+static void xgene_enet_ring_wr32(struct xgene_enet_desc_ring *ring,
+					u32 offset, u32 data)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+
+	iowrite32(data, pdata->ring_csr_addr + offset);
+}
+
+static void xgene_enet_ring_rd32(struct xgene_enet_desc_ring *ring,
+					u32 offset, u32 *data)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+
+	*data = ioread32(pdata->ring_csr_addr + offset);
+}
+
+static void xgene_enet_write_ring_state(struct xgene_enet_desc_ring *ring)
+{
+	int i;
+
+	xgene_enet_ring_wr32(ring, CSR_RING_CONFIG, ring->num);
+	for (i = 0; i < NUM_RING_CONFIG; i++) {
+		xgene_enet_ring_wr32(ring, CSR_RING_WR_BASE + (i * 4),
+				     ring->state[i]);
+	}
+}
+
+static void xgene_enet_clr_ring_state(struct xgene_enet_desc_ring *ring)
+{
+	memset(ring->state, 0, sizeof(u32) * NUM_RING_CONFIG);
+	xgene_enet_write_ring_state(ring);
+}
+
+static void xgene_enet_set_ring_state(struct xgene_enet_desc_ring *ring)
+{
+	xgene_enet_ring_set_type(ring);
+
+	if (RING_OWNER(ring) == RING_OWNER_ETH0)
+		xgene_enet_ring_set_recombbuf(ring);
+
+	xgene_enet_ring_init(ring);
+	xgene_enet_write_ring_state(ring);
+}
+
+static void xgene_enet_set_ring_id(struct xgene_enet_desc_ring *ring)
+{
+	u32 ring_id_val, ring_id_buf;
+	bool is_bufpool;
+
+	is_bufpool = IS_FP(ring->id);
+
+	ring_id_val = ring->id & GENMASK(9, 0);
+	ring_id_val |= OVERWRITE;
+
+	ring_id_buf = (ring->num << 9) & GENMASK(18, 9);
+	ring_id_buf |= PREFETCH_BUF_EN;
+	if (is_bufpool)
+		ring_id_buf |= IS_BUFFER_POOL;
+
+	xgene_enet_ring_wr32(ring, CSR_RING_ID, ring_id_val);
+	xgene_enet_ring_wr32(ring, CSR_RING_ID_BUF, ring_id_buf);
+}
+
+static void xgene_enet_clr_desc_ring_id(struct xgene_enet_desc_ring *ring)
+{
+	u32 ring_id;
+
+	ring_id = ring->id | OVERWRITE;
+	xgene_enet_ring_wr32(ring, CSR_RING_ID, ring_id);
+	xgene_enet_ring_wr32(ring, CSR_RING_ID_BUF, 0);
+}
+
+struct xgene_enet_desc_ring *xgene_enet_setup_ring(
+					struct xgene_enet_desc_ring *ring)
+{
+	u32 size = ring->size;
+	u32 i, data;
+	u64 *desc;
+
+	xgene_enet_clr_ring_state(ring);
+	xgene_enet_set_ring_state(ring);
+	xgene_enet_set_ring_id(ring);
+
+	ring->slots = IS_FP(ring->id) ? size / 16 : size / 32;
+
+	if (IS_FP(ring->id) || RING_OWNER(ring) != RING_OWNER_CPU)
+		goto out;
+
+	for (i = 0; i < ring->slots; i++) {
+		desc = (u64 *)&ring->desc[i];
+		desc[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+	}
+
+	xgene_enet_ring_rd32(ring, CSR_RING_NE_INT_MODE, &data);
+	data |= (1 << (31 - RING_BUFNUM(ring)));
+	xgene_enet_ring_wr32(ring, CSR_RING_NE_INT_MODE, data);
+
+out:
+	return ring;
+}
+
+void xgene_enet_clear_ring(struct xgene_enet_desc_ring *ring)
+{
+	u32 data;
+
+	if (IS_FP(ring->id) || RING_OWNER(ring) != RING_OWNER_CPU)
+		goto out;
+
+	xgene_enet_ring_rd32(ring, CSR_RING_NE_INT_MODE, &data);
+	data &= ~(u32) (1 << (31 - RING_BUFNUM(ring)));
+	xgene_enet_ring_wr32(ring, CSR_RING_NE_INT_MODE, data);
+
+out:
+	xgene_enet_clr_desc_ring_id(ring);
+	xgene_enet_clr_ring_state(ring);
+}
+
+static void xgene_enet_wr_csr(struct xgene_enet_pdata *pdata,
+			      u32 offset, u32 val)
+{
+	void *addr = pdata->eth_csr_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static void xgene_enet_wr_ring_if(struct xgene_enet_pdata *pdata,
+				  u32 offset, u32 val)
+{
+	void *addr = pdata->eth_ring_if_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static void xgene_enet_wr_diag_csr(struct xgene_enet_pdata *pdata,
+				   u32 offset, u32 val)
+{
+	void *addr = pdata->eth_diag_csr_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static void xgene_enet_wr_mcx_csr(struct xgene_enet_pdata *pdata,
+				  u32 offset, u32 val)
+{
+	void *addr = pdata->mcx_mac_csr_addr + offset;
+
+	iowrite32(val, addr);
+}
+
+static u32 xgene_enet_wr_indirect(void *addr, void *wr, void *cmd,
+				  void *cmd_done, u32 wr_addr, u32 wr_data)
+{
+	u32 cmd_done_val;
+
+	iowrite32(wr_addr, addr);
+	iowrite32(wr_data, wr);
+	iowrite32(XGENE_ENET_WR_CMD, cmd);
+	udelay(5);		/* wait 5 us for completion */
+	cmd_done_val = ioread32(cmd_done);
+	iowrite32(0, cmd);
+	return cmd_done_val;
+}
+
+static void xgene_enet_wr_mcx_mac(struct xgene_enet_pdata *pdata,
+				  u32 wr_addr, u32 wr_data)
+{
+	void *addr, *wr, *cmd, *cmd_done;
+	int ret;
+
+	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
+	wr = pdata->mcx_mac_addr + MAC_WRITE_REG_OFFSET;
+	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+
+	ret = xgene_enet_wr_indirect(addr, wr, cmd, cmd_done, wr_addr, wr_data);
+	if (!ret)
+		netdev_err(pdata->ndev, "MCX mac write failed, addr: %04x\n",
+			   wr_addr);
+}
+
+static void xgene_enet_rd_csr(struct xgene_enet_pdata *pdata,
+			      u32 offset, u32 *val)
+{
+	void *addr = pdata->eth_csr_addr + offset;
+
+	*val = ioread32(addr);
+}
+
+static void xgene_enet_rd_diag_csr(struct xgene_enet_pdata *pdata,
+				   u32 offset, u32 *val)
+{
+	void *addr = pdata->eth_diag_csr_addr + offset;
+
+	*val = ioread32(addr);
+}
+
+static void xgene_enet_rd_mcx_csr(struct xgene_enet_pdata *pdata,
+				  u32 offset, u32 *val)
+{
+	void *addr = pdata->mcx_mac_csr_addr + offset;
+
+	*val = ioread32(addr);
+}
+
+static u32 xgene_enet_rd_indirect(void *addr, void *rd, void *cmd,
+				  void *cmd_done, u32 rd_addr, u32 *rd_data)
+{
+	u32 cmd_done_val;
+
+	iowrite32(rd_addr, addr);
+	iowrite32(XGENE_ENET_RD_CMD, cmd);
+	udelay(5);		/* wait 5 us for completion */
+	cmd_done_val = ioread32(cmd_done);
+	*rd_data = ioread32(rd);
+	iowrite32(0, cmd);
+
+	return cmd_done_val;
+}
+
+static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
+				  u32 rd_addr, u32 *rd_data)
+{
+	void *addr, *rd, *cmd, *cmd_done;
+	int ret;
+
+	addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
+	rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
+	cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
+
+	ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
+	if (!ret)
+		netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
+			   rd_addr);
+}
+
+static void xgene_enet_rd_mcx_stats(struct xgene_enet_pdata *pdata,
+				    u32 rd_addr, u32 *rd_data)
+{
+	void *addr, *rd, *cmd, *cmd_done;
+	int ret;
+
+	addr = pdata->mcx_stats_addr + STAT_ADDR_REG_OFFSET;
+	rd = pdata->mcx_stats_addr + STAT_READ_REG_OFFSET;
+	cmd = pdata->mcx_stats_addr + STAT_COMMAND_REG_OFFSET;
+	cmd_done = pdata->mcx_stats_addr + STAT_COMMAND_DONE_REG_OFFSET;
+
+	ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
+	if (!ret)
+		netdev_err(pdata->ndev, "MCX stats read failed, addr: %04x\n",
+			   rd_addr);
+}
+
+void xgene_genericmiiphy_write(struct xgene_enet_pdata *pdata, int phy_id,
+			       u32 reg, u16 data)
+{
+	u32 addr = 0, wr_data = 0, done;
+
+	PHY_ADDR_SET(&addr, phy_id);
+	REG_ADDR_SET(&addr, reg);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+
+	PHY_CONTROL_SET(&wr_data, data);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONTROL_ADDR, wr_data);
+
+	usleep_range(20, 30);		/* wait 20 us for completion */
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+	if (done & BUSY_MASK)
+		netdev_err(pdata->ndev, "MII_MGMT write failed\n");
+}
+
+void xgene_genericmiiphy_read(struct xgene_enet_pdata *pdata, u8 phy_id,
+			      u32 reg, u32 *data)
+{
+	u32 addr = 0, done;
+
+	PHY_ADDR_SET(&addr, phy_id);
+	REG_ADDR_SET(&addr, reg);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, addr);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, READ_CYCLE_MASK);
+
+	usleep_range(20, 30);		/* wait 20 us for completion */
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_INDICATORS_ADDR, &done);
+	if (done & BUSY_MASK)
+		netdev_err(pdata->ndev, "MII_MGMT read failed\n");
+
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_STATUS_ADDR, data);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, 0);
+}
+
+void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata)
+{
+	u32 addr0, addr1;
+	u8 *dev_addr = pdata->ndev->dev_addr;
+
+	addr0 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
+		(dev_addr[1] << 8) | dev_addr[0];
+	addr1 = (dev_addr[5] << 24) | (dev_addr[4] << 16);
+	addr1 |= pdata->phy_addr & 0xFFFF;
+
+	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR0_ADDR, addr0);
+	xgene_enet_wr_mcx_mac(pdata, STATION_ADDR1_ADDR, addr1);
+}
+
+static int xgene_enet_ecc_init(struct xgene_enet_pdata *pdata)
+{
+	struct net_device *ndev = pdata->ndev;
+	u32 data;
+
+	xgene_enet_wr_diag_csr(pdata, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0x0);
+	usleep_range(1000, 1100);		/* wait 1 ms for completion */
+	xgene_enet_rd_diag_csr(pdata, ENET_BLOCK_MEM_RDY_ADDR, &data);
+	if (data != 0xffffffff) {
+		netdev_err(ndev, "Failed to release memory from shutdown\n");
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void xgene_gmac_phy_enable_scan_cycle(struct xgene_enet_pdata *pdata,
+					     int enable)
+{
+	u32 val;
+
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, &val);
+	SCAN_CYCLE_MASK_SET(&val, enable);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_COMMAND_ADDR, val);
+
+	/* Program phy address start scan from 0 and register at address 0x1 */
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, &val);
+	PHY_ADDR_SET(&val, 0);
+	REG_ADDR_SET(&val, 1);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_ADDRESS_ADDR, val);
+}
+
+void xgene_gmac_reset(struct xgene_enet_pdata *pdata)
+{
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, SOFT_RESET1);
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, 0);
+}
+
+void xgene_gmac_init(struct xgene_enet_pdata *pdata, int speed)
+{
+	u32 value, mc2;
+	u32 intf_ctl, rgmii;
+	u32 icm0, icm2;
+
+	xgene_gmac_reset(pdata);
+
+	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, &icm0);
+	xgene_enet_rd_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, &icm2);
+	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_2_ADDR, &mc2);
+	xgene_enet_rd_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, &intf_ctl);
+	xgene_enet_rd_csr(pdata, RGMII_REG_0_ADDR, &rgmii);
+
+	switch (speed) {
+	case SPEED_10:
+		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		CFG_MACMODE_SET(&icm0, 0);
+		CFG_WAITASYNCRD_SET(&icm2, 500);
+		rgmii &= ~CFG_SPEED_1250;
+		break;
+	case SPEED_100:
+		ENET_INTERFACE_MODE2_SET(&mc2, 1);
+		intf_ctl |= ENET_LHD_MODE;
+		CFG_MACMODE_SET(&icm0, 1);
+		CFG_WAITASYNCRD_SET(&icm2, 80);
+		rgmii &= ~CFG_SPEED_1250;
+		break;
+	default:
+		ENET_INTERFACE_MODE2_SET(&mc2, 2);
+		intf_ctl |= ENET_GHD_MODE;
+		CFG_TXCLK_MUXSEL0_SET(&rgmii, 4);
+		xgene_enet_rd_csr(pdata, DEBUG_REG_ADDR, &value);
+		value |= CFG_BYPASS_UNISEC_TX | CFG_BYPASS_UNISEC_RX;
+		xgene_enet_wr_csr(pdata, DEBUG_REG_ADDR, value);
+		break;
+	}
+
+	mc2 |= FULL_DUPLEX2;
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_2_ADDR, mc2);
+	xgene_enet_wr_mcx_mac(pdata, INTERFACE_CONTROL_ADDR, intf_ctl);
+
+	xgene_gmac_set_mac_addr(pdata);
+
+	/* Adjust MDC clock frequency */
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &value);
+	MGMT_CLOCK_SEL_SET(&value, 7);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, value);
+
+	/* Enable drop if bufpool not available */
+	xgene_enet_rd_csr(pdata, RSIF_CONFIG_REG_ADDR, &value);
+	value |= CFG_RSIF_FPBUFF_TIMEOUT_EN;
+	xgene_enet_wr_csr(pdata, RSIF_CONFIG_REG_ADDR, value);
+
+	/* Rtype should be copied from FP */
+	xgene_enet_wr_csr(pdata, RSIF_RAM_DBG_REG0_ADDR, 0);
+	xgene_enet_wr_csr(pdata, RGMII_REG_0_ADDR, rgmii);
+
+	/* Rx-Tx traffic resume */
+	xgene_enet_wr_csr(pdata, CFG_LINK_AGGR_RESUME_0_ADDR, TX_PORT0);
+
+	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG0_REG_0_ADDR, icm0);
+	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, icm2);
+
+	xgene_enet_rd_mcx_csr(pdata, RX_DV_GATE_REG_0_ADDR, &value);
+	value &= ~TX_DV_GATE_EN0;
+	value &= ~RX_DV_GATE_EN0;
+	value |= RESUME_RX0;
+	xgene_enet_wr_mcx_csr(pdata, RX_DV_GATE_REG_0_ADDR, value);
+
+	xgene_enet_wr_csr(pdata, CFG_BYPASS_ADDR, RESUME_TX);
+}
+
+/* Start Statistics related functions */
+static void xgene_gmac_get_rx_stats(struct xgene_enet_pdata *pdata,
+				    struct xgene_enet_rx_stats *rx_stat)
+{
+	xgene_enet_rd_mcx_stats(pdata, RBYT_ADDR, &rx_stat->byte_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RPKT_ADDR, &rx_stat->pkt_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RDRP_ADDR, &rx_stat->dropped_pkt_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RFCS_ADDR, &rx_stat->fcs_error_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RFLR_ADDR, &rx_stat->frm_len_err_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RALN_ADDR, &rx_stat->align_err_cntr);
+	xgene_enet_rd_mcx_stats(pdata, ROVR_ADDR, &rx_stat->oversize_pkt_cntr);
+	xgene_enet_rd_mcx_stats(pdata, RUND_ADDR, &rx_stat->undersize_pkt_cntr);
+}
+
+static void xgene_gmac_get_tx_stats(struct xgene_enet_pdata *pdata,
+				    struct xgene_enet_tx_stats *tx_stats)
+{
+	xgene_enet_rd_mcx_stats(pdata, TBYT_ADDR, &tx_stats->byte_cntr);
+	xgene_enet_rd_mcx_stats(pdata, TPKT_ADDR, &tx_stats->pkt_cntr);
+	xgene_enet_rd_mcx_stats(pdata, TDRP_ADDR, &tx_stats->drop_frame_cntr);
+	xgene_enet_rd_mcx_stats(pdata, TFCS_ADDR, &tx_stats->fcs_error_cntr);
+	xgene_enet_rd_mcx_stats(pdata, TUND_ADDR,
+				&tx_stats->undersize_frame_cntr);
+}
+
+void xgene_gmac_get_stats(struct xgene_enet_pdata *pdata,
+			  struct xgene_enet_stats *stats)
+{
+	xgene_gmac_get_rx_stats(pdata, &stats->rx_stats);
+	xgene_gmac_get_tx_stats(pdata, &stats->tx_stats);
+}
+
+static void xgene_enet_config_ring_if_assoc(struct xgene_enet_pdata *pdata)
+{
+	u32 val = 0xffffffff;
+
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQASSOC_ADDR, val);
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPQASSOC_ADDR, val);
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIQMLITEWQASSOC_ADDR, val);
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIQMLITEFPQASSOC_ADDR, val);
+}
+
+void xgene_enet_cle_bypass(struct xgene_enet_pdata *pdata,
+			   u32 dst_ring_num, u32 fpsel, u32 nxtfpsel)
+{
+	u32 cb;
+
+	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG0_0_ADDR, &cb);
+	cb |= CFG_CLE_BYPASS_EN0;
+	CFG_CLE_IP_PROTOCOL0_SET(&cb, 3);
+	xgene_enet_wr_csr(pdata, CLE_BYPASS_REG0_0_ADDR, cb);
+
+	xgene_enet_rd_csr(pdata, CLE_BYPASS_REG1_0_ADDR, &cb);
+	CFG_CLE_DSTQID0_SET(&cb, dst_ring_num);
+	CFG_CLE_FPSEL0_SET(&cb, fpsel);
+	xgene_enet_wr_csr(pdata, CLE_BYPASS_REG1_0_ADDR, cb);
+}
+
+void xgene_gmac_rx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | RX_EN);
+}
+
+void xgene_gmac_tx_enable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data | TX_EN);
+}
+
+void xgene_gmac_rx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~RX_EN);
+}
+
+void xgene_gmac_tx_disable(struct xgene_enet_pdata *pdata)
+{
+	u32 data;
+
+	xgene_enet_rd_mcx_mac(pdata, MAC_CONFIG_1_ADDR, &data);
+	xgene_enet_wr_mcx_mac(pdata, MAC_CONFIG_1_ADDR, data & ~TX_EN);
+}
+
+void xgene_enet_reset(struct xgene_enet_pdata *pdata)
+{
+	u32 val;
+
+	clk_prepare_enable(pdata->clk);
+	clk_disable_unprepare(pdata->clk);
+	clk_prepare_enable(pdata->clk);
+	xgene_enet_ecc_init(pdata);
+	xgene_enet_config_ring_if_assoc(pdata);
+
+	/* Enable auto-incr for scanning */
+	xgene_enet_rd_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, &val);
+	val |= SCAN_AUTO_INCR;
+	MGMT_CLOCK_SEL_SET(&val, 1);
+	xgene_enet_wr_mcx_mac(pdata, MII_MGMT_CONFIG_ADDR, val);
+	xgene_gmac_phy_enable_scan_cycle(pdata, 1);
+}
+
+void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
+{
+	clk_disable_unprepare(pdata->clk);
+}
+
+static int xgene_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct xgene_enet_pdata *pdata = bus->priv;
+	u32 val;
+
+	xgene_genericmiiphy_read(pdata, mii_id, regnum, &val);
+	netdev_dbg(pdata->ndev, "mdio_rd: bus=%d reg=%d val=%x\n",
+		   mii_id, regnum, val);
+
+	return val;
+}
+
+static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+				 u16 val)
+{
+	struct xgene_enet_pdata *pdata = bus->priv;
+
+	netdev_dbg(pdata->ndev, "mdio_wr: bus=%d reg=%d val=%x\n",
+		   mii_id, regnum, val);
+	xgene_genericmiiphy_write(pdata, mii_id, regnum, val);
+
+	return 0;
+}
+
+static void xgene_enet_adjust_link(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct phy_device *phydev = pdata->phy_dev;
+	bool status_change = false;
+
+	if (phydev->link && pdata->phy_speed != phydev->speed) {
+		xgene_gmac_init(pdata, phydev->speed);
+		pdata->phy_speed = phydev->speed;
+		status_change = true;
+	}
+
+	if (pdata->phy_link != phydev->link) {
+		if (!phydev->link)
+			pdata->phy_speed = 0;
+		pdata->phy_link = phydev->link;
+		status_change = true;
+	}
+
+	if (!status_change)
+		goto out;
+
+	if (phydev->link) {
+		xgene_gmac_rx_enable(pdata);
+		xgene_gmac_tx_enable(pdata);
+	} else {
+		xgene_gmac_rx_disable(pdata);
+		xgene_gmac_tx_disable(pdata);
+	}
+	phy_print_status(phydev);
+out:
+	return;
+}
+
+static int xgene_enet_phy_connect(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct device_node *phy_np;
+	struct phy_device *phy_dev;
+	int ret = 0;
+
+	struct device *dev = &pdata->pdev->dev;
+
+	phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
+
+	if (!phy_np) {
+		netdev_dbg(ndev, "No phy-handle found\n");
+		ret = -ENODEV;
+	}
+
+	phy_dev = of_phy_connect(ndev, phy_np, &xgene_enet_adjust_link,
+				 0, pdata->phy_mode);
+	if (!phy_dev) {
+		netdev_err(ndev, "Could not connect to PHY\n");
+		ret = -ENODEV;
+		goto out;
+	}
+
+out:
+	pdata->phy_link = 0;
+	pdata->phy_speed = 0;
+	pdata->phy_dev = phy_dev;
+
+	return ret;
+}
+
+int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
+{
+	struct net_device *ndev = pdata->ndev;
+	struct device *dev = &pdata->pdev->dev;
+	struct device_node *child_np = NULL;
+	struct device_node *mdio_np = NULL;
+	struct mii_bus *mdio_bus = NULL;
+	int ret;
+
+	for_each_child_of_node(dev->of_node, child_np) {
+		if (of_device_is_compatible(child_np, "apm,xgene-mdio")) {
+			mdio_np = child_np;
+			break;
+		}
+	}
+
+	if (!mdio_np) {
+		netdev_dbg(ndev, "No mdio node in the dts\n");
+		ret = -1;
+		goto err;
+	}
+
+	mdio_bus = mdiobus_alloc();
+	if (!mdio_bus) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	mdio_bus->name = "APM X-Gene MDIO bus";
+	mdio_bus->read = xgene_enet_mdio_read;
+	mdio_bus->write = xgene_enet_mdio_write;
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s", "xgene-enet-mii");
+
+	mdio_bus->irq = devm_kcalloc(dev, PHY_MAX_ADDR, sizeof(int),
+				     GFP_KERNEL);
+	if (mdio_bus->irq == NULL) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	mdio_bus->priv = pdata;
+	mdio_bus->parent = &ndev->dev;
+
+	ret = of_mdiobus_register(mdio_bus, mdio_np);
+	if (ret) {
+		netdev_err(ndev, "Failed to register MDIO bus\n");
+		goto err;
+	}
+	pdata->mdio_bus = mdio_bus;
+	ret = xgene_enet_phy_connect(ndev);
+
+	return ret;
+err:
+	if (mdio_bus) {
+		if (mdio_bus->irq)
+			devm_kfree(dev, mdio_bus->irq);
+		mdiobus_free(mdio_bus);
+	}
+	return ret;
+}
+
+int xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
+{
+	struct mii_bus *mdio_bus;
+
+	mdio_bus = pdata->mdio_bus;
+	mdiobus_unregister(mdio_bus);
+	mdiobus_free(mdio_bus);
+	pdata->mdio_bus = NULL;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
new file mode 100644
index 0000000..a4c0a14
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -0,0 +1,353 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_HW_H__
+#define __XGENE_ENET_HW_H__
+
+#include "xgene_enet_main.h"
+
+struct xgene_enet_pdata;
+struct xgene_enet_stats;
+
+/* clears and then set bits */
+static inline void set_bits(u32 *dst, u32 val, u32 start, u32 len)
+{
+	u32 end = start + len - 1;
+	u32 mask = GENMASK(end, start);
+
+	*dst &= ~mask;
+	*dst |= (val << start) & mask;
+}
+
+static inline u32 get_bits(u32 val, u32 start, u32 end)
+{
+	return (val & GENMASK(end, start)) >> start;
+}
+
+#define CSR_RING_ID		0x00000008
+#define OVERWRITE		BIT(31)
+#define IS_BUFFER_POOL		BIT(20)
+#define PREFETCH_BUF_EN		BIT(21)
+#define CSR_RING_ID_BUF		0x0000000c
+#define CSR_RING_NE_INT_MODE	0x0000017c
+#define CSR_RING_CONFIG		0x0000006c
+#define CSR_RING_WR_BASE	0x00000070
+#define NUM_RING_CONFIG		5
+#define BUFPOOL_MODE		3
+#define RM3			3
+#define INC_DEC_CMD_ADDR	0x2c
+#define IS_FP(x) ((x & 0x0020) ? 1 : 0)
+#define UDP_HDR_SIZE		2
+
+#define CREATE_MASK(pos, len)		GENMASK(pos+len-1, pos)
+#define CREATE_MASK_ULL(pos, len)	GENMASK_ULL(pos+len-1, pos)
+
+/* Empty slot soft signature */
+#define EMPTY_SLOT_INDEX	1
+#define EMPTY_SLOT		~0ULL
+
+#define RING_BUFNUM(q)		(q->id & 0x003F)
+#define RING_OWNER(q)		((q->id & 0x03C0) >> 6)
+#define BUF_LEN_CODE_2K		0x5000
+
+#define SELTHRSH_POS		3
+#define SELTHRSH_LEN		3
+#define RINGADDRL_POS		5
+#define RINGADDRL_LEN		27
+#define RINGADDRH_POS		0
+#define RINGADDRH_LEN		6
+#define RINGSIZE_POS		23
+#define RINGSIZE_LEN		3
+#define RINGTYPE_POS		19
+#define RINGTYPE_LEN		2
+#define RINGMODE_POS		20
+#define RINGMODE_LEN		3
+#define RECOMTIMEOUTL_POS	28
+#define RECOMTIMEOUTL_LEN	3
+#define RECOMTIMEOUTH_POS	0
+#define RECOMTIMEOUTH_LEN	2
+#define NUMMSGSINQ_POS		1
+#define NUMMSGSINQ_LEN		16
+#define ACCEPTLERR		BIT(19)
+#define QCOHERENT		BIT(4)
+#define RECOMBBUF		BIT(27)
+
+#define BLOCK_ETH_CSR_OFFSET		0x2000
+#define BLOCK_ETH_RING_IF_OFFSET	0x9000
+#define BLOCK_ETH_CLKRST_CSR_OFFSET	0xC000
+#define BLOCK_ETH_DIAG_CSR_OFFSET	0xD000
+
+#define BLOCK_ETH_MAC_OFFSET		0x0000
+#define BLOCK_ETH_STATS_OFFSET		0x0014
+#define BLOCK_ETH_MAC_CSR_OFFSET	0x2800
+
+/* Constants for indirect registers */
+#define MAC_ADDR_REG_OFFSET		0
+#define MAC_COMMAND_REG_OFFSET		4
+#define MAC_WRITE_REG_OFFSET		8
+#define MAC_READ_REG_OFFSET		12
+#define MAC_COMMAND_DONE_REG_OFFSET	16
+
+#define STAT_ADDR_REG_OFFSET		0
+#define STAT_COMMAND_REG_OFFSET		4
+#define STAT_WRITE_REG_OFFSET		8
+#define STAT_READ_REG_OFFSET		12
+#define STAT_COMMAND_DONE_REG_OFFSET	16
+
+/* Address PE_MCXMAC  Registers */
+#define MII_MGMT_CONFIG_ADDR		0x20
+#define MII_MGMT_COMMAND_ADDR		0x24
+#define MII_MGMT_ADDRESS_ADDR		0x28
+#define MII_MGMT_CONTROL_ADDR		0x2c
+#define MII_MGMT_STATUS_ADDR		0x30
+#define MII_MGMT_INDICATORS_ADDR	0x34
+
+#define BUSY_MASK			BIT(0)
+#define READ_CYCLE_MASK			BIT(0)
+#define PHY_CONTROL_SET(dst, val)	set_bits(dst, val, 0, 16)
+
+#define ENET_SPARE_CFG_REG_ADDR		0x00000750
+#define RSIF_CONFIG_REG_ADDR		0x00000010
+#define RSIF_RAM_DBG_REG0_ADDR		0x00000048
+#define RGMII_REG_0_ADDR		0x000007e0
+#define CFG_LINK_AGGR_RESUME_0_ADDR	0x000007c8
+#define DEBUG_REG_ADDR			0x00000700
+#define CFG_BYPASS_ADDR			0x00000294
+#define CLE_BYPASS_REG0_0_ADDR		0x00000490
+#define CLE_BYPASS_REG1_0_ADDR		0x00000494
+#define CFG_RSIF_FPBUFF_TIMEOUT_EN	BIT(31)
+#define RESUME_TX			BIT(0)
+#define CFG_SPEED_1250			BIT(24)
+#define TX_PORT0			BIT(0)
+#define CFG_BYPASS_UNISEC_TX		BIT(2)
+#define CFG_BYPASS_UNISEC_RX		BIT(1)
+#define CFG_TXCLK_MUXSEL0_SET(dst, val)	set_bits(dst, val, 29, 3)
+#define CFG_CLE_BYPASS_EN0		BIT(31)
+
+#define CFG_CLE_IP_PROTOCOL0_SET(dst, val)	set_bits(dst, val, 16, 2)
+#define CFG_CLE_DSTQID0_SET(dst, val)		set_bits(dst, val, 0, 12)
+#define CFG_CLE_FPSEL0_SET(dst, val)		set_bits(dst, val, 16, 4)
+#define CFG_MACMODE_SET(dst, val)		set_bits(dst, val, 18, 2)
+#define CFG_WAITASYNCRD_SET(dst, val)		set_bits(dst, val, 0, 16)
+#define ICM_CONFIG0_REG_0_ADDR		0x00000400
+#define ICM_CONFIG2_REG_0_ADDR		0x00000410
+#define RX_DV_GATE_REG_0_ADDR		0x000005fc
+#define TX_DV_GATE_EN0			BIT(2)
+#define RX_DV_GATE_EN0			BIT(1)
+#define RESUME_RX0			BIT(0)
+#define ENET_CFGSSQMIWQASSOC_ADDR		0x000000e0
+#define ENET_CFGSSQMIFPQASSOC_ADDR		0x000000dc
+#define ENET_CFGSSQMIQMLITEFPQASSOC_ADDR	0x000000f0
+#define ENET_CFGSSQMIQMLITEWQASSOC_ADDR		0x000000f4
+
+#define ENET_CFG_MEM_RAM_SHUTDOWN_ADDR		0x00000070
+#define ENET_BLOCK_MEM_RDY_ADDR			0x00000074
+#define MAC_CONFIG_1_ADDR			0x00000000
+#define MAC_CONFIG_2_ADDR			0x00000004
+#define MAX_FRAME_LEN_ADDR			0x00000010
+#define INTERFACE_CONTROL_ADDR			0x00000038
+#define STATION_ADDR0_ADDR			0x00000040
+#define STATION_ADDR1_ADDR			0x00000044
+#define SCAN_CYCLE_MASK_SET(dst, src)		set_bits(dst, val, 0, 1)
+#define PHY_ADDR_SET(dst, val)			set_bits(dst, val, 8, 5)
+#define REG_ADDR_SET(dst, val)			set_bits(dst, val, 0, 5)
+#define ENET_INTERFACE_MODE2_SET(dst, val)	set_bits(dst, val, 8, 2)
+#define MGMT_CLOCK_SEL_SET(dst, val)		set_bits(dst, val, 0, 3)
+#define SOFT_RESET1			BIT(31)
+#define TX_EN				BIT(0)
+#define RX_EN				BIT(2)
+#define ENET_LHD_MODE			BIT(25)
+#define ENET_GHD_MODE			BIT(26)
+#define FULL_DUPLEX2			BIT(0)
+#define SCAN_AUTO_INCR			BIT(5)
+#define RBYT_ADDR			0x00000027
+#define RPKT_ADDR			0x00000028
+#define RFCS_ADDR			0x00000029
+#define RALN_ADDR			0x0000002f
+#define RFLR_ADDR			0x00000030
+#define RUND_ADDR			0x00000033
+#define ROVR_ADDR			0x00000034
+#define RDRP_ADDR			0x00000037
+#define TBYT_ADDR			0x00000038
+#define TPKT_ADDR			0x00000039
+#define TDRP_ADDR			0x00000045
+#define TFCS_ADDR			0x00000047
+#define TUND_ADDR			0x0000004a
+
+#define TSO_IPPROTO_TCP			1
+#define TSO_IPPROTO_UDP			0
+#define	FULL_DUPLEX			2
+
+#define USERINFO_POS			0
+#define USERINFO_LEN			32
+#define FPQNUM_POS			32
+#define FPQNUM_LEN			12
+#define STASH_POS			53
+#define STASH_LEN			2
+#define BUFDATALEN_POS			48
+#define BUFDATALEN_LEN			12
+#define BUFLEN_POS			60
+#define BUFLEN_LEN			3
+#define DATAADDR_POS			0
+#define DATAADDR_LEN			42
+#define COHERENT_POS			63
+#define COHERENT_LEN			1
+#define HENQNUM_POS			48
+#define HENQNUM_LEN			12
+#define TYPESEL_POS			44
+#define TYPESEL_LEN			4
+#define ETHHDR_POS			12
+#define ETHHDR_LEN			8
+#define IC_POS				35	/* Insert CRC */
+#define IC_LEN				1
+#define TCPHDR_POS			0
+#define TCPHDR_LEN			6
+#define IPHDR_POS			6
+#define IPHDR_LEN			5
+#define EC_POS				22	/* Enable checksum */
+#define EC_LEN				1
+#define IS_POS				24	/* IP protocol select */
+#define IS_LEN				1
+
+struct xgene_enet_desc {
+	u64 m0;
+	u64 m1;
+	u64 m2;
+	u64 m3;
+};
+
+struct xgene_enet_desc16 {
+	u64 m0;
+	u64 m1;
+};
+
+static inline void xgene_enet_cpu_to_le64(void *desc_ptr, int count)
+{
+	u64 *desc = desc_ptr;
+	int i;
+
+	for (i = 0; i < count; i++)
+		desc[i] = cpu_to_le64(desc[i]);
+}
+
+static inline void xgene_enet_le64_to_cpu(void *desc_ptr, int count)
+{
+	u64 *desc = desc_ptr;
+	int i;
+
+	for (i = 0; i < count; i++)
+		desc[i] = le64_to_cpu(desc[i]);
+}
+
+static inline void xgene_enet_desc16_to_le64(void *desc_ptr)
+{
+	u64 *desc;
+
+	desc = desc_ptr;
+	desc[1] = cpu_to_le64(desc[1]);
+}
+
+static inline void xgene_enet_le64_to_desc16(void *desc_ptr)
+{
+	u64 *desc;
+
+	desc = desc_ptr;
+	desc[1] = le64_to_cpu(desc[1]);
+}
+
+enum xgene_enet_ring_cfgsize {
+	RING_CFGSIZE_512B,
+	RING_CFGSIZE_2KB,
+	RING_CFGSIZE_16KB,
+	RING_CFGSIZE_64KB,
+	RING_CFGSIZE_512KB,
+	RING_CFGSIZE_INVALID
+};
+
+enum xgene_enet_ring_type {
+	RING_DISABLED,
+	RING_REGULAR,
+	RING_BUFPOOL
+};
+
+enum xgene_enet_ring_owner {
+	RING_OWNER_ETH0,
+	RING_OWNER_CPU = 15,
+	RING_OWNER_INVALID
+};
+
+enum xgene_enet_ring_bufnum {
+	RING_BUFNUM_REGULAR = 0x0,
+	RING_BUFNUM_BUFPOOL = 0x20,
+	RING_BUFNUM_INVALID
+};
+
+struct xgene_enet_desc_ring *xgene_enet_setup_ring(
+		struct xgene_enet_desc_ring *ring);
+void xgene_enet_clear_ring(struct xgene_enet_desc_ring *ring);
+
+enum desc_info_index {
+	USERINFO,
+	FPQNUM,
+	STASH,
+	DATAADDR,
+	BUFDATALEN,
+	BUFLEN,
+	COHERENT,
+	TCPHDR,
+	IPHDR,
+	ETHHDR,
+	EC,
+	IS,
+	IC,
+	TYPESEL,
+	HENQNUM,
+	MAX_DESC_INFO_INDEX
+};
+
+struct xgene_enet_desc_info {
+	u8 word_index;
+	u8 start_bit;
+	u8 len;
+};
+
+enum xgene_enet_cmd {
+	XGENE_ENET_WR_CMD = BIT(31),
+	XGENE_ENET_RD_CMD = BIT(30)
+};
+
+void set_desc(void *desc_ptr, enum desc_info_index index, u64 val);
+u64 get_desc(void *desc_ptr, enum desc_info_index index);
+
+void xgene_enet_reset(struct xgene_enet_pdata *priv);
+void xgene_gmac_reset(struct xgene_enet_pdata *priv);
+void xgene_gmac_init(struct xgene_enet_pdata *priv, int speed);
+void xgene_gmac_tx_enable(struct xgene_enet_pdata *priv);
+void xgene_gmac_rx_enable(struct xgene_enet_pdata *priv);
+void xgene_gmac_tx_disable(struct xgene_enet_pdata *priv);
+void xgene_gmac_rx_disable(struct xgene_enet_pdata *priv);
+void xgene_gmac_set_mac_addr(struct xgene_enet_pdata *pdata);
+void xgene_enet_cle_bypass(struct xgene_enet_pdata *priv,
+			   u32 dst_ring_num, u32 fpsel, u32 nxtfpsel);
+void xgene_gport_shutdown(struct xgene_enet_pdata *priv);
+void xgene_gmac_get_stats(struct xgene_enet_pdata *priv,
+			  struct xgene_enet_stats *stats);
+#endif /* __XGENE_ENET_HW_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
new file mode 100644
index 0000000..0feb571
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -0,0 +1,936 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_hw.h"
+
+static void xgene_enet_init_bufpool(struct xgene_enet_desc_ring *buf_pool)
+{
+	struct xgene_enet_desc16 *desc;
+	int i;
+
+	for (i = 0; i < buf_pool->slots; i++) {
+		desc = &buf_pool->desc16[i];
+
+		set_desc(desc, USERINFO, i);
+		set_desc(desc, FPQNUM, buf_pool->dst_ring_num);
+		set_desc(desc, STASH, 1);
+
+		/* Hardware expects descriptor in little endian format */
+		xgene_enet_cpu_to_le64(desc, 4);
+	}
+}
+
+static struct device *ndev_to_dev(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+	return &pdata->pdev->dev;
+}
+
+static int xgene_enet_refill_bufpool(struct xgene_enet_desc_ring *buf_pool,
+				     u32 nbuf)
+{
+	struct sk_buff *skb;
+	struct xgene_enet_desc16 *desc;
+	struct net_device *ndev;
+	struct device *dev;
+	dma_addr_t dma_addr;
+	u32 tail = buf_pool->tail;
+	u32 slots = buf_pool->slots - 1;
+	int i, ret = 0;
+	u16 bufdatalen, len;
+
+	ndev = buf_pool->ndev;
+	dev = ndev_to_dev(buf_pool->ndev);
+	bufdatalen = BUF_LEN_CODE_2K | (SKB_BUFFER_SIZE & GENMASK(11, 0));
+	len = XGENE_ENET_MAX_MTU;
+
+	for (i = 0; i < nbuf; i++) {
+		desc = &buf_pool->desc16[tail];
+
+		skb = netdev_alloc_skb_ip_align(ndev, len);
+		if (unlikely(!skb)) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		buf_pool->rx_skb[tail] = skb;
+
+		dma_addr = dma_map_single(dev, skb->data, len, DMA_FROM_DEVICE);
+		if (dma_mapping_error(dev, dma_addr)) {
+			netdev_err(ndev, "DMA mapping error\n");
+			dev_kfree_skb_any(skb);
+			ret = -EINVAL;
+			goto out;
+		}
+		set_desc(desc, DATAADDR, dma_addr);
+		set_desc(desc, BUFDATALEN, bufdatalen);
+		set_desc(desc, COHERENT, 1);
+
+		xgene_enet_desc16_to_le64(desc);
+		tail = (tail + 1) & slots;
+	}
+
+	iowrite32(nbuf, buf_pool->cmd);
+	buf_pool->tail = tail;
+
+out:
+	return ret;
+}
+
+static u16 xgene_enet_dst_ring_num(struct xgene_enet_desc_ring *ring)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+
+	return ((u16)pdata->rm << 10) | ring->num;
+}
+
+static u8 xgene_enet_hdr_len(const void *data)
+{
+	const struct ethhdr *eth = data;
+
+	return (eth->h_proto == htons(ETH_P_8021Q)) ? VLAN_ETH_HLEN : ETH_HLEN;
+}
+
+static u32 xgene_enet_ring_len(struct xgene_enet_desc_ring *ring)
+{
+	u32 *cmd_base = ring->cmd_base;
+	u32 ring_state, num_msgs;
+
+	ring_state = ioread32(&cmd_base[1]);
+	num_msgs = ring_state & CREATE_MASK(NUMMSGSINQ_POS, NUMMSGSINQ_LEN);
+	return num_msgs >> NUMMSGSINQ_POS;
+}
+
+static void xgene_enet_delete_bufpool(struct xgene_enet_desc_ring *buf_pool)
+{
+	u32 tail = buf_pool->tail;
+	u32 slots = buf_pool->slots - 1;
+	int len = xgene_enet_ring_len(buf_pool);
+	struct xgene_enet_desc16 *desc;
+	u32 userinfo;
+	int i;
+
+	for (i = 0; i < len; i++) {
+		tail = (tail - 1) & slots;
+		desc = &buf_pool->desc16[tail];
+
+		/* Hardware stores descriptor in little endian format */
+		xgene_enet_le64_to_desc16(desc);
+		userinfo = get_desc(desc, USERINFO);
+		dev_kfree_skb_any(buf_pool->rx_skb[userinfo]);
+	}
+
+	iowrite32(-len, buf_pool->cmd);
+	buf_pool->tail = tail;
+}
+
+irqreturn_t xgene_enet_rx_irq(const int irq, void *data)
+{
+	struct xgene_enet_desc_ring *rx_ring = data;
+
+	if (napi_schedule_prep(&rx_ring->napi)) {
+		disable_irq_nosync(irq);
+		__napi_schedule(&rx_ring->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
+				    struct xgene_enet_desc *desc)
+{
+	struct sk_buff *skb;
+	dma_addr_t pa;
+	size_t len;
+	struct device *dev;
+	u16 skb_index;
+	int ret = 0;
+
+	skb_index = get_desc(desc, USERINFO);
+	skb = cp_ring->cp_skb[skb_index];
+
+	dev = ndev_to_dev(cp_ring->ndev);
+	pa = (dma_addr_t)get_desc(desc, DATAADDR);
+	len = get_desc(desc, BUFDATALEN);
+	dma_unmap_single(dev, pa, len, DMA_TO_DEVICE);
+
+	if (likely(skb)) {
+		dev_kfree_skb_any(skb);
+	} else {
+		netdev_err(cp_ring->ndev, "completion skb is NULL\n");
+		ret = -1;
+	}
+
+	return ret;
+}
+
+static void xgene_enet_checksum_offload(struct xgene_enet_desc *desc,
+					struct sk_buff *skb)
+{
+	u32 maclen, nr_frags;
+	struct iphdr *iph;
+	u8 l4hlen = 0;
+	u8 l3hlen = 0;
+	u8 csum_enable = 0;
+	u8 proto = 0;
+	struct net_device *ndev = skb->dev;
+
+	if (unlikely(!(ndev->features & NETIF_F_IP_CSUM)))
+		goto out;
+	if (unlikely(skb->protocol != htons(ETH_P_IP)) &&
+	    unlikely(skb->protocol != htons(ETH_P_8021Q)))
+		goto out;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	maclen = xgene_enet_hdr_len(skb->data);
+	iph = ip_hdr(skb);
+	l3hlen = ip_hdrlen(skb) >> 2;
+
+	if (unlikely(iph->frag_off & htons(IP_MF | IP_OFFSET)))
+		goto out;
+	if (likely(iph->protocol == IPPROTO_TCP)) {
+		l4hlen = tcp_hdrlen(skb) / 4;
+		csum_enable = 1;
+		proto = TSO_IPPROTO_TCP;
+	} else if (iph->protocol == IPPROTO_UDP) {
+		l4hlen = UDP_HDR_SIZE;
+		csum_enable = 1;
+		proto = TSO_IPPROTO_UDP;
+	}
+
+	set_desc(desc, TCPHDR, l4hlen);
+	set_desc(desc, IPHDR, l3hlen);
+	set_desc(desc, EC, csum_enable);
+	set_desc(desc, IS, proto);
+out:
+	return;
+}
+
+static int xgene_enet_setup_tx_desc(struct xgene_enet_desc_ring *tx_ring,
+				     struct sk_buff *skb)
+{
+	struct xgene_enet_desc *desc;
+	dma_addr_t dma_addr;
+	u8 ethhdr;
+	u16 tail = tx_ring->tail;
+	struct device *dev = ndev_to_dev(tx_ring->ndev);
+
+	desc = &tx_ring->desc[tail];
+	memset(desc, 0, sizeof(struct xgene_enet_desc));
+
+	dma_addr = dma_map_single(dev, skb->data, skb->len, DMA_TO_DEVICE);
+	if (dma_mapping_error(dev, dma_addr)) {
+		netdev_err(tx_ring->ndev, "DMA mapping error\n");
+		return -EINVAL;
+	}
+	set_desc(desc, DATAADDR, dma_addr);
+
+	set_desc(desc, BUFDATALEN, skb->len);
+	set_desc(desc, COHERENT, 1);
+	tx_ring->cp_ring->cp_skb[tail] = skb;
+	set_desc(desc, USERINFO, tail);
+	set_desc(desc, HENQNUM, tx_ring->dst_ring_num);
+	set_desc(desc, TYPESEL, 1);
+	ethhdr = xgene_enet_hdr_len(skb->data);
+	set_desc(desc, ETHHDR, ethhdr);
+	set_desc(desc, IC, 1);
+
+	xgene_enet_checksum_offload(desc, skb);
+
+	/* Hardware expects descriptor in little endian format */
+	xgene_enet_cpu_to_le64(desc, 4);
+
+	return 0;
+}
+
+static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
+					 struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
+	struct xgene_enet_desc_ring *cp_ring = tx_ring->cp_ring;
+	u32 tx_level, cq_level;
+	u32 pkt_count = 1;
+
+	tx_level = xgene_enet_ring_len(tx_ring);
+	cq_level = xgene_enet_ring_len(cp_ring);
+	if (tx_level > pdata->tx_qcnt_hi || cq_level > pdata->cp_qcnt_hi) {
+		netif_stop_queue(ndev);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (xgene_enet_setup_tx_desc(tx_ring, skb))
+		goto out;
+
+	skb_tx_timestamp(skb);
+
+	tx_ring->tail = (tx_ring->tail + 1) & (tx_ring->slots - 1);
+	iowrite32(pkt_count, tx_ring->cmd);
+out:
+	return NETDEV_TX_OK;
+}
+
+void xgene_enet_skip_csum(struct sk_buff *skb)
+{
+	struct iphdr *iph = (struct iphdr *)skb->data;
+
+	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET)) ||
+	    (iph->protocol != IPPROTO_TCP && iph->protocol != IPPROTO_UDP)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+}
+
+static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
+				struct xgene_enet_desc *desc)
+{
+	struct net_device *ndev = rx_ring->ndev;
+	struct device *dev = ndev_to_dev(rx_ring->ndev);
+	struct xgene_enet_desc_ring *buf_pool = rx_ring->buf_pool;
+	u32 datalen, skb_index;
+	struct sk_buff *skb;
+	dma_addr_t pa;
+	int ret = 0;
+
+	skb_index = get_desc(desc, USERINFO);
+	skb = buf_pool->rx_skb[skb_index];
+	prefetch(skb->data - NET_IP_ALIGN);
+
+	/* Strip off CRC as HW isn't doing this */
+	datalen = get_desc(desc, BUFDATALEN);
+	datalen -= 4;
+	skb_put(skb, datalen);
+
+	pa = (dma_addr_t)get_desc(desc, DATAADDR);
+	dma_unmap_single(dev, pa, XGENE_ENET_MAX_MTU, DMA_FROM_DEVICE);
+
+	if (--rx_ring->nbufpool == 0) {
+		ret = xgene_enet_refill_bufpool(buf_pool, NUM_BUFPOOL);
+		rx_ring->nbufpool = NUM_BUFPOOL;
+	}
+
+	skb_checksum_none_assert(skb);
+	skb->protocol = eth_type_trans(skb, ndev);
+	if (likely((ndev->features & NETIF_F_IP_CSUM) &&
+		   skb->protocol == htons(ETH_P_IP))) {
+		xgene_enet_skip_csum(skb);
+	}
+
+	napi_gro_receive(&rx_ring->napi, skb);
+
+	return ret;
+}
+
+static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
+				   int budget)
+{
+	struct net_device *ndev = ring->ndev;
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+	struct xgene_enet_desc *desc;
+	int napi_budget = budget;
+	int cmd = 0, ret = 0;
+	u16 head = ring->head;
+	u16 slots = ring->slots - 1;
+
+	do {
+		desc = &ring->desc[head];
+		if (unlikely(((u64 *)desc)[EMPTY_SLOT_INDEX] == EMPTY_SLOT))
+			break;
+
+		/* Hardware stores descriptor in little endian format */
+		xgene_enet_le64_to_cpu(desc, 4);
+		if (get_desc(desc, FPQNUM))
+			ret = xgene_enet_rx_frame(ring, desc);
+		else
+			ret = xgene_enet_tx_completion(ring, desc);
+		((u64 *)desc)[EMPTY_SLOT_INDEX] = EMPTY_SLOT;
+
+		head = (head + 1) & slots;
+		cmd++;
+
+		if (ret)
+			break;
+	} while (--budget);
+
+	if (likely(cmd)) {
+		iowrite32(-cmd, ring->cmd);
+		ring->head = head;
+
+		if (netif_queue_stopped(ndev)) {
+			if (xgene_enet_ring_len(ring) < pdata->cp_qcnt_low)
+				netif_wake_queue(ndev);
+		}
+	}
+
+	return napi_budget - budget;
+}
+
+static int xgene_enet_napi(struct napi_struct *napi, const int budget)
+{
+	struct xgene_enet_desc_ring *ring =
+	    container_of(napi, struct xgene_enet_desc_ring, napi);
+	int processed = xgene_enet_process_ring(ring, budget);
+
+	if (processed != budget) {
+		napi_complete(napi);
+		enable_irq(ring->irq);
+	}
+
+	return processed;
+}
+
+static void xgene_enet_timeout(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+	xgene_gmac_reset(pdata);
+}
+
+static int xgene_enet_register_irq(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	int ret;
+
+	ret = devm_request_irq(dev, pdata->rx_ring->irq, xgene_enet_rx_irq,
+			      IRQF_SHARED, ndev->name, pdata->rx_ring);
+	if (ret) {
+		netdev_err(ndev, "rx%d interrupt request failed\n",
+			   pdata->rx_ring->irq);
+	}
+
+	return ret;
+}
+
+static void xgene_enet_free_irq(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+
+	devm_free_irq(dev, pdata->rx_ring->irq, pdata->rx_ring);
+}
+
+static int xgene_enet_open(struct net_device *ndev)
+{
+	int ret = 0;
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+	xgene_gmac_tx_enable(pdata);
+	xgene_gmac_rx_enable(pdata);
+
+	ret = xgene_enet_register_irq(ndev);
+	if (ret)
+		goto out;
+	napi_enable(&pdata->rx_ring->napi);
+
+	if (pdata->phy_dev)
+		phy_start(pdata->phy_dev);
+
+	netif_start_queue(ndev);
+out:
+	return ret;
+}
+
+static int xgene_enet_close(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+
+	netif_stop_queue(ndev);
+
+	if (pdata->phy_dev)
+		phy_stop(pdata->phy_dev);
+
+	napi_disable(&pdata->rx_ring->napi);
+	xgene_enet_free_irq(ndev);
+	xgene_enet_process_ring(pdata->rx_ring, -1);
+
+	xgene_gmac_tx_disable(pdata);
+	xgene_gmac_rx_disable(pdata);
+
+	return 0;
+}
+
+static void xgene_enet_delete_ring(struct xgene_enet_desc_ring *ring)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+	struct device *dev = &pdata->pdev->dev;
+
+	xgene_enet_clear_ring(ring);
+	dma_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
+	devm_kfree(dev, ring);
+}
+
+static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
+{
+	struct device *dev = &pdata->pdev->dev;
+	struct xgene_enet_desc_ring *buf_pool;
+
+	if (pdata->tx_ring) {
+		xgene_enet_delete_ring(pdata->tx_ring);
+		pdata->tx_ring = NULL;
+	}
+
+	if (pdata->rx_ring) {
+		buf_pool = pdata->rx_ring->buf_pool;
+		xgene_enet_delete_bufpool(buf_pool);
+		xgene_enet_delete_ring(buf_pool);
+		devm_kfree(dev, buf_pool->rx_skb);
+
+		xgene_enet_delete_ring(pdata->rx_ring);
+		pdata->rx_ring = NULL;
+	}
+}
+
+static int xgene_enet_get_ring_size(struct device *dev,
+				    enum xgene_enet_ring_cfgsize cfgsize)
+{
+	int size = -EINVAL;
+
+	switch (cfgsize) {
+	case RING_CFGSIZE_512B:
+		size = 0x200;
+		break;
+	case RING_CFGSIZE_2KB:
+		size = 0x800;
+		break;
+	case RING_CFGSIZE_16KB:
+		size = 0x4000;
+		break;
+	case RING_CFGSIZE_64KB:
+		size = 0x10000;
+		break;
+	case RING_CFGSIZE_512KB:
+		size = 0x80000;
+		break;
+	default:
+		dev_err(dev, "Unsupported cfg ring size %d\n", cfgsize);
+		break;
+	}
+
+	return size;
+}
+
+static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
+			struct net_device *ndev, u32 ring_num,
+			enum xgene_enet_ring_cfgsize cfgsize, u32 ring_id)
+{
+	struct xgene_enet_desc_ring *ring;
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	u32 size;
+
+	ring = devm_kzalloc(dev, sizeof(struct xgene_enet_desc_ring),
+			    GFP_KERNEL);
+	if (!ring)
+		goto err;
+
+	ring->ndev = ndev;
+	ring->num = ring_num;
+	ring->cfgsize = cfgsize;
+	ring->id = ring_id;
+
+	size = xgene_enet_get_ring_size(dev, cfgsize);
+	ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
+					      GFP_KERNEL);
+	if (!ring->desc_addr)
+		goto err;
+	ring->size = size;
+
+	ring->cmd_base = pdata->ring_cmd_addr + (ring->num << 6);
+	ring->cmd = ring->cmd_base + INC_DEC_CMD_ADDR;
+	pdata->rm = RM3;
+	ring = xgene_enet_setup_ring(ring);
+	netdev_dbg(ndev, "ring info: num=%d  size=%d  id=%d  slots=%d\n",
+		   ring->num, ring->size, ring->id, ring->slots);
+
+	return ring;
+err:
+	if (ring && ring->desc_addr) {
+		dma_free_coherent(dev, size, ring->desc_addr, ring->dma);
+		devm_kfree(dev, ring);
+	}
+	if (ring)
+		devm_kfree(dev, ring);
+
+	return NULL;
+}
+
+static int xgene_enet_create_desc_rings(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
+	struct xgene_enet_desc_ring *buf_pool = NULL;
+	u32 ring_num = 0;
+	u32 ring_id;
+	int ret = 0;
+
+	/* allocate rx descriptor ring */
+	ring_id = (RING_OWNER_CPU << 6) | RING_BUFNUM_REGULAR;
+	rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+					      RING_CFGSIZE_16KB, ring_id);
+	if (IS_ERR_OR_NULL(rx_ring)) {
+		ret = PTR_ERR(rx_ring);
+		goto err;
+	}
+
+	/* allocate buffer pool for receiving packets */
+	ring_id = (RING_OWNER_ETH0 << 6) | RING_BUFNUM_BUFPOOL;
+	buf_pool = xgene_enet_create_desc_ring(ndev, ring_num++,
+					       RING_CFGSIZE_2KB, ring_id);
+	if (IS_ERR_OR_NULL(buf_pool)) {
+		ret = PTR_ERR(buf_pool);
+		goto err;
+	}
+
+	rx_ring->nbufpool = NUM_BUFPOOL;
+	rx_ring->buf_pool = buf_pool;
+	rx_ring->irq = pdata->rx_irq;
+	buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
+				     sizeof(struct sk_buff *), GFP_KERNEL);
+	if (!buf_pool->rx_skb) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
+	rx_ring->buf_pool = buf_pool;
+	pdata->rx_ring = rx_ring;
+
+	/* allocate tx descriptor ring */
+	ring_id = (RING_OWNER_ETH0 << 6) | RING_BUFNUM_REGULAR;
+	tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+					      RING_CFGSIZE_16KB, ring_id);
+	if (IS_ERR_OR_NULL(tx_ring)) {
+		ret = PTR_ERR(tx_ring);
+		goto err;
+	}
+	pdata->tx_ring = tx_ring;
+
+	cp_ring = pdata->rx_ring;
+	cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
+				     sizeof(struct sk_buff *), GFP_KERNEL);
+	if (!cp_ring->cp_skb) {
+		ret = -ENOMEM;
+		goto err;
+	}
+	pdata->tx_ring->cp_ring = cp_ring;
+	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
+
+	pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
+	pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
+	pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
+
+	return 0;
+
+err:
+	xgene_enet_delete_desc_rings(pdata);
+	return ret;
+}
+
+static struct net_device_stats *xgene_enet_get_stats(struct net_device *ndev)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct net_device_stats *nst = &pdata->nstats;
+	struct xgene_enet_stats stats;
+	struct xgene_enet_rx_stats *rx_stats;
+	struct xgene_enet_tx_stats *tx_stats;
+	u32 pkt_bytes, crc_bytes = 4;
+
+	memset(&stats, 0, sizeof(struct xgene_enet_stats));
+	rx_stats = &stats.rx_stats;
+	tx_stats = &stats.tx_stats;
+
+	spin_lock(&pdata->stats_lock);
+	xgene_gmac_get_stats(pdata, &stats);
+
+	pkt_bytes = rx_stats->byte_cntr;
+	pkt_bytes -= rx_stats->pkt_cntr * crc_bytes;
+	nst->rx_packets += rx_stats->pkt_cntr;
+	nst->rx_bytes += pkt_bytes;
+
+	pkt_bytes = tx_stats->byte_cntr;
+	pkt_bytes -= tx_stats->pkt_cntr * crc_bytes;
+	nst->tx_packets += tx_stats->pkt_cntr;
+	nst->tx_bytes += pkt_bytes;
+
+	nst->rx_dropped += rx_stats->dropped_pkt_cntr;
+	nst->tx_dropped += tx_stats->drop_frame_cntr;
+
+	nst->rx_crc_errors += rx_stats->fcs_error_cntr;
+	nst->rx_length_errors += rx_stats->frm_len_err_cntr;
+	nst->rx_frame_errors += rx_stats->align_err_cntr;
+	nst->rx_over_errors += rx_stats->oversize_pkt_cntr;
+
+	nst->rx_errors += rx_stats->fcs_error_cntr +
+			  rx_stats->frm_len_err_cntr +
+			  rx_stats->oversize_pkt_cntr +
+			  rx_stats->undersize_pkt_cntr;
+
+	nst->tx_errors += tx_stats->fcs_error_cntr +
+			  tx_stats->undersize_frame_cntr;
+	spin_unlock(&pdata->stats_lock);
+
+	return nst;
+}
+
+static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	int ret;
+
+	ret = eth_mac_addr(ndev, addr);
+	if (ret)
+		goto out;
+
+	xgene_gmac_set_mac_addr(pdata);
+out:
+	return ret;
+}
+
+static const struct net_device_ops xgene_ndev_ops = {
+	.ndo_open = xgene_enet_open,
+	.ndo_stop = xgene_enet_close,
+	.ndo_start_xmit = xgene_enet_start_xmit,
+	.ndo_tx_timeout = xgene_enet_timeout,
+	.ndo_get_stats = xgene_enet_get_stats,
+	.ndo_change_mtu = eth_change_mtu,
+	.ndo_set_mac_address = xgene_enet_set_mac_address,
+};
+
+static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
+{
+	struct platform_device *pdev;
+	struct net_device *ndev;
+	struct device *dev;
+	struct resource *res;
+	void *base_addr;
+	const char *mac;
+	int ret = 0;
+
+	pdev = pdata->pdev;
+	dev = &pdev->dev;
+	ndev = pdata->ndev;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(dev, "Resource IORESOURCE_MEM 0 not defined\n");
+		ret = -ENODEV;
+		goto out;
+	}
+	pdata->base_addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(pdata->base_addr)) {
+		dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
+		return PTR_ERR(pdata->base_addr);
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(dev, "Resource IORESOURCE_MEM 1 not defined\n");
+		ret = -ENODEV;
+		goto out;
+	}
+	pdata->ring_csr_addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(pdata->ring_csr_addr)) {
+		dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
+		return PTR_ERR(pdata->ring_csr_addr);
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (!res) {
+		dev_err(dev, "Resource IORESOURCE_MEM 2 not defined\n");
+		ret = -ENODEV;
+		goto out;
+	}
+	pdata->ring_cmd_addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(pdata->ring_cmd_addr)) {
+		dev_err(dev, "Unable to retrieve ENET Ring command region\n");
+		return PTR_ERR(pdata->ring_cmd_addr);
+	}
+
+	ret = platform_get_irq(pdev, 0);
+	if (ret <= 0) {
+		dev_err(dev, "Unable to get ENET Rx IRQ\n");
+		goto out;
+	}
+	pdata->rx_irq = ret;
+
+	mac = of_get_mac_address(dev->of_node);
+	if (mac)
+		memcpy(ndev->dev_addr, mac, ndev->addr_len);
+	else
+		eth_hw_addr_random(ndev);
+	memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
+
+	pdata->phy_mode = of_get_phy_mode(pdev->dev.of_node);
+	if (pdata->phy_mode < 0) {
+		dev_err(dev, "Incorrect phy-connection-type in DTS\n");
+		ret = -EINVAL;
+		goto out;
+	}
+
+	pdata->clk = devm_clk_get(&pdev->dev, NULL);
+	ret = IS_ERR(pdata->clk);
+	if (ret) {
+		dev_err(&pdev->dev, "can't get clock\n");
+		goto out;
+	}
+
+	base_addr = pdata->base_addr;
+	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
+	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
+	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
+	pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
+	pdata->mcx_stats_addr = base_addr + BLOCK_ETH_STATS_OFFSET;
+	pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
+	pdata->rx_buff_cnt = NUM_PKT_BUF;
+out:
+	return ret;
+}
+
+static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
+{
+	struct net_device *ndev = pdata->ndev;
+	struct xgene_enet_desc_ring *buf_pool;
+	int ret = 0;
+
+	xgene_enet_reset(pdata);
+
+	xgene_gmac_tx_disable(pdata);
+	xgene_gmac_rx_disable(pdata);
+
+	ret = xgene_enet_create_desc_rings(ndev);
+	if (ret) {
+		netdev_err(ndev, "Error in ring configuration\n");
+		goto out;
+	}
+
+	/* setup buffer pool */
+	buf_pool = pdata->rx_ring->buf_pool;
+	xgene_enet_init_bufpool(buf_pool);
+	ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
+	if (ret)
+		goto out;
+
+	xgene_enet_cle_bypass(pdata, xgene_enet_dst_ring_num(pdata->rx_ring),
+			      RING_BUFNUM(buf_pool) - 0x20, 0);
+	xgene_gmac_init(pdata, SPEED_1000);
+out:
+	return ret;
+}
+
+static int xgene_enet_probe(struct platform_device *pdev)
+{
+	struct net_device *ndev;
+	struct xgene_enet_pdata *pdata;
+	struct device *dev = &pdev->dev;
+	struct napi_struct *napi;
+	int ret = 0;
+
+	ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
+	if (!ndev)
+		return -ENOMEM;
+
+	pdata = netdev_priv(ndev);
+
+	pdata->pdev = pdev;
+	pdata->ndev = ndev;
+	SET_NETDEV_DEV(ndev, dev);
+	platform_set_drvdata(pdev, pdata);
+	ndev->netdev_ops = &xgene_ndev_ops;
+	ndev->features |= NETIF_F_IP_CSUM;
+	ndev->features |= NETIF_F_GSO;
+	ndev->features |= NETIF_F_GRO;
+
+	ret = xgene_enet_get_resources(pdata);
+	if (ret)
+		goto err;
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		netdev_err(ndev, "Failed to register netdev\n");
+		goto err;
+	}
+
+	ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
+	if (ret) {
+		netdev_err(ndev, "No usable DMA configuration\n");
+		goto err;
+	}
+
+	ret = xgene_enet_init_hw(pdata);
+	if (ret)
+		goto err;
+
+	napi = &pdata->rx_ring->napi;
+	netif_napi_add(ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
+	ret = xgene_enet_mdio_config(pdata);
+
+	return ret;
+err:
+	free_netdev(ndev);
+	return ret;
+}
+
+static int xgene_enet_remove(struct platform_device *pdev)
+{
+	struct xgene_enet_pdata *pdata;
+	struct net_device *ndev;
+
+	pdata = platform_get_drvdata(pdev);
+	ndev = pdata->ndev;
+
+	xgene_gmac_rx_disable(pdata);
+	xgene_gmac_tx_disable(pdata);
+
+	netif_napi_del(&pdata->rx_ring->napi);
+	xgene_enet_mdio_remove(pdata);
+	xgene_enet_delete_desc_rings(pdata);
+	unregister_netdev(ndev);
+	xgene_gport_shutdown(pdata);
+	free_netdev(ndev);
+
+	return 0;
+}
+
+static struct of_device_id xgene_enet_match[] = {
+	{.compatible = "apm,xgene-enet",},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, xgene_enet_match);
+
+static struct platform_driver xgene_enet_driver = {
+	.driver = {
+		   .name = "xgene-enet",
+		   .owner = THIS_MODULE,
+		   .of_match_table = xgene_enet_match,
+		   },
+	.probe = xgene_enet_probe,
+	.remove = xgene_enet_remove,
+};
+
+module_platform_driver(xgene_enet_driver);
+
+MODULE_DESCRIPTION("APM X-Gene SoC Ethernet driver");
+MODULE_VERSION("1.0");
+MODULE_AUTHOR("Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
new file mode 100644
index 0000000..3d20ecf
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -0,0 +1,131 @@
+/* Applied Micro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2014, Applied Micro Circuits Corporation
+ * Authors: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
+ *	    Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
+ *	    Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_MAIN_H__
+#define __XGENE_ENET_MAIN_H__
+
+#include <linux/clk.h>
+#include <linux/of_platform.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <linux/if_vlan.h>
+#include <linux/phy.h>
+#include "xgene_enet_hw.h"
+
+#define XGENE_ENET_MAX_MTU	1536
+#define SKB_BUFFER_SIZE		(XGENE_ENET_MAX_MTU - NET_IP_ALIGN)
+
+#define NUM_PKT_BUF	64
+#define NUM_BUFPOOL	32
+
+/* software context of a descriptor ring */
+struct xgene_enet_desc_ring {
+	struct net_device *ndev;
+	u16 id;
+	u16 num;
+	u16 head;
+	u16 tail;
+	u16 slots;
+	u16 irq;
+	u32 size;
+	u32 state[NUM_RING_CONFIG];
+	void __iomem *cmd_base;
+	void __iomem *cmd;
+	dma_addr_t dma;
+	u16 dst_ring_num;
+	u8 nbufpool;
+	struct sk_buff *(*rx_skb);
+	struct sk_buff *(*cp_skb);
+	enum xgene_enet_ring_cfgsize cfgsize;
+	struct xgene_enet_desc_ring *cp_ring;
+	struct xgene_enet_desc_ring *buf_pool;
+	struct napi_struct napi;
+	union {
+		void *desc_addr;
+		struct xgene_enet_desc *desc;
+		struct xgene_enet_desc16 *desc16;
+	};
+};
+
+struct xgene_enet_rx_stats {
+	u32 byte_cntr;
+	u32 pkt_cntr;
+	u32 fcs_error_cntr;
+	u32 align_err_cntr;
+	u32 frm_len_err_cntr;
+	u32 undersize_pkt_cntr;
+	u32 oversize_pkt_cntr;
+	u32 dropped_pkt_cntr;
+};
+
+struct xgene_enet_tx_stats {
+	u32 byte_cntr;
+	u32 pkt_cntr;
+	u32 drop_frame_cntr;
+	u32 fcs_error_cntr;
+	u32 undersize_frame_cntr;
+};
+
+struct xgene_enet_stats {
+	struct xgene_enet_rx_stats rx_stats;
+	struct xgene_enet_tx_stats tx_stats;
+};
+
+/* ethernet private data */
+struct xgene_enet_pdata {
+	struct net_device *ndev;
+	struct mii_bus *mdio_bus;
+	struct phy_device *phy_dev;
+	int phy_link;
+	int phy_speed;
+	struct clk *clk;
+	struct platform_device *pdev;
+	struct xgene_enet_desc_ring *tx_ring;
+	struct xgene_enet_desc_ring *rx_ring;
+	struct net_device_stats nstats;
+	char *dev_name;
+	u32 rx_buff_cnt;
+	u32 tx_qcnt_hi;
+	u32 cp_qcnt_hi;
+	u32 cp_qcnt_low;
+	u32 rx_irq;
+	void __iomem *eth_csr_addr;
+	void __iomem *eth_ring_if_addr;
+	void __iomem *eth_diag_csr_addr;
+	void __iomem *mcx_mac_addr;
+	void __iomem *mcx_stats_addr;
+	void __iomem *mcx_mac_csr_addr;
+	void __iomem *base_addr;
+	void __iomem *ring_csr_addr;
+	void __iomem *ring_cmd_addr;
+	u32 phy_addr;
+	int phy_mode;
+	u32 speed;
+	u16 rm;
+	spinlock_t stats_lock;
+};
+
+int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata);
+int xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata);
+
+#endif /* __XGENE_ENET_MAIN_H__ */
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
