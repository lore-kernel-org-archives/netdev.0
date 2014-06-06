From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next] mac802154: llsec: add forgotten list_del_rcu in key removal
Date: Fri,  6 Jun 2014 14:27:52 +0200
Message-ID: <1402057672-17657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:46323 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaFFM2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:28:19 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s56CSHNU006189
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 6 Jun 2014 14:28:18 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During key removal, the key object is freed, but not taken out of the
llsec key list properly. Fix that.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/llsec.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index e4a2558..1456f73 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -285,6 +285,7 @@ int mac802154_llsec_key_del(struct mac802154_llsec *sec,
 		mkey = container_of(pos->key, struct mac802154_llsec_key, key);
 
 		if (llsec_key_id_equal(&pos->id, key)) {
+			list_del_rcu(&pos->list);
 			llsec_key_put(mkey);
 			return 0;
 		}
-- 
1.7.9.5
