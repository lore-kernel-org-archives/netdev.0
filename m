From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 02/64] Bluetooth: Use the proper function cast to get hdr data
Date: Mon, 10 May 2010 11:36:52 +0200
Message-ID: <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53429 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab0EJJih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:37 -0400
In-Reply-To: <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_ll.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 91e44df..fb8445c 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -402,7 +402,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case HCILL_W4_EVENT_HDR:
-				eh = (struct hci_event_hdr *) ll->rx_skb->data;
+				eh = hci_event_hdr(ll->rx_skb);
 
 				BT_DBG("Event header: evt 0x%2.2x plen %d", eh->evt, eh->plen);
 
@@ -410,7 +410,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case HCILL_W4_ACL_HDR:
-				ah = (struct hci_acl_hdr *) ll->rx_skb->data;
+				ah = hci_acl_hdr(ll->rx_skb);
 				dlen = __le16_to_cpu(ah->dlen);
 
 				BT_DBG("ACL header: dlen %d", dlen);
@@ -419,7 +419,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case HCILL_W4_SCO_HDR:
-				sh = (struct hci_sco_hdr *) ll->rx_skb->data;
+				sh = hci_sco_hdr(ll->rx_skb);
 
 				BT_DBG("SCO header: dlen %d", sh->dlen);
 
-- 
1.6.6.1

