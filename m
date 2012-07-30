From: Denis@vger.kernel.org, Kirjanov@vger.kernel.org
Subject: [PATCH net-next] bluetooth: Replace list_for_each with list_for_each_entry() helper
Date: Mon, 30 Jul 2012 13:47:12 +0400
Message-ID: <1343641632-8670-1-git-send-email-kirjanov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Denis Kirjanov <kirjanov@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.121.140]:10547 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab2G3Jrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 05:47:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---
 include/net/bluetooth/hci_core.h |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 475b8c0..fcf839f 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -852,7 +852,7 @@ struct hci_cb {
 
 static inline void hci_auth_cfm(struct hci_conn *conn, __u8 status)
 {
-	struct list_head *p;
+	struct hci_cb *cb;
 	__u8 encrypt;
 
 	hci_proto_auth_cfm(conn, status);
@@ -863,8 +863,7 @@ static inline void hci_auth_cfm(struct hci_conn *conn, __u8 status)
 	encrypt = (conn->link_mode & HCI_LM_ENCRYPT) ? 0x01 : 0x00;
 
 	read_lock(&hci_cb_list_lock);
-	list_for_each(p, &hci_cb_list) {
-		struct hci_cb *cb = list_entry(p, struct hci_cb, list);
+	list_for_each_entry(cb, &hci_cb_list, list) {
 		if (cb->security_cfm)
 			cb->security_cfm(conn, status, encrypt);
 	}
@@ -874,7 +873,7 @@ static inline void hci_auth_cfm(struct hci_conn *conn, __u8 status)
 static inline void hci_encrypt_cfm(struct hci_conn *conn, __u8 status,
 								__u8 encrypt)
 {
-	struct list_head *p;
+	struct hci_cb *cb;
 
 	if (conn->sec_level == BT_SECURITY_SDP)
 		conn->sec_level = BT_SECURITY_LOW;
@@ -885,8 +884,7 @@ static inline void hci_encrypt_cfm(struct hci_conn *conn, __u8 status,
 	hci_proto_encrypt_cfm(conn, status, encrypt);
 
 	read_lock(&hci_cb_list_lock);
-	list_for_each(p, &hci_cb_list) {
-		struct hci_cb *cb = list_entry(p, struct hci_cb, list);
+	list_for_each_entry(cb, &hci_cb_list, list) {
 		if (cb->security_cfm)
 			cb->security_cfm(conn, status, encrypt);
 	}
@@ -895,11 +893,10 @@ static inline void hci_encrypt_cfm(struct hci_conn *conn, __u8 status,
 
 static inline void hci_key_change_cfm(struct hci_conn *conn, __u8 status)
 {
-	struct list_head *p;
+	struct hci_cb *cb;
 
 	read_lock(&hci_cb_list_lock);
-	list_for_each(p, &hci_cb_list) {
-		struct hci_cb *cb = list_entry(p, struct hci_cb, list);
+	list_for_each_entry(cb, &hci_cb_list, list) {
 		if (cb->key_change_cfm)
 			cb->key_change_cfm(conn, status);
 	}
@@ -909,11 +906,10 @@ static inline void hci_key_change_cfm(struct hci_conn *conn, __u8 status)
 static inline void hci_role_switch_cfm(struct hci_conn *conn, __u8 status,
 								__u8 role)
 {
-	struct list_head *p;
+	struct hci_cb *cb;
 
 	read_lock(&hci_cb_list_lock);
-	list_for_each(p, &hci_cb_list) {
-		struct hci_cb *cb = list_entry(p, struct hci_cb, list);
+	list_for_each_entry(cb, &hci_cb_list, list) {
 		if (cb->role_switch_cfm)
 			cb->role_switch_cfm(conn, status, role);
 	}
-- 
1.7.1


-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
