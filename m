From: =?ISO-2022-JP?B?IllPU0hJRlVKSSBIaWRlYWtpICgbJEI1SEYjGyhCIBskQjFRGyhC?=
	 =?ISO-2022-JP?B?GyRCTEAbKEIpIg==?= <hideaki@yoshifuji.org>
Subject: [PATCH net-next-2.6 3/3] ipv6 sit: Set relay to 0.0.0.0 directly
 if relay_prefixlen == 0.
Date: Sun, 11 Oct 2009 22:31:37 +0900
Message-ID: <4AD1DE39.4050709@yoshifuji.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45122 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753011AbZJKNkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 09:40:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 sit: Set relay to 0.0.0.0 directly if relay_prefixlen == 0.

Do not use bit-shift if relay_prefixlen == 0;
relay_prefix << 32 does not result in 0.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/sit.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 193d0c6..510d31f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1014,9 +1014,12 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					 ip6rd.prefixlen);
 			if (!ipv6_addr_equal(&prefix, &ip6rd.prefix))
 				goto done;
-			relay_prefix = ip6rd.relay_prefix &
-				       htonl(0xffffffffUL <<
-					     (32 - ip6rd.relay_prefixlen));
+			if (ip6rd.relay_prefixlen)
+				relay_prefix = ip6rd.relay_prefix &
+					       htonl(0xffffffffUL <<
+						     (32 - ip6rd.relay_prefixlen));
+			else
+				relay_prefix = 0;
 			if (relay_prefix != ip6rd.relay_prefix)
 				goto done;
 
-- 
1.5.6.5


