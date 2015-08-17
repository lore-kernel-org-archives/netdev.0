From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] net: rtnetlink: be more strict when setting MAC address
Date: Mon, 17 Aug 2015 23:06:47 +0200
Message-ID: <1439845607-2824-1-git-send-email-phil@nwl.cc>
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35430 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbbHQVGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 17:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon evaluation of IFLA_ADDRESS and IFLA_BROADCAST messages, make sure
the passed argument length matches dev->addr_len exactly.

This fixes dubious behaviour of 'ip link set eth0 addr <MAC>' where
'<MAC>' is too long, e.g. '00:11:22:33:44:55:66:77'. Called like this,
'ip' would return successfully and the kernel sets eth0's MAC address to
the leading six octets of the passed argument.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/core/rtnetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 788ceed..1d61cd1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1456,11 +1456,11 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 {
 	if (dev) {
 		if (tb[IFLA_ADDRESS] &&
-		    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
+		    nla_len(tb[IFLA_ADDRESS]) != dev->addr_len)
 			return -EINVAL;
 
 		if (tb[IFLA_BROADCAST] &&
-		    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
+		    nla_len(tb[IFLA_BROADCAST]) != dev->addr_len)
 			return -EINVAL;
 	}
 
-- 
2.1.2
