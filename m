From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] ipv4: fix nexthop attlen check in fib_nh_match
Date: Mon, 13 Oct 2014 11:54:23 +0200
Message-ID: <1413194063-10354-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:32789 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbaJMJy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 05:54:26 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so8144163wgh.10
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 02:54:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_nh_match does not match nexthops correctly. Example:

This command is not successful and route is removed. After this patch
applied, the route is correctly matched and result is:
RTNETLINK answers: No such process

Please consider this for stable trees as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/fib_semantics.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 5b6efb3..f99f41b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -537,7 +537,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 			return 1;
 
 		attrlen = rtnh_attrlen(rtnh);
-		if (attrlen < 0) {
+		if (attrlen > 0) {
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-- 
1.9.3
