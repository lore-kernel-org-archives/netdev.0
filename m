From: zengzhaoxiu@163.com
Subject: [patch V4 23/31] ethernet: use parity8 in sun/niu.c
Date: Wed, 11 May 2016 17:22:17 +0800
Message-ID: <1462958539-25752-1-git-send-email-zengzhaoxiu@163.com>
References: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Cc: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462955158-28394-1-git-send-email-zengzhaoxiu@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
 drivers/net/ethernet/sun/niu.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 9cc4564..8c344ef 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -2742,18 +2742,12 @@ static int niu_set_alt_mac_rdc_table(struct niu *np, int idx,
 
 static u64 vlan_entry_set_parity(u64 reg_val)
 {
-	u64 port01_mask;
-	u64 port23_mask;
-
-	port01_mask = 0x00ff;
-	port23_mask = 0xff00;
-
-	if (hweight64(reg_val & port01_mask) & 1)
+	if (parity8(reg_val))
 		reg_val |= ENET_VLAN_TBL_PARITY0;
 	else
 		reg_val &= ~ENET_VLAN_TBL_PARITY0;
 
-	if (hweight64(reg_val & port23_mask) & 1)
+	if (parity8((unsigned int)reg_val >> 8))
 		reg_val |= ENET_VLAN_TBL_PARITY1;
 	else
 		reg_val &= ~ENET_VLAN_TBL_PARITY1;
-- 
2.7.4
