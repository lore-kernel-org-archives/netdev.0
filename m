From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 8/8] ibm_newemac: Skip EMACs that are marked unused by the firmware
Date: Wed, 21 Nov 2007 17:06:46 +1100
Message-ID: <20071121060737.6AA72DDE0C@ozlabs.org>
References: <1195625198.76200.922309668615.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38967 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbXKUGHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 01:07:41 -0500
In-Reply-To: <1195625198.76200.922309668615.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugh Blemings <hugh@blemings.org>

Depending on how the 44x processors are wired, some EMAC cells
might not be useable (and not connected to a PHY). However, some
device-trees may choose to still expose them (since their registers
are present in the MMIO space) but with an "unused" property in them.

Signed-off-by: Hugh Blemings <hugh@blemings.org>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/core.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2007-11-20 14:47:02.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/core.c	2007-11-20 14:47:05.000000000 +1100
@@ -2550,6 +2550,10 @@ static int __devinit emac_probe(struct o
 	struct device_node **blist = NULL;
 	int err, i;
 
+	/* Skip unused/unwired EMACS */
+	if (of_get_property(np, "unused", NULL))
+		return -ENODEV;
+
 	/* Find ourselves in the bootlist if we are there */
 	for (i = 0; i < EMAC_BOOT_LIST_SIZE; i++)
 		if (emac_boot_list[i] == np)
