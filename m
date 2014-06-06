From: Kiran Kumar Raparthy <kiran.kumar@linaro.org>
Subject: [RFC] Bluetooth: Do not attempt to send dlci disconnect when in BT_CONFIG.
Date: Fri,  6 Jun 2014 15:49:31 +0530
Message-ID: <1402049971-7762-1-git-send-email-kiran.kumar@linaro.org>
Cc: Nick Pelly <npelly@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	Seung-Woo Kim <sw0312.kim@samsung.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Android Kernel Team <kernel-team@android.com>,
	John Stultz <john.stultz@linaro.org>,
	Kiran Raparthy <kiran.kumar@linaro.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Pelly <npelly@google.com>

Do not attempt to send dlci disconnect when in BT_CONFIG.

This fixes a bug where shutdown() and close() on a rfcomm socket during ACL
connection would not cause HCI Create Connection Cancel.

This is one of the number of patches from the Android AOSP common.git tree,
which is used on almost all Android devices.  so I wanted to submit it for
review to see if it should go upstream.

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Hurley <peter@hurleysoftware.com>
Cc: Seung-Woo Kim <sw0312.kim@samsung.com>
Cc: Nick Pelly <npelly@google.com>
Cc: linux-bluetooth@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Android Kernel Team <kernel-team@android.com>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Nick Pelly <npelly@google.com>
[kiran: Added context to commit message]
Signed-off-by: Kiran Raparthy <kiran.kumar@linaro.org>
---
 net/bluetooth/rfcomm/core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index cf62026..6a531e7 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -456,7 +456,6 @@ static int __rfcomm_dlc_close(struct rfcomm_dlc *d, int err)
 
 	switch (d->state) {
 	case BT_CONNECT:
-	case BT_CONFIG:
 	case BT_OPEN:
 	case BT_CONNECT2:
 		if (test_and_clear_bit(RFCOMM_DEFER_SETUP, &d->flags)) {
-- 
1.8.2.1
