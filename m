From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/6] sky2: disable support for 88E8056
Date: Wed, 11 Apr 2007 14:47:58 -0700
Message-ID: <20070411214859.649647641@linux-foundation.org>
References: <20070411214757.194710334@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34858 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030470AbXDKWah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 18:30:37 -0400
Content-Disposition: inline; filename=sky2-8056-disable.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This device is having all sorts of problems that lead to data corruption
and system instability.  It gets receive status and data out of order,
it generates descriptor and TSO errors, etc.

Until the problems are resolved, it should not be used by anyone
who cares about there system.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-04-11 14:06:38.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-04-11 14:07:36.000000000 -0700
@@ -123,7 +123,10 @@ static const struct pci_device_id sky2_i
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
+#ifdef broken
+	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
+#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */

--
Stephen Hemminger <shemminger@linux-foundation.org>

