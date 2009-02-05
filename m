From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.29] cxgb3 - Fix lro switch
Date: Wed, 04 Feb 2009 16:25:47 -0800
Message-ID: <20090205002547.26126.47373.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, kxie@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15872 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbZBEAZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:25:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The LRO switch is always set to 1 in the rx processing loop.
It breaks the accelerated iSCSI receive traffic.
Fix its computation.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 379a132..d31791f 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2276,8 +2276,7 @@ no_mem:
 		} else if ((len = ntohl(r->len_cq)) != 0) {
 			struct sge_fl *fl;
 
-			if (eth)
-				lro = qs->lro_enabled && is_eth_tcp(rss_hi);
+			lro &= eth && is_eth_tcp(rss_hi);
 
 			fl = (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
 			if (fl->use_pages) {

