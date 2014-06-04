From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 1/6] dm9000: acquire irq flags from device tree
Date: Wed,  4 Jun 2014 17:28:44 -0500
Message-ID: <1994ef1f22c99cf021b0e096b12509f29ac400d5.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:34831 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbaFDWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:56 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 3D4754A8
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:13 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DM9000 supports both active high interrupts and active low interrupts.
This is configured via the attached EEPROM.  In the device-tree case, make sure
that the DM9000 driver passes the correct flags to request_irq.

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index a1a2b40..9d44c3f 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1292,6 +1292,9 @@ dm9000_open(struct net_device *dev)
 	 * may work, and tell the user that this is a problem */
 
 	if (irqflags == IRQF_TRIGGER_NONE)
+		irqflags = irq_get_trigger_type(dev->irq);
+
+	if (irqflags == IRQF_TRIGGER_NONE)
 		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
 
 	irqflags |= IRQF_SHARED;
-- 
1.9.0.rc3.12.gbc97e2d
