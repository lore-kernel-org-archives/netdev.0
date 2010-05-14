From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 20/25] wimax/i2400m: USB specific TX queue's minimum buffer room required for new message
Date: Fri, 14 May 2010 14:45:19 -0700
Message-ID: <7ef9f9a4ee47b8d8ab9519647ba02fc700473be8.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:45009 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932548Ab0ENVtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:18 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch specifies the TX queue's buffer room required by the
USB bus driver while allocating header space for a new message.
Please refer the documentation in the code.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/usb.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index d8c4d64..6fd8cf5 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -467,6 +467,13 @@ int i2400mu_probe(struct usb_interface *iface,
 	usb_set_intfdata(iface, i2400mu);
 
 	i2400m->bus_tx_block_size = I2400MU_BLK_SIZE;
+	/*
+	 * Room required in the Tx queue for USB message to accommodate
+	 * a smallest payload while allocating header space is 16 bytes.
+	 * Adding this room  for the new tx message increases the
+	 * possibilities of including any payload with size <= 16 bytes.
+	 */
+	i2400m->bus_tx_room_min = I2400MU_BLK_SIZE;
 	i2400m->bus_pl_size_max = I2400MU_PL_SIZE_MAX;
 	i2400m->bus_setup = NULL;
 	i2400m->bus_dev_start = i2400mu_bus_dev_start;
-- 
1.6.6.1

