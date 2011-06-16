From: Antoine Reversat <a.reversat@gmail.com>
Subject: [PATCH 001/001] vlan: don't call ndo_vlan_rx_register on hardware
 that doesn't have vlan support
Date: Thu, 16 Jun 2011 16:47:13 -0400
Message-ID: <BANLkTimBm8rFF41RzAN6vk3o6SLy6cfZDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61827 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015Ab1FPUrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 16:47:14 -0400
Received: by bwz15 with SMTP id 15so282724bwz.19
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2011 13:47:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the call to ndo_vlan_rx_register if the underlying
device doesn't have hardware support for VLAN.
Signed-off-by: Antoine Reversat <a.reversat@gmail.com>
---
--- linux-2.6.39/net/8021q/vlan.c	2011-05-19 00:06:34.000000000 -0400
+++ linux-2.6.39-fixed/net/8021q/vlan.c	2011-06-16 16:39:25.933742004 -0400
@@ -211,7 +211,7 @@ int register_vlan_dev(struct net_device
 	grp->nr_vlans++;

 	if (ngrp) {
-		if (ops->ndo_vlan_rx_register)
+		if (ops->ndo_vlan_rx_register && (real_dev->features & NETIF_F_HW_VLAN_RX))
 			ops->ndo_vlan_rx_register(real_dev, ngrp);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
