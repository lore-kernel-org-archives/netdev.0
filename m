From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: fix incorrect type
Date: Mon, 11 Apr 2016 17:06:08 +0200
Message-ID: <b870830205240e7eb0732ddfdaa6534ab061fb1c.1460387151.git.jbenc@redhat.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209AbcDKPGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 11:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The protocol is 16bit, not 32bit.

Fixes: e1e5314de08ba ("vxlan: implement GPE")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9f3634064c92..7f697a3f00a4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1181,7 +1181,7 @@ out:
 }
 
 static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
-				__be32 *protocol,
+				__be16 *protocol,
 				struct sk_buff *skb, u32 vxflags)
 {
 	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)unparsed;
@@ -1284,7 +1284,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	struct vxlanhdr unparsed;
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
-	__be32 protocol = htons(ETH_P_TEB);
+	__be16 protocol = htons(ETH_P_TEB);
 	bool raw_proto = false;
 	void *oiph;
 
-- 
1.8.3.1
