From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 01/64] Bluetooth: Fix return value when bt_skb_alloc fails
Date: Mon, 10 May 2010 11:36:51 +0200
Message-ID: <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53426 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533Ab0EJJig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:36 -0400
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

Set the proper error(ENOMEM), instead of just return 0.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_h4.c |    2 +-
 drivers/bluetooth/hci_ll.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index c0ce813..3f038f5 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -246,7 +246,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 			BT_ERR("Can't allocate mem for new packet");
 			h4->rx_state = H4_W4_PACKET_TYPE;
 			h4->rx_count = 0;
-			return 0;
+			return -ENOMEM;
 		}
 
 		h4->rx_skb->dev = (void *) hu->hdev;
diff --git a/drivers/bluetooth/hci_ll.c b/drivers/bluetooth/hci_ll.c
index 5c65014..91e44df 100644
--- a/drivers/bluetooth/hci_ll.c
+++ b/drivers/bluetooth/hci_ll.c
@@ -491,7 +491,7 @@ static int ll_recv(struct hci_uart *hu, void *data, int count)
 			BT_ERR("Can't allocate mem for new packet");
 			ll->rx_state = HCILL_W4_PACKET_TYPE;
 			ll->rx_count = 0;
-			return 0;
+			return -ENOMEM;
 		}
 
 		ll->rx_skb->dev = (void *) hu->hdev;
-- 
1.6.6.1

