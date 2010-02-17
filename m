From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/2] Staging: Octeon: Remove /proc/octeon_ethernet_stats
Date: Tue, 16 Feb 2010 17:25:33 -0800
Message-ID: <1266369933-1282-2-git-send-email-ddaney@caviumnetworks.com>
References: <4B7B4540.1010700@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:6670 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933864Ab0BQBZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 20:25:45 -0500
In-Reply-To: <4B7B4540.1010700@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file shouldn't be in /proc, so we remove it.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/Makefile        |    1 -
 drivers/staging/octeon/ethernet-proc.c |  144 --------------------------------
 drivers/staging/octeon/ethernet-proc.h |   29 -------
 drivers/staging/octeon/ethernet.c      |    4 -
 4 files changed, 0 insertions(+), 178 deletions(-)
 delete mode 100644 drivers/staging/octeon/ethernet-proc.c
 delete mode 100644 drivers/staging/octeon/ethernet-proc.h

diff --git a/drivers/staging/octeon/Makefile b/drivers/staging/octeon/Makefile
index c0a583c..87447c1 100644
--- a/drivers/staging/octeon/Makefile
+++ b/drivers/staging/octeon/Makefile
@@ -14,7 +14,6 @@ obj-${CONFIG_OCTEON_ETHERNET} :=  octeon-ethernet.o
 octeon-ethernet-objs := ethernet.o
 octeon-ethernet-objs += ethernet-mdio.o
 octeon-ethernet-objs += ethernet-mem.o
-octeon-ethernet-objs += ethernet-proc.o
 octeon-ethernet-objs += ethernet-rgmii.o
 octeon-ethernet-objs += ethernet-rx.o
 octeon-ethernet-objs += ethernet-sgmii.o
