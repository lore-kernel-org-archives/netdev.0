From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] vxlan: Fix to enable UDP checksums on interface
Date: Thu,  6 Nov 2014 18:06:01 -0800
Message-ID: <1415325961-23053-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:49363 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbaKGCGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 21:06:10 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so11323234igd.1
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 18:06:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add definition to vxlan nla_policy for UDP checksum. This is necessary
to enable UDP checksums on VXLAN.

In some instances, enabling UDP checksums can improve performance on
receive for devices that return legacy checksum-unnecessary for UDP/IP.
Also, UDP checksum provides some protection against VNI corruption.

Testing:

Ran 200 instances of TCP_STREAM and TCP_RR on bnx2x.

TCP_STREAM
  IPv4, without UDP checksums
      14.41% TX CPU utilization
      25.71% RX CPU utilization
      9083.4 Mbps
  IPv4, with UDP checksums
      13.99% TX CPU utilization
      13.40% RX CPU utilization
      9095.65 Mbps

TCP_RR
  IPv4, without UDP checksums
      94.08% TX CPU utilization
      156/248/462 90/95/99% latencies
      1.12743e+06 tps
  IPv4, with UDP checksums
      94.43% TX CPU utilization
      158/250/462 90/95/99% latencies
      1.13345e+06 tps

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca30982..0ab4114 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2233,6 +2233,9 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
+	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
2.1.0.rc2.206.gedb03e5
