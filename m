From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/2] r8152: remove generic_ocp_read before writing
Date: Mon, 19 Jan 2015 17:02:45 +0800
Message-ID: <1394712342-15778-127-Taiwan-albertk@realtek.com>
References: <1394712342-15778-126-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-126-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ocp_write_word() and ocp_write_byte(), there is a generic_ocp_read()
which is used to read the whole 4 byte data, keep the unchanged bytes,
and modify the expected bytes. However, the "byen" could be used to
determine which bytes of the 4 bytes to write, so the action could be
removed.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 57ec23e..0aa83fb 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -833,9 +833,6 @@ static void ocp_write_word(struct r8152 *tp, u16 type, u16 index, u32 data)
 		index &= ~3;
 	}
 
-	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
-
-	data |= __le32_to_cpu(tmp) & ~mask;
 	tmp = __cpu_to_le32(data);
 
 	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
@@ -874,9 +871,6 @@ static void ocp_write_byte(struct r8152 *tp, u16 type, u16 index, u32 data)
 		index &= ~3;
 	}
 
-	generic_ocp_read(tp, index, sizeof(tmp), &tmp, type);
-
-	data |= __le32_to_cpu(tmp) & ~mask;
 	tmp = __cpu_to_le32(data);
 
 	generic_ocp_write(tp, index, byen, sizeof(tmp), &tmp, type);
-- 
2.1.0
