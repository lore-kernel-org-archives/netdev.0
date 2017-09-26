From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] ieee802154: atusb: make two structures static, fixes warnings
Date: Tue, 26 Sep 2017 14:18:36 +0100
Message-ID: <20170926131836.15171-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Schmidt <stefan@osg.samsung.com>,
        Alexander Aring <alex.aring@gmail.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The arrays atusb_chip_data and hulusb_chip_data are local to the source
and do not need to be in global scope, so make them static. Also
remove unnecessary forward declaration of atusb_chip_data.

Cleans up sparse warnings:
symbol 'atusb_chip_data' was not declared. Should it be static?
symbol 'hulusb_chip_data' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ieee802154/atusb.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/atusb.c b/drivers/net/ieee802154/atusb.c
index 115fa3f37a86..8b0718de568f 100644
--- a/drivers/net/ieee802154/atusb.c
+++ b/drivers/net/ieee802154/atusb.c
@@ -45,8 +45,6 @@
 #define ATUSB_ALLOC_DELAY_MS	100	/* delay after failed allocation */
 #define ATUSB_TX_TIMEOUT_MS	200	/* on the air timeout */
 
-struct atusb_chip_data;
-
 struct atusb {
 	struct ieee802154_hw *hw;
 	struct usb_device *usb_dev;
@@ -767,14 +765,14 @@ atusb_set_promiscuous_mode(struct ieee802154_hw *hw, const bool on)
 	return 0;
 }
 
-struct atusb_chip_data atusb_chip_data = {
+static struct atusb_chip_data atusb_chip_data = {
 	.t_channel_switch = 1,
 	.rssi_base_val = -91,
 	.set_txpower = atusb_set_txpower,
 	.set_channel = atusb_set_channel,
 };
 
-struct atusb_chip_data hulusb_chip_data = {
+static struct atusb_chip_data hulusb_chip_data = {
 	.t_channel_switch = 11,
 	.rssi_base_val = -100,
 	.set_txpower = hulusb_set_txpower,
-- 
2.14.1

