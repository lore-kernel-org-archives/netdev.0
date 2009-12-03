From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 09/18] Bluetooth: Fix handling of BNEP setup connection requests
Date: Thu,  3 Dec 2009 19:45:46 +0100
Message-ID: <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbZLCSp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:59 -0500
In-Reply-To: <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vikram Kandukuri <vkandukuri@atheros.com>

According to BNEP test specification the proper response should be sent
for a setup connection request message after the BNEP connection setup
has been completed.

Signed-off-by: Vikram Kandukuri <vikram.kandukuri@atheros.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/bnep/core.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index cafe9f5..29b1b22 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -230,7 +230,6 @@ static int bnep_rx_control(struct bnep_session *s, void *data, int len)
 
 	switch (cmd) {
 	case BNEP_CMD_NOT_UNDERSTOOD:
-	case BNEP_SETUP_CONN_REQ:
 	case BNEP_SETUP_CONN_RSP:
 	case BNEP_FILTER_NET_TYPE_RSP:
 	case BNEP_FILTER_MULTI_ADDR_RSP:
@@ -245,6 +244,10 @@ static int bnep_rx_control(struct bnep_session *s, void *data, int len)
 		err = bnep_ctrl_set_mcfilter(s, data, len);
 		break;
 
+	case BNEP_SETUP_CONN_REQ:
+		err = bnep_send_rsp(s, BNEP_SETUP_CONN_RSP, BNEP_CONN_NOT_ALLOWED);
+		break;
+
 	default: {
 			u8 pkt[3];
 			pkt[0] = BNEP_CONTROL;
-- 
1.6.5.2

