From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] xfrm: fix error checking in xfrm_output_gso
Date: Thu, 27 Oct 2011 13:33:18 +0800
Message-ID: <4EA8ED1E.6080808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42629 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557Ab1J0Fda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 01:33:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_output2() returns 1 on success. This bug makes xfrm_output_gso()
drop all segments except the first one.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 47bacd8..04e963a 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -159,7 +159,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 		segs->next = NULL;
 		err = xfrm_output2(segs);
 
-		if (unlikely(err)) {
+		if (unlikely(err < 0)) {
 			while ((segs = nskb)) {
 				nskb = segs->next;
 				segs->next = NULL;
