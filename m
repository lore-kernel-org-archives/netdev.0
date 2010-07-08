From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 01/13] Bluetooth: Remove max_tx and tx_window module paramenters from L2CAP
Date: Thu,  8 Jul 2010 16:59:50 -0300
Message-ID: <1901cc314ec34e25e18600ba000c5edc43a63544.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36210 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:28 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

We don't need these parameters anymore since we have socket options for
them.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 1b682a5..5c636b3 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -60,8 +60,6 @@ static int enable_ertm = 1;
 #else
 static int enable_ertm = 0;
 #endif
-static int max_transmit = L2CAP_DEFAULT_MAX_TX;
-static int tx_window = L2CAP_DEFAULT_TX_WINDOW;
 
 static u32 l2cap_feat_mask = L2CAP_FEAT_FIXED_CHAN;
 static u8 l2cap_fixed_chan[8] = { 0x02, };
@@ -808,9 +806,9 @@ static void l2cap_sock_init(struct sock *sk, struct sock *parent)
 			pi->mode = L2CAP_MODE_ERTM;
 		else
 			pi->mode = L2CAP_MODE_BASIC;
-		pi->max_tx = max_transmit;
+		pi->max_tx = L2CAP_DEFAULT_MAX_TX;
 		pi->fcs  = L2CAP_FCS_CRC16;
-		pi->tx_win = tx_window;
+		pi->tx_win = L2CAP_DEFAULT_TX_WINDOW;
 		pi->sec_level = BT_SECURITY_LOW;
 		pi->role_switch = 0;
 		pi->force_reliable = 0;
@@ -4674,12 +4672,6 @@ module_exit(l2cap_exit);
 module_param(enable_ertm, bool, 0644);
 MODULE_PARM_DESC(enable_ertm, "Enable enhanced retransmission mode");
 
-module_param(max_transmit, uint, 0644);
-MODULE_PARM_DESC(max_transmit, "Max transmit value (default = 3)");
-
-module_param(tx_window, uint, 0644);
-MODULE_PARM_DESC(tx_window, "Transmission window size value (default = 63)");
-
 MODULE_AUTHOR("Marcel Holtmann <marcel@holtmann.org>");
 MODULE_DESCRIPTION("Bluetooth L2CAP ver " VERSION);
 MODULE_VERSION(VERSION);
-- 
1.7.1.1

