From: "zhaoxiu.zeng" <zhaoxiu.zeng@gmail.com>
Subject: [PATCH 25/31] ethernet: use parity8 in sun/niu.c
Date: Sun, 27 Mar 2016 15:36:22 +0800
Message-ID: <56F78D76.1060305@gmail.com>
References: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36474 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbcC0Hg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 03:36:56 -0400
In-Reply-To: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>
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
2.5.5
