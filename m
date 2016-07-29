From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: [PATCH 1/1] Bluetooth: add printf format attribute to hci_set_[fh]w_info()
Date: Fri, 29 Jul 2016 13:28:25 +0200
Message-ID: <20160729112825.22091-1-nicolas.iooss_linux@m4x.org>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Iooss <nicolas.iooss_linux@m4x.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5177a83827cd ("Bluetooth: Add debugfs fields for hardware and
firmware info") introduced hci_set_hw_info() and hci_set_fw_info().
These functions use kvasprintf_const() but are not marked with a
__printf attribute.  Adding such an attribute helps detecting issues
related to printf-formatting at build time.

Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
---
 include/net/bluetooth/hci_core.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index ee7fc47680a1..012e5031fe47 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -1026,8 +1026,8 @@ int hci_resume_dev(struct hci_dev *hdev);
 int hci_reset_dev(struct hci_dev *hdev);
 int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb);
 int hci_recv_diag(struct hci_dev *hdev, struct sk_buff *skb);
-void hci_set_hw_info(struct hci_dev *hdev, const char *fmt, ...);
-void hci_set_fw_info(struct hci_dev *hdev, const char *fmt, ...);
+__printf(2, 3) void hci_set_hw_info(struct hci_dev *hdev, const char *fmt, ...);
+__printf(2, 3) void hci_set_fw_info(struct hci_dev *hdev, const char *fmt, ...);
 int hci_dev_open(__u16 dev);
 int hci_dev_close(__u16 dev);
 int hci_dev_do_close(struct hci_dev *hdev);
-- 
2.9.0
