From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] ipv6: copy prefsrc setting when copying route entry
Date: Fri, 20 May 2011 23:27:24 +0200
Message-ID: <1305926844-12995-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Daniel Walter <sahne@0x90.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:49923 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752807Ab1ETVfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 17:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c3968a857a6b6c3d2ef4ead35776b055fb664d74
('ipv6: RTA_PREFSRC support for ipv6 route source address selection')
added support for ipv6 prefsrc as an alternative to ipv6 addrlabels,
but it did not work because the prefsrc entry was not copied.

Cc: Daniel Walter <sahne@0x90.at>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fd0eec6..deae5b5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1746,6 +1746,7 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif
+		memcpy(&rt->rt6i_prefsrc, &ort->rt6i_prefsrc, sizeof(struct rt6key));
 		rt->rt6i_table = ort->rt6i_table;
 	}
 	return rt;
-- 
1.7.3.4

