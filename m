From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 16/18] Bluetooth: Add L2CAP option for max transmit value
Date: Thu,  3 Dec 2009 19:45:53 +0100
Message-ID: <5fbcd3d1a07e234583e17830e8aef47282c22141.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
 <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
 <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
 <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
 <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
 <32fd63981ed453bd882f22e3e9b0ccbc11fb47e5.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756133AbZLCSqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:03 -0500
In-Reply-To: <32fd63981ed453bd882f22e3e9b0ccbc11fb47e5.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For testing purposes it is important to modify the max transmit value.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index c898f34..5129b88 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -54,6 +54,7 @@
 #define VERSION "2.14"
 
 static int enable_ertm = 0;
+static int max_transmit = L2CAP_DEFAULT_MAX_TX;
 
 static u32 l2cap_feat_mask = L2CAP_FEAT_FIXED_CHAN;
 static u8 l2cap_fixed_chan[8] = { 0x02, };
@@ -2253,7 +2254,7 @@ done:
 	case L2CAP_MODE_ERTM:
 		rfc.mode            = L2CAP_MODE_ERTM;
 		rfc.txwin_size      = L2CAP_DEFAULT_TX_WINDOW;
-		rfc.max_transmit    = L2CAP_DEFAULT_MAX_TX;
+		rfc.max_transmit    = max_transmit;
 		rfc.retrans_timeout = 0;
 		rfc.monitor_timeout = 0;
 		rfc.max_pdu_size    = cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
@@ -4060,6 +4061,9 @@ module_exit(l2cap_exit);
 module_param(enable_ertm, bool, 0644);
 MODULE_PARM_DESC(enable_ertm, "Enable enhanced retransmission mode");
 
+module_param(max_transmit, uint, 0644);
+MODULE_PARM_DESC(max_transmit, "Max transmit value (default = 3)");
+
 MODULE_AUTHOR("Marcel Holtmann <marcel@holtmann.org>");
 MODULE_DESCRIPTION("Bluetooth L2CAP ver " VERSION);
 MODULE_VERSION(VERSION);
-- 
1.6.5.2

