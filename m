From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] bluetooth: Rename function bt_err to bt_to_errno
Date: Wed, 29 Jun 2011 18:18:29 -0700
Message-ID: <895bc01e49b93b9498ca05cfa1bd9cf58cf30df8.1309396408.git.joe@perches.com>
References: <1309370457.2208.48.camel@aeonflux> <cover.1309396408.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309396408.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make it easier to use more normal logging styles later.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/bluetooth/bluetooth.h |    2 +-
 net/bluetooth/hci_core.c          |    2 +-
 net/bluetooth/l2cap_core.c        |    4 ++--
 net/bluetooth/lib.c               |    4 ++--
 net/bluetooth/sco.c               |    4 ++--
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 7bccaf9..7d77545f 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -204,7 +204,7 @@ out:
 	return NULL;
 }
 
-int bt_err(__u16 code);
+int bt_to_errno(__u16 code);
 
 extern int hci_sock_init(void);
 extern void hci_sock_cleanup(void);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index b18db56..ec34c5a 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -148,7 +148,7 @@ static int __hci_request(struct hci_dev *hdev, void (*req)(struct hci_dev *hdev,
 
 	switch (hdev->req_status) {
 	case HCI_REQ_DONE:
-		err = -bt_err(hdev->req_result);
+		err = -bt_to_errno(hdev->req_result);
 		break;
 
 	case HCI_REQ_CANCELED:
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 9ec9c8c..2a27428 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -4107,7 +4107,7 @@ static int l2cap_connect_cfm(struct hci_conn *hcon, u8 status)
 		if (conn)
 			l2cap_conn_ready(conn);
 	} else
-		l2cap_conn_del(hcon, bt_err(status));
+		l2cap_conn_del(hcon, bt_to_errno(status));
 
 	return 0;
 }
@@ -4131,7 +4131,7 @@ static int l2cap_disconn_cfm(struct hci_conn *hcon, u8 reason)
 	if (!(hcon->type == ACL_LINK || hcon->type == LE_LINK))
 		return -EINVAL;
 
-	l2cap_conn_del(hcon, bt_err(reason));
+	l2cap_conn_del(hcon, bt_to_errno(reason));
 
 	return 0;
 }
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index b826d1b..4e7cf8b 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -59,7 +59,7 @@ char *batostr(bdaddr_t *ba)
 EXPORT_SYMBOL(batostr);
 
 /* Bluetooth error codes to Unix errno mapping */
-int bt_err(__u16 code)
+int bt_to_errno(__u16 code)
 {
 	switch (code) {
 	case 0:
@@ -149,4 +149,4 @@ int bt_err(__u16 code)
 		return ENOSYS;
 	}
 }
-EXPORT_SYMBOL(bt_err);
+EXPORT_SYMBOL(bt_to_errno);
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index cb4fb78..4c3621b 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -932,7 +932,7 @@ static int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 		if (conn)
 			sco_conn_ready(conn);
 	} else
-		sco_conn_del(hcon, bt_err(status));
+		sco_conn_del(hcon, bt_to_errno(status));
 
 	return 0;
 }
@@ -944,7 +944,7 @@ static int sco_disconn_cfm(struct hci_conn *hcon, __u8 reason)
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
 		return -EINVAL;
 
-	sco_conn_del(hcon, bt_err(reason));
+	sco_conn_del(hcon, bt_to_errno(reason));
 
 	return 0;
 }
-- 
1.7.6.rc1
