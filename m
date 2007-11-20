From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/4] [IPV6] TCPMD5: Check return value of
 tcp_alloc_md5sig_pool().
Date: Wed, 21 Nov 2007 01:53:20 +0900 (JST)
Message-ID: <20071121.015320.15060696.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35814 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbXKTQxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 11:53:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/tcp_ipv6.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3aad861..b1bfbdd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -581,7 +581,10 @@ static int tcp_v6_md5_do_add(struct sock *sk, struct in6_addr *peer,
 			}
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		}
-		tcp_alloc_md5sig_pool();
+		if (tcp_alloc_md5sig_pool() == NULL) {
+			kfree(newkey);
+			return -ENOMEM;
+		}
 		if (tp->md5sig_info->alloced6 == tp->md5sig_info->entries6) {
 			keys = kmalloc((sizeof (tp->md5sig_info->keys6[0]) *
 				       (tp->md5sig_info->entries6 + 1)), GFP_ATOMIC);
-- 
1.4.4.4

