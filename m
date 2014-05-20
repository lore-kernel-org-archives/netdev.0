From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 1/2] mac802154: llsec: fix incorrect lock pairing
Date: Tue, 20 May 2014 13:14:22 +0200
Message-ID: <1400584463-21692-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400584463-21692-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:51470 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbaETLOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 07:14:48 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4KBEj3Y013190
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 20 May 2014 13:14:46 +0200
In-Reply-To: <1400584463-21692-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In encrypt, sec->lock is taken with read_lock_bh, so in the error path,
we must read_unlock_bh.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/mac802154/llsec.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index a83674e..6edcb20 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -776,7 +776,7 @@ int mac802154_llsec_encrypt(struct mac802154_llsec *sec, struct sk_buff *skb)
 	return rc < 0 ? rc : 0;
 
 fail_read:
-	read_unlock(&sec->lock);
+	read_unlock_bh(&sec->lock);
 fail:
 	rcu_read_unlock();
 	return rc;
-- 
1.7.9.5
