From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] vxlan: Wrong type passed to %pIS
Date: Sat,  7 Feb 2015 03:17:31 +0100
Message-ID: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:37407 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbbBGCRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 21:17:41 -0500
Received: by mail-lb0-f177.google.com with SMTP id p9so21140262lbv.8
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 18:17:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

src_ip is a pointer to a union vxlan_addr, one member of which is a
struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
the value of src_ip itself. Since %pIS formally expects something of
type struct sockaddr*, let's pass a pointer to the appropriate union
member, though this of course doesn't change the generated code.

Fixes: e4c7ed415387 ("vxlan: add ipv6 support")
Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a8c755dcab14..11defbb24183 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -991,7 +991,7 @@ static bool vxlan_snoop(struct net_device *dev,
 		if (net_ratelimit())
 			netdev_info(dev,
 				    "%pM migrated from %pIS to %pIS\n",
-				    src_mac, &rdst->remote_ip, &src_ip);
+				    src_mac, &rdst->remote_ip.sa, &src_ip->sa);
 
 		rdst->remote_ip = *src_ip;
 		f->updated = jiffies;
-- 
2.1.3
