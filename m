From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv4: remove unnecessary check on orig_oif
Date: Fri, 11 Aug 2017 17:02:02 -0700
Message-ID: <1502496122-27784-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35058 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751439AbdHLACJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 20:02:09 -0400
Received: by mail-pg0-f65.google.com with SMTP id l64so4148266pge.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 17:02:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_iif is going to be set to either 0 or orig_oif. If orig_oif
is 0 it amounts to the same end result so remove the check.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6324ade81a81..9c9895a6fc0f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2237,7 +2237,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->rt_iif	= orig_oif ? : 0;
+	rth->rt_iif = orig_oif;
 	if (res->table)
 		rth->rt_table_id = res->table->tb_id;
 
-- 
2.1.4
