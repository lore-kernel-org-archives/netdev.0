From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] skge: serial mode register values
Date: Wed, 28 Nov 2007 14:23:01 -0800
Message-ID: <20071128142301.116526f4@freepuppy.rosehill>
References: <20071126195447.846382144@linux-foundation.org>
	<20071126195557.815206367@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60566 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755333AbXK1Xa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 18:30:58 -0500
In-Reply-To: <20071126195557.815206367@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For compatiablity with sk98lin, make sure and set same values
in serial mode register.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
Please apply for 2.6.24 (upstream-fixes) after the previous group
of skge patches (1.13)

--- a/drivers/net/skge.c	2007-11-28 09:27:02.000000000 -0800
+++ b/drivers/net/skge.c	2007-11-28 10:53:26.000000000 -0800
@@ -2190,9 +2190,12 @@ static void yukon_mac_init(struct skge_h
 			 TX_JAM_IPG_VAL(TX_JAM_IPG_DEF) |
 			 TX_IPG_JAM_DATA(TX_IPG_JAM_DEF));
 
-	/* serial mode register */
-	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
-	if (hw->dev[port]->mtu > 1500)
+	/* configure the Serial Mode Register */
+	reg = DATA_BLIND_VAL(DATA_BLIND_DEF)
+		| GM_SMOD_VLAN_ENA
+		| IPG_DATA_VAL(IPG_DATA_DEF);
+
+	if (hw->dev[port]->mtu > ETH_DATA_LEN)
 		reg |= GM_SMOD_JUMBO_ENA;
 
 	gma_write16(hw, port, GM_SERIAL_MODE, reg);
