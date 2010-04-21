From: Roland Dreier <rdreier@cisco.com>
Subject: cxgb4: Use ntohs() on __be16 value instead of htons()
Date: Wed, 21 Apr 2010 11:09:21 -0700
Message-ID: <ada1ve8r832.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:48417 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab0DUSKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 14:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the correct direction of byte-swapping function to fix a mistake
shown by sparse endianness checking -- c.fl0id is __be16.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/cxgb4/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 14adc58..70bf2b2 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -2047,7 +2047,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	adap->sge.ingr_map[iq->cntxt_id] = iq;
 
 	if (fl) {
-		fl->cntxt_id = htons(c.fl0id);
+		fl->cntxt_id = ntohs(c.fl0id);
 		fl->avail = fl->pend_cred = 0;
 		fl->pidx = fl->cidx = 0;
 		fl->alloc_failed = fl->large_alloc_failed = fl->starving = 0;

-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
