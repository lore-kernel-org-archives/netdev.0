From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] qlge: Fix sparse endian warning in ql_hw_csum_setup().
Date: Mon,  5 Jan 2009 14:27:30 -0800
Message-ID: <1231194452-10671-3-git-send-email-ron.mercer@qlogic.com>
References: <20090105222600.GA4232@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbZAEW1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:27:36 -0500
In-Reply-To: <20090105222600.GA4232@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed u16 to __sum16 usage.

Warnings:
drivers/net/qlge/qlge_main.c:1897:9: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:1897:9:    expected unsigned short [usertype] *check
drivers/net/qlge/qlge_main.c:1897:9:    got restricted unsigned short *<noident>
drivers/net/qlge/qlge_main.c:1903:9: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:1903:9:    expected unsigned short [usertype] *check
drivers/net/qlge/qlge_main.c:1903:9:    got restricted unsigned short *<noident>
drivers/net/qlge/qlge_main.c:1909:9: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:1909:9:    expected unsigned short [unsigned] [short] [usertype] <noident>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 837be72..d7894aa 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1884,7 +1884,7 @@ static void ql_hw_csum_setup(struct sk_buff *skb,
 {
 	int len;
 	struct iphdr *iph = ip_hdr(skb);
-	u16 *check;
+	__sum16 *check;
 	mac_iocb_ptr->opcode = OPCODE_OB_MAC_TSO_IOCB;
 	mac_iocb_ptr->frame_len = cpu_to_le32((u32) skb->len);
 	mac_iocb_ptr->net_trans_offset =
-- 
1.6.0

