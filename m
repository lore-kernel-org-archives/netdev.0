From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 02/11] enic: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:26 -0700
Message-ID: <1341878975-10577-2-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052Ab2GJAJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:08 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:08 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set after calling eth_type_trans.
eth_type_trans already sets skb->dev to the proper value, thus making this
unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Roopa Prabhu <roprabhu@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
Cc: Nishank Trivedi <nistrive@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 8132c78..ad1468b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1300,8 +1300,6 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 			skb->ip_summed = CHECKSUM_COMPLETE;
 		}
 
-		skb->dev = netdev;
-
 		if (vlan_stripped)
 			__vlan_hwaccel_put_tag(skb, vlan_tci);
 
-- 
1.7.9.5
