From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 12/13] Bluetooth: Reset the security level after an authentication failure
Date: Thu,  8 Jul 2010 17:00:01 -0300
Message-ID: <818eba8ae369ad578548922d68c068bc372c3ab8.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36242 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758609Ab0GHUAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:54 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@nokia.com>

When authentication fails for a connection the assumed security level
should be set back to BT_SECURITY_LOW so that subsequent connect
attempts over the same link don't falsely assume that security is
adequate enough.

Signed-off-by: Johan Hedberg <johan.hedberg@nokia.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_event.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 6c57fc7..786b5de 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1049,6 +1049,8 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 	if (conn) {
 		if (!ev->status)
 			conn->link_mode |= HCI_LM_AUTH;
+		else
+			conn->sec_level = BT_SECURITY_LOW;
 
 		clear_bit(HCI_CONN_AUTH_PEND, &conn->pend);
 
-- 
1.7.1.1

