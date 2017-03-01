From: Colin King <colin.king@canonical.com>
Subject: [PATCH] Bluetooth: fix assignments on error variable err
Date: Wed,  1 Mar 2017 15:10:53 +0000
Message-ID: <20170301151053.25779-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable err is being initialized to zero and then later being
set to the error return from the call to hci_req_run_skb; hence
we can remove the redundant initialization to zero.

Also on two occassions err is not being set from the error return
from the call to hci_req_run_skb, so add these missing assignments.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/bluetooth/amp.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/bluetooth/amp.c b/net/bluetooth/amp.c
index 02a4ccc..ebcab5b 100644
--- a/net/bluetooth/amp.c
+++ b/net/bluetooth/amp.c
@@ -263,7 +263,7 @@ void amp_read_loc_assoc_frag(struct hci_dev *hdev, u8 phy_handle)
 	struct hci_cp_read_local_amp_assoc cp;
 	struct amp_assoc *loc_assoc = &hdev->loc_assoc;
 	struct hci_request req;
-	int err = 0;
+	int err;
 
 	BT_DBG("%s handle %d", hdev->name, phy_handle);
 
@@ -282,7 +282,7 @@ void amp_read_loc_assoc(struct hci_dev *hdev, struct amp_mgr *mgr)
 {
 	struct hci_cp_read_local_amp_assoc cp;
 	struct hci_request req;
-	int err = 0;
+	int err;
 
 	memset(&hdev->loc_assoc, 0, sizeof(struct amp_assoc));
 	memset(&cp, 0, sizeof(cp));
@@ -292,7 +292,7 @@ void amp_read_loc_assoc(struct hci_dev *hdev, struct amp_mgr *mgr)
 	set_bit(READ_LOC_AMP_ASSOC, &mgr->state);
 	hci_req_init(&req, hdev);
 	hci_req_add(&req, HCI_OP_READ_LOCAL_AMP_ASSOC, sizeof(cp), &cp);
-	hci_req_run_skb(&req, read_local_amp_assoc_complete);
+	err = hci_req_run_skb(&req, read_local_amp_assoc_complete);
 	if (err < 0)
 		a2mp_send_getampassoc_rsp(hdev, A2MP_STATUS_INVALID_CTRL_ID);
 }
@@ -303,7 +303,7 @@ void amp_read_loc_assoc_final_data(struct hci_dev *hdev,
 	struct hci_cp_read_local_amp_assoc cp;
 	struct amp_mgr *mgr = hcon->amp_mgr;
 	struct hci_request req;
-	int err = 0;
+	int err;
 
 	cp.phy_handle = hcon->handle;
 	cp.len_so_far = cpu_to_le16(0);
@@ -314,7 +314,7 @@ void amp_read_loc_assoc_final_data(struct hci_dev *hdev,
 	/* Read Local AMP Assoc final link information data */
 	hci_req_init(&req, hdev);
 	hci_req_add(&req, HCI_OP_READ_LOCAL_AMP_ASSOC, sizeof(cp), &cp);
-	hci_req_run_skb(&req, read_local_amp_assoc_complete);
+	err = hci_req_run_skb(&req, read_local_amp_assoc_complete);
 	if (err < 0)
 		a2mp_send_getampassoc_rsp(hdev, A2MP_STATUS_INVALID_CTRL_ID);
 }
-- 
2.10.2
