From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv4: fix table id in getroute response
Date: Wed, 11 Jan 2017 15:42:17 -0800
Message-ID: <1484178137-23735-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36113 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754039AbdAKXnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 18:43:06 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so1836390pfu.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 15:42:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtm_table is an 8-bit field while table ids are allowed up to u32. Commit
709772e6e065 ("net: Fix routing tables with id > 255 for legacy software")
added the preference to set rtm_table in dumps to RT_TABLE_COMPAT if the
table id is > 255. The table id returned on get route requests should do
the same.

Fixes: c36ba6603a11 ("net: Allow user to get table id from route lookup")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0fcac8e7a2b2..709ffe67d1de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2472,7 +2472,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= fl4->flowi4_tos;
-	r->rtm_table	= table_id;
+	r->rtm_table	= table_id < 256 ? table_id : RT_TABLE_COMPAT;
 	if (nla_put_u32(skb, RTA_TABLE, table_id))
 		goto nla_put_failure;
 	r->rtm_type	= rt->rt_type;
-- 
2.1.4
