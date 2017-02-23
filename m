From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net] vxlan: correctly validate VXLAN ID against VXLAN_VID_MASK
Date: Thu, 23 Feb 2017 13:59:02 +0100
Message-ID: <3ea499d5a3564fc7074665962b1a10cccd900e59.1487854674.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:48948 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751107AbdBWNOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 08:14:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The incorrect check caused an off-by-one error: the maximum VID 0xffffff
was unusable.

Fixes: d342894c5d2f ("vxlan: virtual extensible lan")
Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 556953f53437..f89428fb7389 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2675,7 +2675,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 
 	if (data[IFLA_VXLAN_ID]) {
 		__u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
-		if (id >= VXLAN_VID_MASK)
+		if (id & ~VXLAN_VID_MASK)
 			return -ERANGE;
 	}
 
-- 
2.11.1
