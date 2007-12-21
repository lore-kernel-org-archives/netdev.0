From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [XFRM]: Fix outbound statistics.
Date: Fri, 21 Dec 2007 23:17:58 +0900
Message-ID: <11982466781770-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:59333 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756783AbXLUOSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:18:17 -0500
In-Reply-To: 11982085193489-git-send-email-nakam@linux-ipv6.org
References: 11982085193489-git-send-email-nakam@linux-ipv6.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, I failed to include this statistics codes since I didn't notice
the conflict with the latest Herbert XFRM fix.

Please apply this, too.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/xfrm/xfrm_output.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 867484a..8dee031 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -43,17 +43,23 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 	do {
 		err = xfrm_state_check_space(x, skb);
-		if (err)
+		if (err) {
 			goto error_nolock;
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTERROR);
+		}
 
 		err = x->outer_mode->output(x, skb);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEMODEERROR);
 			goto error_nolock;
+		}
 
 		spin_lock_bh(&x->lock);
 		err = xfrm_state_check_expire(x);
-		if (err)
+		if (err) {
+			XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATEEXPIRED);
 			goto error;
+		}
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
-- 
1.4.4.2

