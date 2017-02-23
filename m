From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net v2] vxlan: correctly validate VXLAN ID against VXLAN_N_VID
Date: Thu, 23 Feb 2017 17:19:41 +0100
Message-ID: <4650647d72b8f219cb725b40de9b4627f3306919.1487866739.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:53488 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751049AbdBWQTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 11:19:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The incorrect check caused an off-by-one error: the maximum VID 0xffffff
was unusable.

Fixes: d342894c5d2f ("vxlan: virtual extensible lan")
Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
v2: check against VXLAN_N_VID instead of changing operator


 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 556953f53437..268c2a12e61d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2675,7 +2675,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 
 	if (data[IFLA_VXLAN_ID]) {
 		__u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
-		if (id >= VXLAN_VID_MASK)
+		if (id >= VXLAN_N_VID)
 			return -ERANGE;
 	}
 
-- 
2.11.1
