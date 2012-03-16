From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Fri, 16 Mar 2012 16:57:15 +0800
Message-ID: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: steffen.klassert@secunet.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41681 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab2CPI4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 04:56:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent

Call skb_pull reduce skb->len before next "while cycle"

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..f67f840 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1450,7 +1450,8 @@ alloc_new_skb:
 				kfree_skb(skb);
 				goto error;
 			}
-
+
+			skb_pull(skb, dst_exthdrlen);
 			offset += copy;
 			length -= datalen - fraggap;
 			transhdrlen = 0;
-- 
1.7.5.4
