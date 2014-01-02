From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC 7/7] net: TX path for IPv6/UDP Generic UDP
 Encpasulation
Date: Thu, 2 Jan 2014 14:19:12 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021415030.32603@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hkchu@google.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:34091 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbaABWTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:19:14 -0500
Received: by mail-pb0-f73.google.com with SMTP id rq2so2053428pbb.0
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:19:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba..2abe2b8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1126,6 +1126,13 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct ip_tunnel_6rd ip6rd;
 #endif
 
+
+	/* Try generic tunnel ioctls first */
+	err = ip_tunnel_gen_ioctl(dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
+	err = 0;
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 #ifdef CONFIG_IPV6_SIT_6RD
-- 
1.8.5.1
