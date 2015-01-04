From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] bluetooth: Remove unused function
Date: Sun,  4 Jan 2015 16:55:14 +0100
Message-ID: <1420386914-12885-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function hci_conn_change_link_key() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 include/net/bluetooth/hci_core.h |    1 -
 net/bluetooth/hci_conn.c         |   15 ---------------
 2 files changed, 16 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 37ff1ae..a922163 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -728,7 +728,6 @@ int hci_conn_check_link_mode(struct hci_conn *conn);
 int hci_conn_check_secure(struct hci_conn *conn, __u8 sec_level);
 int hci_conn_security(struct hci_conn *conn, __u8 sec_level, __u8 auth_type,
 		      bool initiator);
-int hci_conn_change_link_key(struct hci_conn *conn);
 int hci_conn_switch_role(struct hci_conn *conn, __u8 role);
 
 void hci_conn_enter_active_mode(struct hci_conn *conn, __u8 force_active);
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index b9517bd..1fc18b6 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -1075,21 +1075,6 @@ int hci_conn_check_secure(struct hci_conn *conn, __u8 sec_level)
 }
 EXPORT_SYMBOL(hci_conn_check_secure);
 
-/* Change link key */
-int hci_conn_change_link_key(struct hci_conn *conn)
-{
-	BT_DBG("hcon %p", conn);
-
-	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->flags)) {
-		struct hci_cp_change_conn_link_key cp;
-		cp.handle = cpu_to_le16(conn->handle);
-		hci_send_cmd(conn->hdev, HCI_OP_CHANGE_CONN_LINK_KEY,
-			     sizeof(cp), &cp);
-	}
-
-	return 0;
-}
-
 /* Switch role */
 int hci_conn_switch_role(struct hci_conn *conn, __u8 role)
 {
-- 
1.7.10.4
