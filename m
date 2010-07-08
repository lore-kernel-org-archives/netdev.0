From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 13/13] Bluetooth: Update sec_level/auth_type for already existing connections
Date: Thu,  8 Jul 2010 17:00:02 -0300
Message-ID: <8c6147deb8b480598cb23cb02f992db03e5fccf8.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36244 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758610Ab0GHUAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:55 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ville Tervo <ville.tervo@nokia.com>

Update auth level for already existing connections if it is lower
than required by new connection.

Signed-off-by: Ville Tervo <ville.tervo@nokia.com>
Reviewed-by: Emeltchenko Andrei <andrei.emeltchenko@nokia.com>
Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_conn.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index b10e3cd..800b6b9 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -358,6 +358,11 @@ struct hci_conn *hci_connect(struct hci_dev *hdev, int type, bdaddr_t *dst, __u8
 		acl->sec_level = sec_level;
 		acl->auth_type = auth_type;
 		hci_acl_connect(acl);
+	} else {
+		if (acl->sec_level < sec_level)
+			acl->sec_level = sec_level;
+		if (acl->auth_type < auth_type)
+			acl->auth_type = auth_type;
 	}
 
 	if (type == ACL_LINK)
-- 
1.7.1.1

