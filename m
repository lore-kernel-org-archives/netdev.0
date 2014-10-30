From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 1/2] mpls: Fix mpls_gso handler.
Date: Thu, 30 Oct 2014 00:49:57 -0700
Message-ID: <1414655397-1541-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Simon Horman <simon.horman@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:59817 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161430AbaJaBuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 21:50:23 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so6687200pad.1
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 18:50:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mpls gso handler needs to pull skb after segmenting skb.

CC: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/mpls/mpls_gso.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index f0f5309..e3545f2 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -59,8 +59,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 	 * above pulled.  It will be re-pushed after returning
 	 * skb_mac_gso_segment(), an indirect caller of this function.
 	 */
-	__skb_push(skb, skb->data - skb_mac_header(skb));
-
+	__skb_pull(skb, skb->data - skb_mac_header(skb));
 out:
 	return segs;
 }
-- 
1.7.1
