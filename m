From: Wei-Ning Huang <wnhuang@chromium.org>
Subject: [PATCH] Bluetooth: hci_core: cancel power off delayed work properly
Date: Mon, 15 Feb 2016 17:09:51 +0800
Message-ID: <1455527391-13622-1-git-send-email-wnhuang@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, johan.hedberg@intel.com,
	snanda@chromium.org, djkurtz@chromium.org,
	Wei-Ning Huang <wnhuang@chromium.org>, marcel@holtmann.org,
	gustavo@padovan.org, johan.hedberg@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Linux Bluetooth <linux-bluetooth@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei-Ning Huang <wnhuang@chromium.org>

When the HCI_AUTO_OFF flag is cleared, the power_off delayed work need
to be cancel or HCI will be powered off even if it's managed.

Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
---
 net/bluetooth/hci_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 47bcef7..f42305a 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2017,6 +2017,7 @@ static void hci_power_on(struct work_struct *work)
 	if (test_bit(HCI_UP, &hdev->flags) &&
 	    hci_dev_test_flag(hdev, HCI_MGMT) &&
 	    hci_dev_test_and_clear_flag(hdev, HCI_AUTO_OFF)) {
+		cancel_delayed_work(&hdev->power_off);
 		hci_req_sync_lock(hdev);
 		err = __hci_req_hci_power_on(hdev);
 		hci_req_sync_unlock(hdev);
-- 
2.7.0.rc3.207.g0ac5344
