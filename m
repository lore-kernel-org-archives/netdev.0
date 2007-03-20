From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 22/31] [DCCP]: More debug information for dccp_wait_for_ccid
Date: Tue, 20 Mar 2007 20:16:51 -0300
Message-ID: <20070320231650.GK17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932764AbXCTXQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:16:55 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:16:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds more detail in the wait_for_ccid packet scheduling loop.
In particular, it informs about (i) when delay is used and (ii) why
a packet is discarded.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index aa21cc4..c8d843e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -194,6 +194,7 @@ static int dccp_wait_for_ccid(struct sock *sk, struct sk_buff *skb)
 		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 		if (rc <= 0)
 			break;
+		dccp_pr_debug("delayed send by %d msec\n", rc);
 		delay = msecs_to_jiffies(rc);
 		sk->sk_write_pending++;
 		release_sock(sk);
@@ -255,7 +256,7 @@ void dccp_write_xmit(struct sock *sk, int block)
 				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
 					 err);
 		} else {
-			dccp_pr_debug("packet discarded\n");
+			dccp_pr_debug("packet discarded due to err=%d\n", err);
 			kfree_skb(skb);
 		}
 	}
-- 
1.5.0.3

