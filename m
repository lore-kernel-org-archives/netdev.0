From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/9] net: Remove e_nobufs label from ip_route_input_slow
Date: Wed, 23 Sep 2015 08:15:16 -0700
Message-ID: <1443021322-48621-4-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36643 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbbIWPPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:39 -0400
Received: by pacgz1 with SMTP id gz1so8980382pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:39 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e_nobufs has 1 user. Move setting err to -ENOBUFS for the 1 user and
use the goto out label instead of e_nobufs. Stepping stone patch; next
one moves rth code into a helper function.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3c5000db5972..e3b18cc1952f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1805,8 +1805,10 @@ out:	return err;
 
 	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
-	if (!rth)
-		goto e_nobufs;
+	if (!rth) {
+		err = -ENOBUFS;
+		goto out;
+	}
 
 	rth->dst.output= ip_rt_bug;
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1852,10 +1854,6 @@ out:	return err;
 #endif
 	goto out;
 
-e_nobufs:
-	err = -ENOBUFS;
-	goto out;
-
 martian_source:
 	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
 	goto out;
-- 
1.9.1
