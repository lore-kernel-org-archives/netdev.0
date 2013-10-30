From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 3/3] r8152: fix incorrect type in assignment
Date: Wed, 30 Oct 2013 15:13:40 +0800
Message-ID: <1383117220-893-4-git-send-email-hayeswang@realtek.com>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
 <1383117220-893-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383117220-893-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The data from the hardware should be little endian. Correct the
declaration.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 763234d..a77bdb8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -307,22 +307,22 @@ enum rtl8152_flags {
 #define MCU_TYPE_USB			0x0000
 
 struct rx_desc {
-	u32 opts1;
+	__le32 opts1;
 #define RX_LEN_MASK			0x7fff
-	u32 opts2;
-	u32 opts3;
-	u32 opts4;
-	u32 opts5;
-	u32 opts6;
+	__le32 opts2;
+	__le32 opts3;
+	__le32 opts4;
+	__le32 opts5;
+	__le32 opts6;
 };
 
 struct tx_desc {
-	u32 opts1;
+	__le32 opts1;
 #define TX_FS			(1 << 31) /* First segment of a packet */
 #define TX_LS			(1 << 30) /* Final segment of a packet */
 #define TX_LEN_MASK		0x3ffff
 
-	u32 opts2;
+	__le32 opts2;
 #define UDP_CS			(1 << 31) /* Calculate UDP/IP checksum */
 #define TCP_CS			(1 << 30) /* Calculate TCP/IP checksum */
 #define IPV4_CS			(1 << 29) /* Calculate IPv4 checksum */
@@ -876,7 +876,7 @@ static void write_bulk_callback(struct urb *urb)
 static void intr_callback(struct urb *urb)
 {
 	struct r8152 *tp;
-	__u16 *d;
+	__le16 *d;
 	int status = urb->status;
 	int res;
 
-- 
1.8.3.1
