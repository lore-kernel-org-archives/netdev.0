From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 8/9] Bluetooth: Add SCO fallback for unsupported feature error
Date: Sat, 27 Feb 2010 23:38:37 +0100
Message-ID: <705e5711b61e9622b2d88850f38c219014aa0780.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
 <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
 <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
 <b914a250e7b390c713b36a9405a39c4c11abad80.1267276098.git.marcel@holtmann.org>
 <943da25d95c7e8fd8c39dbf09e030f5da46f5d85.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54702 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936370Ab0B0WkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:25 -0500
In-Reply-To: <943da25d95c7e8fd8c39dbf09e030f5da46f5d85.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Coe <smcoe1@gmail.com>

The Bluetooth SIG PTS test case: TC_AG_ACS_BV_10_I, rejects eSCO with
"Unsupported Feature or Parameter Value" (0x11).  This patch adds case
for SCO fallback.

2007-09-20 12:20:37.787747 > HCI Event: Number of Completed Packets (0x13) plen 5
   handle 38 packets 1
2007-09-20 12:20:37.842154 < HCI Command: Setup Synchronous Connection (0x01|0x0028) plen 17
   handle 38 voice setting 0x0060
2007-09-20 12:20:37.847037 > HCI Event: Command Status (0x0f) plen 4
   Setup Synchronous Connection (0x01|0x0028) status 0x00 ncmd 1
2007-09-20 12:20:37.855233 > HCI Event: Max Slots Change (0x1b) plen 3
   handle 38 slots 1
2007-09-20 12:20:39.913354 > HCI Event: Synchronous Connect Complete (0x2c) plen 17
   status 0x11 handle 38 bdaddr 00:16:93:01:01:7A type eSCO
   Error: Unsupported Feature or Parameter Value
2007-09-20 12:20:39.922629 > HCI Event: Max Slots Change (0x1b) plen 3
   handle 38 slots 5
2007-09-20 12:20:58.126886 < ACL data: handle 38 flags 0x02 dlen 8
   L2CAP(d): cid 0x0041 len 4 [psm 0]
     0000: 0b 53 01 b8                                       .S..
2007-09-20 12:20:58.130138 > HCI Event: Number of Completed Packets (0x13) plen 5
   handle 38 packets 1

Signed-off-by: Stephen Coe <smcoe1@gmail.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_event.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 592da5c..6c57fc7 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1698,6 +1698,7 @@ static inline void hci_sync_conn_complete_evt(struct hci_dev *hdev, struct sk_bu
 		hci_conn_add_sysfs(conn);
 		break;
 
+	case 0x11:	/* Unsupported Feature or Parameter Value */
 	case 0x1c:	/* SCO interval rejected */
 	case 0x1a:	/* Unsupported Remote Feature */
 	case 0x1f:	/* Unspecified error */
-- 
1.6.6

