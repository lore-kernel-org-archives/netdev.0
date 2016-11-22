From: Manjeet Pawar <manjeet.p@samsung.com>
Subject: [PATCH] ipv6:ipv6_pinfo dereferenced after NULL check
Date: Tue, 22 Nov 2016 11:57:04 +0530
Message-ID: <1479796024-39418-1-git-send-email-manjeet.p@samsung.com>
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com,
        Rohit Thapliyal <r.thapliyal@samsung.com>,
        Manjeet Pawar <manjeet.p@samsung.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rohit Thapliyal <r.thapliyal@samsung.com>

np checked for NULL and then dereferenced. It should be modified
for NULL case.

Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
---
 net/ipv6/ip6_output.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1dfc402..c2afa14 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -205,14 +205,15 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	/*
 	 *	Fill in the IPv6 header
 	 */
-	if (np)
+	if (np) {
 		hlimit = np->hop_limit;
+		ip6_flow_hdr(
+					hdr, tclass, ip6_make_flowlabel(
+					net, skb, fl6->flowlabel,
+					np->autoflowlabel, fl6));
+	}
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
-				np->autoflowlabel, fl6));
-
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
 	hdr->hop_limit = hlimit;
-- 
1.9.1
