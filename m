From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: set mac_header correctly in GPE mode
Date: Wed, 11 May 2016 15:55:06 +0200
Message-ID: <3b9c5ffd8085c0af7072960865883a23be0d0a32.1462974886.git.jbenc@redhat.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32796 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933136AbcEKNzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 09:55:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For VXLAN-GPE, the interface is ARPHRD_NONE, thus we need to reset
mac_header after pulling the outer header.

Fixes: e1e5314de08b ("vxlan: implement GPE")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2f29d20aa08f..e030a804b772 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1338,6 +1338,8 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	if (__iptunnel_pull_header(skb, VXLAN_HLEN, protocol, raw_proto,
 				   !net_eq(vxlan->net, dev_net(vxlan->dev))))
 			goto drop;
+	if (raw_proto)
+		skb_reset_mac_header(skb);
 
 	if (vxlan_collect_metadata(vs)) {
 		__be32 vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
-- 
1.8.3.1
