From: Kiran Kumar Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [RFC] Bluetooth: Add ACL MTU, available buffers and total buffers to hci_conn_info.
Date: Fri,  6 Jun 2014 15:48:00 +0530
Message-ID: <1402049880-7686-1-git-send-email-kiran.kumar@linaro.org>
Cc: Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Kiran Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Add ACL MTU, available buffers and total buffers to hci_conn_info.

This provides userspace debugging tools access to ACL flow control state.

This is one of the number of patches from the Android AOSP common.git tree,
which is used on almost all Android devices.  so I wanted to submit it for
review to see if it should go upstream.

Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Nick Pelly <npelly-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
[kiran: Added context to commit message]
Signed-off-by: Kiran Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/net/bluetooth/hci.h |  3 +++
 net/bluetooth/hci_conn.c    | 18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index be150cf..67dc0fb 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -1830,6 +1830,9 @@ struct hci_conn_info {
 	__u8     out;
 	__u16    state;
 	__u32    link_mode;
+	__u32    mtu;
+	__u32    cnt;
+	__u32    pkts;
 };
 
 struct hci_dev_req {
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 521fd4f..c2ba0fe 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -1064,6 +1064,15 @@ int hci_get_conn_list(void __user *arg)
 		(ci + n)->out   = c->out;
 		(ci + n)->state = c->state;
 		(ci + n)->link_mode = c->link_mode;
+		if (c->type == SCO_LINK) {
+			(ci + n)->mtu = hdev->sco_mtu;
+			(ci + n)->cnt = hdev->sco_cnt;
+			(ci + n)->pkts = hdev->sco_pkts;
+		} else {
+			(ci + n)->mtu = hdev->acl_mtu;
+			(ci + n)->cnt = hdev->acl_cnt;
+			(ci + n)->pkts = hdev->acl_pkts;
+		}
 		if (++n >= req.conn_num)
 			break;
 	}
@@ -1100,6 +1109,15 @@ int hci_get_conn_info(struct hci_dev *hdev, void __user *arg)
 		ci.out   = conn->out;
 		ci.state = conn->state;
 		ci.link_mode = conn->link_mode;
+		if (req.type == SCO_LINK) {
+			ci.mtu = hdev->sco_mtu;
+			ci.cnt = hdev->sco_cnt;
+			ci.pkts = hdev->sco_pkts;
+		} else {
+			ci.mtu = hdev->acl_mtu;
+			ci.cnt = hdev->acl_cnt;
+			ci.pkts = hdev->acl_pkts;
+		}
 	}
 	hci_dev_unlock(hdev);
 
-- 
1.8.2.1
