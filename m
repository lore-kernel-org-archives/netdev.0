From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] cassini: NAPI configuration
Date: Wed, 21 Nov 2007 11:53:58 -0800
Message-ID: <20071121115358.2e31fb91@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60773 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752837AbXKUTyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 14:54:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Cassini driver has NAPI support, but it not possible to configure it.
Compile tested only, no idea if it works (no hardware).
Get rid of warning from lefover variable in now visible code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/Kconfig	2007-11-19 18:56:12.000000000 -0800
+++ b/drivers/net/Kconfig	2007-11-21 11:28:20.000000000 -0800
@@ -587,6 +587,15 @@ config CASSINI
 	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
 	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/817-4341-10.pdf>
 
+config CASSINI_NAPI
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
+	depends on CASSINI && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card.
+
+	  If in doubt, say N.
+
 config SUNVNET
 	tristate "Sun Virtual Network support"
 	depends on SUN_LDOMS
--- a/drivers/net/cassini.c	2007-11-16 16:17:20.000000000 -0800
+++ b/drivers/net/cassini.c	2007-11-21 11:30:43.000000000 -0800
@@ -2611,7 +2611,7 @@ static int cas_poll(struct napi_struct *
 {
 	struct cas *cp = container_of(napi, struct cas, napi);
 	struct net_device *dev = cp->dev;
-	int i, enable_intr, todo, credits;
+	int i, enable_intr, credits;
 	u32 status = readl(cp->regs + REG_INTR_STATUS);
 	unsigned long flags;
 
