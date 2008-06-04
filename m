From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/3] [IPV6]: Do not change protocol for raw IPv6 sockets.
Date: Wed,  4 Jun 2008 15:49:06 +0400
Message-ID: <1212580148-9885-1-git-send-email-den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	"Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13500 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860AbYFDLtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 07:49:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not allowed to change underlying protocol for
   int fd = socket(PF_INET6, SOCK_RAW, IPPROTO_UDP);

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/ipv6_sockglue.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 56d55fe..763230e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -161,6 +161,9 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			struct ipv6_txoptions *opt;
 			struct sk_buff *pktopt;
 
+			if (sk->sk_type == SOCK_RAW)
+				break;
+
 			if (sk->sk_protocol != IPPROTO_UDP &&
 			    sk->sk_protocol != IPPROTO_UDPLITE &&
 			    sk->sk_protocol != IPPROTO_TCP)
-- 
1.5.3.rc5

