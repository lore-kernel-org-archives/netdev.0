From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/6] Bluetooth: Fallback eSCO to SCO on error 0x1a (Unsupported Remote Feature)
Date: Fri,  5 Feb 2010 12:05:34 -0800
Message-ID: <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54198 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab0BEUGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:43 -0500
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Pelly <npelly@google.com>

General Motors carkits that use LGE BT chipsets return this error code
when an eSCO is attempted, despite advertising eSCO support.

2009-08-13 14:41:39.755518 < HCI Command: Setup Synchronous Connection (0x01|0x0028) plen 17
   handle 1 voice setting 0x0060
2009-08-13 14:41:39.757563 > HCI Event: Command Status (0x0f) plen 4
   Setup Synchronous Connection (0x01|0x0028) status 0x00 ncmd 1
2009-08-13 14:41:39.789484 > HCI Event: Synchronous Connect Complete (0x2c) plen 17
   status 0x1a handle 257 bdaddr 00:1E:B2:23:5E:B3 type eSCO
   Error: Unsupported Remote Feature / Unsupported LMP Feature

Signed-off-by: Jaikumar Ganesh <jaikumar@google.com>
Signed-off-by: Nick Pelly <npelly@google.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_event.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 28517ba..592da5c 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1699,6 +1699,7 @@ static inline void hci_sync_conn_complete_evt(struct hci_dev *hdev, struct sk_bu
 		break;
 
 	case 0x1c:	/* SCO interval rejected */
+	case 0x1a:	/* Unsupported Remote Feature */
 	case 0x1f:	/* Unspecified error */
 		if (conn->out && conn->attempt < 2) {
 			conn->pkt_type = (hdev->esco_type & SCO_ESCO_MASK) |
-- 
1.6.6

