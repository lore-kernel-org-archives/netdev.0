From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 4/6] ibm_newemac Use status property for unused/unwired EMACs
Date: Tue, 22 Apr 2008 10:46:44 +1000
Message-ID: <20080422004801.E6272DE2DD@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43486 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755612AbYDVAsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 20:48:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@linux.vnet.ibm.com>

Convert ibm_newemac to use the of_device_is_available function when checking
for unused/unwired EMACs.  We leave the current check for an "unused" property
to maintain backwards compatibility for older device trees.  Newer device
trees should simply use the standard "status" property in the EMAC node.

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-04-22 10:42:42.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-04-22 10:43:01.000000000 +1000
@@ -2562,8 +2562,11 @@ static int __devinit emac_probe(struct o
 	struct device_node **blist = NULL;
 	int err, i;
 
-	/* Skip unused/unwired EMACS */
-	if (of_get_property(np, "unused", NULL))
+	/* Skip unused/unwired EMACS.  We leave the check for an unused
+	 * property here for now, but new flat device trees should set a
+	 * status property to "disabled" instead.
+	 */
+	if (of_get_property(np, "unused", NULL) || !of_device_is_available(np))
 		return -ENODEV;
 
 	/* Find ourselves in the bootlist if we are there */
