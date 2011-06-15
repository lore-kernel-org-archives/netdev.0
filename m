From: Antoine Reversat <a.reversat@gmail.com>
Subject: [PATCH 001/001] forcedeth: Don't enable hardware vlan support on
 hardware that doesn't support it
Date: Wed, 15 Jun 2011 16:17:29 -0400
Message-ID: <BANLkTinoW_zEVkm0-bC=3k600-jxf4j5uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63829 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856Ab1FOURa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 16:17:30 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so770329bwz.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 13:17:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the forcedeth driver hardware vlan support is used even on hardware
that doesn't support it leading to incorrect tagging of some packets
when using vlan.

Signed-off-by: Antoine Reversat <a.reversat@gmail.com>
---
--- linux-2.6.39/drivers/net/forcedeth.c	2011-05-19 00:06:34.000000000 -0400
+++ linux-2.6.39-fixed/drivers/net/forcedeth.c	2011-06-15
15:57:45.331158001 -0400
@@ -4915,6 +4915,10 @@ static void nv_vlan_rx_register(struct n
 {
 	struct fe_priv *np = get_nvpriv(dev);

+	/* Don't do anything if device doesn't support VLAN */
+	if (!(np->driver_data & DEV_HAS_VLAN))
+		return;
+
 	spin_lock_irq(&np->lock);

 	/* save vlan group */
