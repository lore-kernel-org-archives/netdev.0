From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH]iwlwifi not correctly dealing with hotunplug
Date: Tue, 13 Nov 2007 12:49:24 +0100
Message-ID: <200711131249.25320.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out001.kontent.com ([81.88.40.215]:35691 "EHLO
	smtp-out001.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbXKMLrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:47:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It makes no sense to enable interrupts if a device has been unplugged.
In addition if in doubt IRQ_HANDLED should be returned.

Signed-off-by: Oliver Neukum <oneukum@suse.de>

	Regards
		Oliver

----

--- linux-2.6.24-rc1/drivers/net/wireless/iwlwifi/iwl3945-base.c.alt	2007-11-13 12:23:07.000000000 +0100
+++ linux-2.6.24-rc1/drivers/net/wireless/iwlwifi/iwl3945-base.c	2007-11-13 12:26:00.000000000 +0100
@@ -4850,7 +4850,7 @@ static irqreturn_t iwl_isr(int irq, void
 	if ((inta == 0xFFFFFFFF) || ((inta & 0xFFFFFFF0) == 0xa5a5a5a0)) {
 		/* Hardware disappeared */
 		IWL_WARNING("HARDWARE GONE?? INTA == 0x%080x\n", inta);
-		goto none;
+		goto unplugged;
 	}
 
 	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
@@ -4858,6 +4858,7 @@ static irqreturn_t iwl_isr(int irq, void
 
 	/* iwl_irq_tasklet() will service interrupts and re-enable them */
 	tasklet_schedule(&priv->irq_tasklet);
+unplugged:
 	spin_unlock(&priv->lock);
 
 	return IRQ_HANDLED;
