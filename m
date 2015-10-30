From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] xfrm: Increment statistic counter on inner mode error
Date: Fri, 30 Oct 2015 07:16:30 +0100
Message-ID: <1446185790-24214-6-git-send-email-steffen.klassert@secunet.com>
References: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39796 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758134AbbJ3GQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:43 -0400
In-Reply-To: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increment the LINUX_MIB_XFRMINSTATEMODEERROR statistic counter
to notify about dropped packets if we fail to fetch a inner mode.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 60ce701..ad7f5b3 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -330,8 +330,10 @@ resume:
 
 		if (x->sel.family == AF_UNSPEC) {
 			inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
-			if (inner_mode == NULL)
+			if (inner_mode == NULL) {
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMODEERROR);
 				goto drop;
+			}
 		}
 
 		if (inner_mode->input(x, skb)) {
-- 
1.9.1
