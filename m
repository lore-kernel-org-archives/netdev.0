From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 3/3] ip6_gre: do not leak dst on tunnel destroy path
Date: Tue,  6 May 2014 18:17:21 +0300
Message-ID: <1399389441-20095-3-git-send-email-popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback7.mail.ru ([94.100.176.135]:40524 "EHLO
	fallback7.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbaEFPRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:17:52 -0400
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru [94.100.177.106])
	by fallback7.mail.ru (mPOP.Fallback_MX) with ESMTP id 2CFBC10120AD6
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:17:49 +0400 (MSK)
Received: from [195.234.68.4] (port=52741 helo=tuxracer.skif.com.ua)
	by smtp46.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh7X-0007OK-Ty
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:17:28 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IPv6 GRE tunnel device destroy we may leak destination
if it was previously established in xmit path.

This might look like following on console:

  unregister_netdevice: waiting for lo to become free. Usage count = 3

on network namespace destroy path and/or ip6_gre unloaded.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75277b7..14ba77e 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -358,6 +358,7 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 	struct ip6gre_net *ign = net_generic(t->net, ip6gre_net_id);
 
 	ip6gre_tunnel_unlink(ign, t);
+	ip6_tnl_dst_reset(t);
 	dev_put(dev);
 }
 
-- 
1.8.3.4
