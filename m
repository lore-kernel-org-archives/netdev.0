From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: Add table id from route lookup to route response
Date: Wed,  2 Sep 2015 09:40:34 -0700
Message-ID: <1441212034-37464-3-git-send-email-dsa@cumulusnetworks.com>
References: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34655 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbbIBQko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:40:44 -0400
Received: by padhy1 with SMTP id hy1so16955081pad.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:40:43 -0700 (PDT)
In-Reply-To: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_fill_info which is called for 'route get' requests hardcodes the
table id as RT_TABLE_MAIN which is not correct when multiple tables
are used. Use the newly added table id in the rtable to send back
the correct table.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92acc95b7578..2738bf4132db 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2325,8 +2325,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= fl4->flowi4_tos;
-	r->rtm_table	= RT_TABLE_MAIN;
-	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN))
+	r->rtm_table	= rt->rt_table_id;
+	if (nla_put_u32(skb, RTA_TABLE, rt->rt_table_id))
 		goto nla_put_failure;
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
-- 
1.9.1
