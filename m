From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/8] qlge: Add probe regs to firmware dump.
Date: Mon, 11 Jan 2010 17:13:00 -0800
Message-ID: <1263258785-5112-4-git-send-email-ron.mercer@qlogic.com>
References: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47621 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab0ALBTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 20:19:42 -0500
In-Reply-To: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c |  191 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 191 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index bacad16..a822456 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -148,6 +148,190 @@ static int ql_get_mpi_regs(struct ql_adapter *qdev, u32 * buf,
 	return status;
 }
 
+/* Read the ASIC probe dump */
+static unsigned int *ql_get_probe(struct ql_adapter *qdev, u32 clock,
+					u8 *valid, u32 *buf)
+{
+	u32 module, mux_sel, probe, lo_val, hi_val;
+
+	for (module = 0; module < MAX_MODULES; module++) {
+		if (valid[module]) {
+			for (mux_sel = 0; mux_sel < MAX_MUX; mux_sel++) {
+				probe = clock | ADDRESS_REGISTER_ENABLE |
+						mux_sel | (module << 9);
+				ql_write32(qdev, PRB_MX_ADDR, probe);
+				lo_val = ql_read32(qdev, PRB_MX_DATA);
+				if (mux_sel == 0) {
+					*buf = probe;
+					buf++;
+				}
+				probe |= UP;
+				ql_write32(qdev, PRB_MX_ADDR, probe);
+				hi_val = ql_read32(qdev, PRB_MX_DATA);
+				*buf = lo_val;
+				buf++;
+				*buf = hi_val;
+				buf++;
+			}
+		}
+	}
+	return buf;
+}
+
+static int ql_get_probe_dump(struct ql_adapter *qdev, unsigned int *buf)
+{
+
+	unsigned char sys_clock_valid_modules[0x20] = {
+				1,	/* 0x00 */
+				1,	/* 0x01 */
+				1,	/* 0x02 */
+				0,	/* 0x03 */
+				1,	/* 0x04 */
+				1,	/* 0x05 */
+				1,	/* 0x06 */
+				1,	/* 0x07 */
+				1,	/* 0x08 */
+				1,	/* 0x09 */
+				1,	/* 0x0A */
+				1,	/* 0x0B */
+				1,	/* 0x0C */
+				1,	/* 0x0D */
+				1,	/* 0x0E */
+				0,	/* 0x0F */
+				1,	/* 0x10 */
+				1,	/* 0x11 */
+				1,	/* 0x12 */
+				1,	/* 0x13 */
+				0,	/* 0x14 */
+				0,	/* 0x15 */
+				0,	/* 0x16 */
+				0,	/* 0x17 */
+				0,	/* 0x18 */
+				0,	/* 0x19 */
+				0,	/* 0x1A */
+				0,	/* 0x1B */
+				0,	/* 0x1C */
+				0,	/* 0x1D */
+				0,	/* 0x1E */
+				0	/* 0x1F */
+			};
+
+
+	unsigned char pci_clock_valid_modules[0x20] = {
+				1,	/* 0x00 */
+				0,	/* 0x01 */
+				0,	/* 0x02 */
+				0,	/* 0x03 */
+				0,	/* 0x04 */
+				0,	/* 0x05 */
+				1,	/* 0x06 */
+				1,	/* 0x07 */
+				0,	/* 0x08 */
+				0,	/* 0x09 */
+				0,	/* 0x0A */
+				0,	/* 0x0B */
+				0,	/* 0x0C */
+				0,	/* 0x0D */
+				1,	/* 0x0E */
+				0,	/* 0x0F */
+				0,	/* 0x10 */
+				0,	/* 0x11 */
+				0,	/* 0x12 */
+				0,	/* 0x13 */
+				0,	/* 0x14 */
+				0,	/* 0x15 */
+				0,	/* 0x16 */
+				0,	/* 0x17 */
+				0,	/* 0x18 */
+				0,	/* 0x19 */
+				0,	/* 0x1A */
+				0,	/* 0x1B */
+				0,	/* 0x1C */
+				0,	/* 0x1D */
+				0,	/* 0x1E */
+				0	/* 0x1F */
+			};
+
+	unsigned char xgm_clock_valid_modules[0x20] = {
+				1,	/* 0x00 */
+				0,	/* 0x01 */
+				0,	/* 0x02 */
+				1,	/* 0x03 */
+				0,	/* 0x04 */
+				0,	/* 0x05 */
+				0,	/* 0x06 */
+				0,	/* 0x07 */
+				1,	/* 0x08 */
+				1,	/* 0x09 */
+				0,	/* 0x0A */
+				0,	/* 0x0B */
+				1,	/* 0x0C */
+				1,	/* 0x0D */
+				1,	/* 0x0E */
+				0,	/* 0x0F */
+				1,	/* 0x10 */
+				1,	/* 0x11 */
+				0,	/* 0x12 */
+				0,	/* 0x13 */
+				0,	/* 0x14 */
+				0,	/* 0x15 */
+				0,	/* 0x16 */
+				0,	/* 0x17 */
+				0,	/* 0x18 */
+				0,	/* 0x19 */
+				0,	/* 0x1A */
+				0,	/* 0x1B */
+				0,	/* 0x1C */
+				0,	/* 0x1D */
+				0,	/* 0x1E */
+				0	/* 0x1F */
+			};
+
+	unsigned char fc_clock_valid_modules[0x20] = {
+				1,	/* 0x00 */
+				0,	/* 0x01 */
+				0,	/* 0x02 */
+				0,	/* 0x03 */
+				0,	/* 0x04 */
+				0,	/* 0x05 */
+				0,	/* 0x06 */
+				0,	/* 0x07 */
+				0,	/* 0x08 */
+				0,	/* 0x09 */
+				0,	/* 0x0A */
+				0,	/* 0x0B */
+				1,	/* 0x0C */
+				1,	/* 0x0D */
+				0,	/* 0x0E */
+				0,	/* 0x0F */
+				0,	/* 0x10 */
+				0,	/* 0x11 */
+				0,	/* 0x12 */
+				0,	/* 0x13 */
+				0,	/* 0x14 */
+				0,	/* 0x15 */
+				0,	/* 0x16 */
+				0,	/* 0x17 */
+				0,	/* 0x18 */
+				0,	/* 0x19 */
+				0,	/* 0x1A */
+				0,	/* 0x1B */
+				0,	/* 0x1C */
+				0,	/* 0x1D */
+				0,	/* 0x1E */
+				0	/* 0x1F */
+			};
+
+	/* First we have to enable the probe mux */
+	ql_write_mpi_reg(qdev, 0x100e, 0x18a20000);
+	buf = ql_get_probe(qdev, SYS_CLOCK, sys_clock_valid_modules, buf);
+	buf = ql_get_probe(qdev, PCI_CLOCK, pci_clock_valid_modules, buf);
+	buf = ql_get_probe(qdev, XGM_CLOCK, xgm_clock_valid_modules, buf);
+	buf = ql_get_probe(qdev, FC_CLOCK, fc_clock_valid_modules, buf);
+
+	return 0;
+
+}
 
 /* Read out the routing index registers */
 static int ql_get_routing_index_registers(struct ql_adapter *qdev, u32 *buf)
@@ -571,6 +755,13 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	if (status)
 		goto err;
 
+	ql_build_coredump_seg_header(&mpi_coredump->probe_dump_seg_hdr,
+				PROBE_DUMP_SEG_NUM,
+				sizeof(struct mpi_coredump_segment_header)
+				+ sizeof(mpi_coredump->probe_dump),
+				"Probe Dump");
+	ql_get_probe_dump(qdev, &mpi_coredump->probe_dump[0]);
+
 	ql_build_coredump_seg_header(&mpi_coredump->routing_reg_seg_hdr,
 				ROUTING_INDEX_SEG_NUM,
 				sizeof(struct mpi_coredump_segment_header)
-- 
1.6.0.2

