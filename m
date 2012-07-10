From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 06/11] qlcnic: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:30 -0700
Message-ID: <1341878975-10577-6-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab2GJAJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:29 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:29 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set before calling eth_type_trans.
eth_type_trans already sets skb->dev to the proper value, thus making this
unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: linux-driver@qlogic.com
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 8620b69..0bcda9c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1488,8 +1488,6 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 		skb_checksum_none_assert(skb);
 	}
 
-	skb->dev = adapter->netdev;
-
 	buffer->skb = NULL;
 
 	return skb;
-- 
1.7.9.5
