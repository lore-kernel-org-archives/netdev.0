From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH v2 5/9] tproxy: allow non-local binds of IPv6 sockets if
 IP_TRANSPARENT is enabled
Date: Thu, 21 Oct 2010 12:47:09 +0200
Message-ID: <20101021104709.5192.12412.stgit@este.odu>
References: <20101021104709.5192.31249.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20101021104709.5192.31249.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Scheidler <bazsi@balabit.hu>

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
---
 net/ipv6/af_inet6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6022098..9480572 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -343,7 +343,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!ipv6_chk_addr(net, &addr->sin6_addr,
+				if (!inet->transparent && !ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					err = -EADDRNOTAVAIL;
 					goto out_unlock;


