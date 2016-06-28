From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 6/6] r8152: add byte_enable for ocp_read_word function
Date: Tue, 28 Jun 2016 10:45:53 +0800
Message-ID: <1394712342-15778-197-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
 <1394712342-15778-191-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-191-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add byte_enable for ocp_read_word() to replace reading 4
bytes data with reading the desired 2 bytes data.

This is used to avoid the issue which is described in
commit b4d99def0938 ("r8152: remove sram_read"). The
origin method always reads 4 bytes data, and it may
have problem when reading the PHY registers.

The new method is supported since RTL8152B, but it
doesn't influence the previous chips. The bits of the
byte_enable for the previous chips are the reserved
bits, and the hw would ignore them.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2fd4944..0bb7c1b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -945,11 +945,13 @@ static u16 ocp_read_word(struct r8152 *tp, u16 type, u16 index)
 {
 	u32 data;
 	__le32 tmp;
+	u16 byen = BYTE_EN_WORD;
 	u8 shift = index & 2;
 
 	index &= ~3;
+	byen <<= shift;
 
-	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
+	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type | byen);
 
 	data = __le32_to_cpu(tmp);
 	data >>= (shift * 8);
-- 
2.4.11