diff --git a/drivers/staging/octeon/ethernet-proc.c b/drivers/staging/octeon/ethernet-proc.c
deleted file mode 100644
index 16308d4..0000000
--- a/drivers/staging/octeon/ethernet-proc.c
+++ /dev/null
@@ -1,144 +0,0 @@
-/**********************************************************************
- * Author: Cavium Networks
- *
- * Contact: support@caviumnetworks.com
- * This file is part of the OCTEON SDK
- *
- * Copyright (c) 2003-2007 Cavium Networks
- *
- * This file is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License, Version 2, as
- * published by the Free Software Foundation.
- *
- * This file is distributed in the hope that it will be useful, but
- * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
- * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this file; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
- * or visit http://www.gnu.org/licenses/.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium Networks for more information
-**********************************************************************/
-#include <linux/kernel.h>
-#include <linux/seq_file.h>
-#include <linux/proc_fs.h>
-#include <net/dst.h>
-
-#include <asm/octeon/octeon.h>
-
-#include "octeon-ethernet.h"
-#include "ethernet-defines.h"
-
-#include "cvmx-helper.h"
-#include "cvmx-pip.h"
-
-/**
- * User is reading /proc/octeon_ethernet_stats
- *
- * @m:
- * @v:
- * Returns
- */
-static int cvm_oct_stats_show(struct seq_file *m, void *v)
-{
-	struct octeon_ethernet *priv;
-	int port;
-
-	for (port = 0; port < TOTAL_NUMBER_OF_PORTS; port++) {
-
-		if (cvm_oct_device[port]) {
-			priv = netdev_priv(cvm_oct_device[port]);
-
-			seq_printf(m, "\nOcteon Port %d (%s)\n", port,
-				   cvm_oct_device[port]->name);
-			seq_printf(m,
-				   "rx_packets:             %12lu\t"
-				   "tx_packets:             %12lu\n",
-				   priv->stats.rx_packets,
-				   priv->stats.tx_packets);
-			seq_printf(m,
-				   "rx_bytes:               %12lu\t"
-				   "tx_bytes:               %12lu\n",
-				   priv->stats.rx_bytes, priv->stats.tx_bytes);
-			seq_printf(m,
-				   "rx_errors:              %12lu\t"
-				   "tx_errors:              %12lu\n",
-				   priv->stats.rx_errors,
-				   priv->stats.tx_errors);
-			seq_printf(m,
-				   "rx_dropped:             %12lu\t"
-				   "tx_dropped:             %12lu\n",
-				   priv->stats.rx_dropped,
-				   priv->stats.tx_dropped);
-			seq_printf(m,
-				   "rx_length_errors:       %12lu\t"
-				   "tx_aborted_errors:      %12lu\n",
-				   priv->stats.rx_length_errors,
-				   priv->stats.tx_aborted_errors);
-			seq_printf(m,
-				   "rx_over_errors:         %12lu\t"
-				   "tx_carrier_errors:      %12lu\n",
-				   priv->stats.rx_over_errors,
-				   priv->stats.tx_carrier_errors);
-			seq_printf(m,
-				   "rx_crc_errors:          %12lu\t"
-				   "tx_fifo_errors:         %12lu\n",
-				   priv->stats.rx_crc_errors,
-				   priv->stats.tx_fifo_errors);
-			seq_printf(m,
-				   "rx_frame_errors:        %12lu\t"
-				   "tx_heartbeat_errors:    %12lu\n",
-				   priv->stats.rx_frame_errors,
-				   priv->stats.tx_heartbeat_errors);
-			seq_printf(m,
-				   "rx_fifo_errors:         %12lu\t"
-				   "tx_window_errors:       %12lu\n",
-				   priv->stats.rx_fifo_errors,
-				   priv->stats.tx_window_errors);
-			seq_printf(m,
-				   "rx_missed_errors:       %12lu\t"
-				   "multicast:              %12lu\n",
-				   priv->stats.rx_missed_errors,
-				   priv->stats.multicast);
-		}
-	}
-
-	return 0;
-}
-
-/**
- * /proc/octeon_ethernet_stats was openned. Use the single_open iterator
- *
- * @inode:
- * @file:
- * Returns
- */
-static int cvm_oct_stats_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, cvm_oct_stats_show, NULL);
-}
-
-static const struct file_operations cvm_oct_stats_operations = {
-	.open = cvm_oct_stats_open,
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
-
-void cvm_oct_proc_initialize(void)
-{
-	struct proc_dir_entry *entry =
-	    create_proc_entry("octeon_ethernet_stats", 0, NULL);
-	if (entry)
-		entry->proc_fops = &cvm_oct_stats_operations;
-}
-
-void cvm_oct_proc_shutdown(void)
-{
-	remove_proc_entry("octeon_ethernet_stats", NULL);
-}
diff --git a/drivers/staging/octeon/ethernet-proc.h b/drivers/staging/octeon/ethernet-proc.h
deleted file mode 100644
index 82c7d9f..0000000
--- a/drivers/staging/octeon/ethernet-proc.h
+++ /dev/null
@@ -1,29 +0,0 @@
-/*********************************************************************
- * Author: Cavium Networks
- *
- * Contact: support@caviumnetworks.com
- * This file is part of the OCTEON SDK
- *
- * Copyright (c) 2003-2007 Cavium Networks
- *
- * This file is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License, Version 2, as
- * published by the Free Software Foundation.
- *
- * This file is distributed in the hope that it will be useful, but
- * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
- * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
- * NONINFRINGEMENT.  See the GNU General Public License for more
- * details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this file; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
- * or visit http://www.gnu.org/licenses/.
- *
- * This file may also be available under a different license from Cavium.
- * Contact Cavium Networks for more information
-*********************************************************************/
-
-void cvm_oct_proc_initialize(void);
-void cvm_oct_proc_shutdown(void);
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 45cb4c7..02b6367 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -42,8 +42,6 @@
 #include "ethernet-tx.h"
 #include "ethernet-mdio.h"
 #include "ethernet-util.h"
-#include "ethernet-proc.h"
-
 
 #include "cvmx-pip.h"
 #include "cvmx-pko.h"
@@ -621,7 +619,6 @@ static int __init cvm_oct_init_module(void)
 		return -ENOMEM;
 	}
 
-	cvm_oct_proc_initialize();
 	cvm_oct_configure_common_hw();
 
 	cvmx_helper_initialize_packet_io_global();
@@ -828,7 +825,6 @@ static void __exit cvm_oct_cleanup_module(void)
 	destroy_workqueue(cvm_oct_poll_queue);
 
 	cvmx_pko_shutdown();
-	cvm_oct_proc_shutdown();
 
 	cvmx_ipd_free_ptr();
 
-- 
1.6.6

