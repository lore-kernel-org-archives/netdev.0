From: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] bluetooth: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:29:52 +0800
Message-ID: <49A51DA0.8030003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/bluetooth/cmtp/core.c |    3 +--
 net/bluetooth/hci_core.c  |    3 +--
 net/bluetooth/l2cap.c     |    3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index c9cac77..0073ec8 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -126,8 +126,7 @@ static inline void cmtp_add_msgpart(struct cmtp_session *session, int id, const
 
 	session->reassembly[id] = nskb;
 
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 }
 
 static inline int cmtp_recv_frame(struct cmtp_session *session, struct sk_buff *skb)
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index ba78cc1..cd06151 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1565,8 +1565,7 @@ static void hci_cmd_task(unsigned long arg)
 
 	/* Send queued commands */
 	if (atomic_read(&hdev->cmd_cnt) && (skb = skb_dequeue(&hdev->cmd_q))) {
-		if (hdev->sent_cmd)
-			kfree_skb(hdev->sent_cmd);
+		kfree_skb(hdev->sent_cmd);
 
 		if ((hdev->sent_cmd = skb_clone(skb, GFP_ATOMIC))) {
 			atomic_dec(&hdev->cmd_cnt);
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index b93748e..04057db 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -483,8 +483,7 @@ static void l2cap_conn_del(struct hci_conn *hcon, int err)
 
 	BT_DBG("hcon %p conn %p, err %d", hcon, conn, err);
 
-	if (conn->rx_skb)
-		kfree_skb(conn->rx_skb);
+	kfree_skb(conn->rx_skb);
 
 	/* Kill channels */
 	while ((sk = conn->chan_list.head)) {
-- 
1.5.3.8
