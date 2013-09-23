From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/12] bluetooth: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:37:36 -0700
Message-ID: <e9994a2b839277a9237364b59e655060f1fcb957.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	linux-bluetooth@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/bluetooth/bluetooth.h | 16 ++++++++--------
 include/net/bluetooth/hci_core.h  | 23 +++++++++++------------
 include/net/bluetooth/rfcomm.h    |  4 ++--
 3 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 10d43d8..13d6c39 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -331,16 +331,16 @@ out:
 
 int bt_to_errno(__u16 code);
 
-extern int hci_sock_init(void);
-extern void hci_sock_cleanup(void);
+int hci_sock_init(void);
+void hci_sock_cleanup(void);
 
-extern int bt_sysfs_init(void);
-extern void bt_sysfs_cleanup(void);
+int bt_sysfs_init(void);
+void bt_sysfs_cleanup(void);
 
-extern int  bt_procfs_init(struct net *net, const char *name,
-			   struct bt_sock_list* sk_list,
-			   int (* seq_show)(struct seq_file *, void *));
-extern void bt_procfs_cleanup(struct net *net, const char *name);
+int bt_procfs_init(struct net *net, const char *name,
+		   struct bt_sock_list *sk_list,
+		   int (*seq_show)(struct seq_file *, void *));
+void bt_procfs_cleanup(struct net *net, const char *name);
 
 extern struct dentry *bt_debugfs;
 
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 3ede820..5769061 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -367,18 +367,17 @@ extern rwlock_t hci_dev_list_lock;
 extern rwlock_t hci_cb_list_lock;
 
 /* ----- HCI interface to upper protocols ----- */
-extern int l2cap_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr);
-extern void l2cap_connect_cfm(struct hci_conn *hcon, u8 status);
-extern int l2cap_disconn_ind(struct hci_conn *hcon);
-extern void l2cap_disconn_cfm(struct hci_conn *hcon, u8 reason);
-extern int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt);
-extern int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb,
-			      u16 flags);
-
-extern int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 *flags);
-extern void sco_connect_cfm(struct hci_conn *hcon, __u8 status);
-extern void sco_disconn_cfm(struct hci_conn *hcon, __u8 reason);
-extern int sco_recv_scodata(struct hci_conn *hcon, struct sk_buff *skb);
+int l2cap_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr);
+void l2cap_connect_cfm(struct hci_conn *hcon, u8 status);
+int l2cap_disconn_ind(struct hci_conn *hcon);
+void l2cap_disconn_cfm(struct hci_conn *hcon, u8 reason);
+int l2cap_security_cfm(struct hci_conn *hcon, u8 status, u8 encrypt);
+int l2cap_recv_acldata(struct hci_conn *hcon, struct sk_buff *skb, u16 flags);
+
+int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 *flags);
+void sco_connect_cfm(struct hci_conn *hcon, __u8 status);
+void sco_disconn_cfm(struct hci_conn *hcon, __u8 reason);
+int sco_recv_scodata(struct hci_conn *hcon, struct sk_buff *skb);
 
 /* ----- Inquiry cache ----- */
 #define INQUIRY_CACHE_AGE_MAX   (HZ*30)   /* 30 seconds */
diff --git a/include/net/bluetooth/rfcomm.h b/include/net/bluetooth/rfcomm.h
index 7afd419..b7f43e7 100644
--- a/include/net/bluetooth/rfcomm.h
+++ b/include/net/bluetooth/rfcomm.h
@@ -256,8 +256,8 @@ static inline void rfcomm_dlc_put(struct rfcomm_dlc *d)
 		rfcomm_dlc_free(d);
 }
 
-extern void __rfcomm_dlc_throttle(struct rfcomm_dlc *d);
-extern void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d);
+void __rfcomm_dlc_throttle(struct rfcomm_dlc *d);
+void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d);
 
 static inline void rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
