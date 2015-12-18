From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH] ipip: ioctl: Remove superfluous IP-TTL handling.
Date: Thu, 17 Dec 2015 16:46:39 -0800
Message-ID: <1450399599-7528-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33786 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614AbbLRArK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 19:47:10 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so21353066pfn.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 16:47:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP-TTL case is already handled in ip_tunnel_ioctl() API.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ipip.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 1f06729..4044da6 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -252,9 +252,6 @@ ipip_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	p.i_key = p.o_key = 0;
 	p.i_flags = p.o_flags = 0;
-	if (p.iph.ttl)
-		p.iph.frag_off |= htons(IP_DF);
-
 	err = ip_tunnel_ioctl(dev, &p, cmd);
 	if (err)
 		return err;
-- 
1.8.3.1
