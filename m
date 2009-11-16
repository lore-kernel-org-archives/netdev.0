From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/3] Bluetooth: Set general bonding security for ACL by default
Date: Mon, 16 Nov 2009 01:48:21 +0100
Message-ID: <93f19c9fc8c98bb6d2e9825115989603ffd5cd1f.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46538 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbZKPAs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 19:48:26 -0500
In-Reply-To: <cover.1258331614.git.marcel@holtmann.org>
In-Reply-To: <cover.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>

This patch fixes double pairing issues with Secure Simple
Paring support. It was observed that when pairing with SSP
enabled, that the confirmation will be asked twice.

http://www.spinics.net/lists/linux-bluetooth/msg02473.html

This also causes bug when initiating SSP connection from
Windows Vista.

The reason is because bluetoothd does not store link keys
since HCIGETAUTHINFO returns 0. Setting default to general
bonding fixes these issues.

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_conn.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index a975098..b7c4224 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -211,6 +211,7 @@ struct hci_conn *hci_conn_add(struct hci_dev *hdev, int type, bdaddr_t *dst)
 	conn->type  = type;
 	conn->mode  = HCI_CM_ACTIVE;
 	conn->state = BT_OPEN;
+	conn->auth_type = HCI_AT_GENERAL_BONDING;
 
 	conn->power_save = 1;
 	conn->disc_timeout = HCI_DISCONN_TIMEOUT;
-- 
1.6.2.5

