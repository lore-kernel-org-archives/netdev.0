From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix overlap check for fragments
Date: Fri, 05 Nov 2010 19:56:34 +0800
Message-ID: <4CD3F0F2.2080804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54586 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab0KEL4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 07:56:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The type of FRAG6_CB(prev)->offset is int, skb->len is *unsigned* int,
and offset is int.

Without this patch, type conversion occurred to this expression, when
(FRAG6_CB(prev)->offset + prev->len) is less than offset.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/reassembly.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index c7ba314..0f27664 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -349,7 +349,7 @@ found:
 
 	/* Check for overlap with preceding fragment. */
 	if (prev &&
-	    (FRAG6_CB(prev)->offset + prev->len) - offset > 0)
+	    (FRAG6_CB(prev)->offset + prev->len) > offset)
 		goto discard_fq;
 
 	/* Look for overlap with succeeding segment. */
-- 
1.6.3.3
