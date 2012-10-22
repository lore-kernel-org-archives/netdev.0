From: Denis Kirjanov <kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RESEND net-next] bluetooth: hci_core: Replace list_for_each with list_for_each_entry() helper
Date: Mon, 22 Oct 2012 17:22:01 +0400
Message-ID: <1350912121-24171-1-git-send-email-kirjanov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Denis Kirjanov <kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace list_for_each with list_for_each_entry() helper

Signed-off-by: Denis Kirjanov <kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
