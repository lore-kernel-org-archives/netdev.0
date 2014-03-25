From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 29/54] jme: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:15 -0700
Message-ID: <1395727540-12148-29-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58467 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbaCYGLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:31 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in jme_expand_header that
can be called in hard irq and other contexts, on the failure
path where the skb is dropped.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/jme.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index f5685c0d0579..14ff8d64257d 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2059,7 +2059,7 @@ jme_expand_header(struct jme_adapter *jme, struct sk_buff *skb)
 	if (unlikely(skb_shinfo(skb)->gso_size &&
 			skb_header_cloned(skb) &&
 			pskb_expand_head(skb, 0, 0, GFP_ATOMIC))) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return -1;
 	}
 
-- 
1.7.10.4
