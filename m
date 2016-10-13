From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tipc: info leak in __tipc_nl_add_udp_addr()
Date: Thu, 13 Oct 2016 11:06:06 +0300
Message-ID: <20161013080606.GA3389@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
        Richard Alpe <richard.alpe@ericsson.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should clear out the padding and unused struct members so that we
don't expose stack information to userspace.

Fixes: fdb3accc2c15 ('tipc: add the ability to get UDP options via netlink')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This goes into the net tree.

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index d80cd3f..78cab9c 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -407,6 +407,7 @@ static int __tipc_nl_add_udp_addr(struct sk_buff *skb,
 	if (ntohs(addr->proto) == ETH_P_IP) {
 		struct sockaddr_in ip4;
 
+		memset(&ip4, 0, sizeof(ip4));
 		ip4.sin_family = AF_INET;
 		ip4.sin_port = addr->port;
 		ip4.sin_addr.s_addr = addr->ipv4.s_addr;
@@ -417,6 +418,7 @@ static int __tipc_nl_add_udp_addr(struct sk_buff *skb,
 	} else if (ntohs(addr->proto) == ETH_P_IPV6) {
 		struct sockaddr_in6 ip6;
 
+		memset(&ip6, 0, sizeof(ip6));
 		ip6.sin6_family = AF_INET6;
 		ip6.sin6_port  = addr->port;
 		memcpy(&ip6.sin6_addr, &addr->ipv6, sizeof(struct in6_addr));
