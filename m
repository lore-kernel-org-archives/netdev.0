From: Manjeet Pawar <manjeet.p@samsung.com>
Subject: [PATCH v2] ipv6:ipv6_pinfo dereferenced after NULL check
Date: Thu, 24 Nov 2016 16:11:57 +0530
Message-ID: <1479984117-39005-1-git-send-email-manjeet.p@samsung.com>
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com,
        Rohit Thapliyal <r.thapliyal@samsung.com>,
        Manjeet Pawar <manjeet.p@samsung.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
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
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>

---
v1->v2: Modified as per the suggestion of Hannes
        np ? np->autoflowlabel : ip6_default_np_autolabel(net)

 net/ipv6/ip6_output.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 59eb4ed..d734b5e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -215,11 +215,14 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	 */
 	if (np)
 		hlimit = np->hop_limit;
+
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-	ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
-						     np->autoflowlabel, fl6));
+	ip6_flow_hdr(hdr, tclass,
+		ip6_make_flowlabel(net, skb, fl6->flowlabel,
+			np ? np->autoflowlabel : ip6_default_np_autolabel(net),
+			fl6));
 
 	hdr->payload_len = htons(seg_len);
 	hdr->nexthdr = proto;
-- 
1.9.1
