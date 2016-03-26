From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 2/2 net-next v3.16]r9169:  Search for registers on set_rx_mode
Date: Sat, 26 Mar 2016 12:57:01 +0200
Message-ID: <1458989821-19782-2-git-send-email-asd@marian1000.go.ro>
References: <1458989821-19782-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-230-247.residential.rdsnet.ro ([5.14.230.247]:45264 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbcCZLYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 07:24:47 -0400
In-Reply-To: <1458989821-19782-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch add searching for needed registers on set_rx_mode function
 and add delay to bee ready.This is for starting on full duplex on full
 speed.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f7b0dfb..0ae8969 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4604,6 +4604,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	int rx_mode;
 	u32 tmp = 0;
 
+	if (!(RTL_R32(MAR0) | RTL_R32(MAR0 + 4) | RTL_R32(RxConfig)))
+		return;
+
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
 		netif_notice(tp, link, dev, "Promiscuous mode enabled\n");
-- 
2.1.4
