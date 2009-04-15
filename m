From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 10:09:37 +0200
Message-ID: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Gallatin <gallatin@myri.com>, Brice Goglin <brice@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35246 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbZDOIPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 04:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add LRO alignment initially committed in 621544eb8c3beaa859c75850f816dd9b056a00a3
and removed in 0dcffac1a329be69bab0ac604bf7283737108e68 during conversion to
multi-slice.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/myri10ge/myri10ge.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 9eed126..f2c4a66 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2447,6 +2447,7 @@ static int myri10ge_open(struct net_device *dev)
 		lro_mgr->lro_arr = ss->rx_done.lro_desc;
 		lro_mgr->get_frag_header = myri10ge_get_frag_header;
 		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
+		lro_mgr->frag_align_pad = 2;
 		if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
 			lro_mgr->max_aggr = MAX_SKB_FRAGS;
 
-- 
1.5.5.6

