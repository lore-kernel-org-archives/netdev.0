From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] can: sja1000: fix bug using library functions for skb allocation
Date: Mon, 26 Oct 2009 16:46:12 +0100
Message-ID: <4AE5C444.9030804@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52572 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbZJZPqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 11:46:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7b6856a0 "can: provide library functions for skb allocation"
did not properly remove two lines of the SJA1000 driver resulting in
a 'skb_over_panic' when calling skb_put, as reported by Kurt.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/sja1000.c |    2 --
 1 file changed, 2 deletions(-)

Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c
@@ -321,8 +321,6 @@ static void sja1000_rx(struct net_device
 	if (fi & FI_RTR)
 		id |= CAN_RTR_FLAG;

-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-	memset(cf, 0, sizeof(struct can_frame));
 	cf->can_id = id;
 	cf->can_dlc = dlc;
 	for (i = 0; i < dlc; i++)
