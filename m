From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 44/54] tilepro: Call dev_consume_skb_any instead of kfree_skb.
Date: Mon, 24 Mar 2014 23:05:30 -0700
Message-ID: <1395727540-12148-44-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58481 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaCYGLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:34 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace kfree_skb with dev_consume_skb_any in tile_net_tx and
tile_net_tx_tso which can be called in hard irq and other contexts.

At the point where the skbs are freed a packet has been successfully
transmitted so dev_consume_skb_any is the appropriate variant to use.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/tile/tilepro.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index b94449b4bd34..e5a5c5d4ce0c 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -1824,7 +1824,7 @@ busy:
 
 	/* Handle completions. */
 	for (i = 0; i < nolds; i++)
-		kfree_skb(olds[i]);
+		dev_consume_skb_any(olds[i]);
 
 	/* Update stats. */
 	u64_stats_update_begin(&stats->syncp);
@@ -2008,7 +2008,7 @@ busy:
 
 	/* Handle completions. */
 	for (i = 0; i < nolds; i++)
-		kfree_skb(olds[i]);
+		dev_consume_skb_any(olds[i]);
 
 	/* HACK: Track "expanded" size for short packets (e.g. 42 < 60). */
 	u64_stats_update_begin(&stats->syncp);
-- 
1.7.10.4
