From: Michal Ludvig <michal@logix.cz>
Subject: [PATCH] SIT tunnels over IPsec
Date: Fri, 16 Jan 2004 19:38:00 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40082F88.9030705@logix.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030007080708000805060003"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030007080708000805060003
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi!

The attached patch fixes IPv6-in-IPv4 (SIT) tunnel over IPsec. Without 
it the SIT packets originated from the same host as the IPsec endpoint 
is leave the interface unencrypted and of course the tunnel doesn't 
work. The patch fixes it. Tested.

Please apply.

Thanks,

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal


--------------030007080708000805060003
Content-Type: text/plain;
 name="kernel-sit.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-sit.diff"

--- linux-2.6.1.orig/net/ipv6/sit.c	2004-01-09 08:00:03.000000000 +0100
+++ linux-2.6.1/net/ipv6/sit.c	2004-01-16 09:51:13.000000000 +0100
@@ -485,7 +485,8 @@ static int ipip6_tunnel_xmit(struct sk_b
 					      { .daddr = dst,
 						.saddr = tiph->saddr,
 						.tos = RT_TOS(tos) } },
-				    .oif = tunnel->parms.link };
+				    .oif = tunnel->parms.link,
+				    .proto = IPPROTO_IPV6 };
 		if (ip_route_output_key(&rt, &fl)) {
 			tunnel->stat.tx_carrier_errors++;
 			goto tx_error_icmp;
@@ -757,7 +758,8 @@ static int ipip6_tunnel_init(struct net_
 					      { .daddr = iph->daddr,
 						.saddr = iph->saddr,
 						.tos = RT_TOS(iph->tos) } },
-				    .oif = tunnel->parms.link };
+				    .oif = tunnel->parms.link,
+				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
 		if (!ip_route_output_key(&rt, &fl)) {
 			tdev = rt->u.dst.dev;


--------------030007080708000805060003--
