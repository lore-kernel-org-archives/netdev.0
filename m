From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH v2 net-next 1/2] mac802154: properly free incoming skbs on decryption failure
Date: Tue, 10 Jun 2014 18:11:10 +0200
Message-ID: <1402416671-30305-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:50760 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbaFJQLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 12:11:49 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5AGBSBx021114
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:11:30 +0200
In-Reply-To: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac802154 RX did not free skbs on decryption failure, assuming that the
caller would when the local rx handler returned _DROP. This was false.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/wpan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 23bc91c..c8cfd54 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -472,6 +472,7 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb,
 	rc = mac802154_llsec_decrypt(&sdata->sec, skb);
 	if (rc) {
 		pr_debug("decryption failed: %i\n", rc);
+		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
 
-- 
1.7.9.5
