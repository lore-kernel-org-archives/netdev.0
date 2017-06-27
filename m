From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next] vxlan: fix incorrect nlattr access in MTU check
Date: Tue, 27 Jun 2017 14:42:43 +0200
Message-ID: <a6097db8a2ce4a13c108651c58a345ccff3505b0.1498565985.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, roopa@cumulusnetworks.com,
        pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:39146 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752927AbdF0MnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 08:43:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The access to the wrong variable could lead to a NULL dereference and
possibly other invalid memory reads in vxlan newlink/changelink requests
with a IFLA_MTU attribute.

Fixes: a985343ba906 "vxlan: refactor verification and application of configuration"
Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 0dafd8e6c665..fd0ff97e3d81 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2727,7 +2727,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
 	}
 
 	if (tb[IFLA_MTU]) {
-		u32 mtu = nla_get_u32(data[IFLA_MTU]);
+		u32 mtu = nla_get_u32(tb[IFLA_MTU]);
 
 		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU)
 			return -EINVAL;
-- 
2.13.2
