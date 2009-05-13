From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/8] ixgbe: Add FCoE feature header to 82599
Date: Wed, 13 May 2009 16:10:01 -0700
Message-ID: <20090513231001.11416.93927.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:38622 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760772AbZEMXKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 19:10:19 -0400
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds the FCoE feature header ixgbe_fcoe.h to 82599. This header includes
the defines and structures required by the ixgbe driver to support various
offload features in 82599 for Fiber Channel over Ethernet (FCoE).  These offloads
features include Fiber Channel CRC calculation, FCoE SOF/EOF auto insertion,
FCoE Sequence Offload (FSO) for large send, and Direct Data Placement (DDP)
for large receive.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.h |   66 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_fcoe.h

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
new file mode 100644
index 0000000..d054c1d
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -0,0 +1,66 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_FCOE_H
+#define _IXGBE_FCOE_H
+
+#include <scsi/fc/fc_fcoe.h>
+
+/* shift bits within STAT fo FCSTAT */
+#define IXGBE_RXDADV_FCSTAT_SHIFT	4
+
+/* ddp user buffer */
+#define IXGBE_BUFFCNT_MAX	256	/* 8 bits bufcnt */
+#define IXGBE_FCPTR_ALIGN	16
+#define IXGBE_FCPTR_MAX	(IXGBE_BUFFCNT_MAX * sizeof(dma_addr_t))
+#define IXGBE_FCBUFF_4KB	0x0
+#define IXGBE_FCBUFF_8KB	0x1
+#define IXGBE_FCBUFF_16KB	0x2
+#define IXGBE_FCBUFF_64KB	0x3
+#define IXGBE_FCBUFF_MAX	65536	/* 64KB max */
+#define IXGBE_FCBUFF_MIN	4096	/* 4KB min */
+#define IXGBE_FCOE_DDP_MAX	512	/* 9 bits xid */
+
+/* fcerr */
+#define IXGBE_FCERR_BADCRC       0x00100000
+
+struct ixgbe_fcoe_ddp {
+	int len;
+	u32 err;
+	unsigned int sgc;
+	struct scatterlist *sgl;
+	dma_addr_t udp;
+	unsigned long *udl;
+};
+
+struct ixgbe_fcoe {
+	spinlock_t lock;
+	struct pci_pool *pool;
+	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
+};
+
+#endif /* _IXGBE_FCOE_H */

