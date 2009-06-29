From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: xmit sctp packet always return no route error
Date: Mon, 29 Jun 2009 16:49:37 +0800
Message-ID: <4A488021.50002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64391 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbZF2Iu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 04:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 'net: skb->dst accessors'(adf30907d63893e4208dfe3f5c88ae12bc2f25d5)
broken the sctp protocol stack, the sctp packet can never be sent out after
Eric Dumazet's patch, which have typo in the sctp code.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index b764114..b94c211 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -407,7 +407,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	}
 	dst = dst_clone(tp->dst);
 	skb_dst_set(nskb, dst);
-	if (dst)
+	if (!dst)
 		goto no_route;
 
 	/* Build the SCTP header.  */
-- 
1.6.2.2




