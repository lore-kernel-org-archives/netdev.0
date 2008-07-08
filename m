From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 12/25] ixgb: add copybreak parameter
Date: Tue, 08 Jul 2008 15:52:02 -0700
Message-ID: <20080708225202.6925.40485.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26406 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753765AbYGHWwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:05 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

copybreak code was already in the driver, allow the user to turn it
off if they don't like it.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index bd08e19..4e422c4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -40,6 +40,12 @@ static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 const char ixgb_driver_version[] = DRV_VERSION;
 static const char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
+#define IXGB_CB_LENGTH 256
+static unsigned int copybreak __read_mostly = IXGB_CB_LENGTH;
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
 /* ixgb_pci_tbl - PCI Device ID Table
  *
  * Wildcard entries (PCI_ANY_ID) should come last
@@ -1976,8 +1982,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */
-#define IXGB_CB_LENGTH 256
-		if (length < IXGB_CB_LENGTH) {
+		if (length < copybreak) {
 			struct sk_buff *new_skb =
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {

