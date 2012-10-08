From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH] skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard
Date: Mon,  8 Oct 2012 18:54:35 +0200
Message-ID: <1349715275-12730-1-git-send-email-jan.ceuleers@computer.org>
Cc: netdev@vger.kernel.org, Graham Gower <graham.gower@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:60497 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043Ab2JHQyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 12:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham Gower <graham.gower@gmail.com>

Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to send/receive
packets on a system with >4gb ram unless a 32bit DMA mask is used.

This issue has been around for years and a fix was sent 3.5 years ago, but
there was some debate as to whether it should instead be fixed as a PCI quirk.
http://www.spinics.net/lists/netdev/msg88670.html

However, 18 months later a similar workaround was introduced for another
chipset exhibiting the same problem.
http://www.spinics.net/lists/netdev/msg142287.html

Signed-off-by: Graham Gower <graham.gower@gmail.com>
Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
I am resubmitting Graham's v4 patch hoping that doing so will avoid further
frustration while still getting this fix into the tree.
I have not tested this; I don't have the hardware. It compiles though.

 drivers/net/ethernet/marvell/skge.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5a30bf8..05b3c83 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4153,6 +4153,13 @@ static struct dmi_system_id skge_32bit_dma_boards[] = {
 			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
 		},
 	},
+	{
+		.ident = "ASUS P5NSLI",
+		.matches = {
+			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
+			DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")
+		},
+	}, 
 	{}
 };
 
-- 
1.7.9.5
