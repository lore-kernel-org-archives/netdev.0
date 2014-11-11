From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: fix IPV6_PKTINFO with v4 mapped
Date: Mon, 10 Nov 2014 17:54:25 -0800
Message-ID: <1415670865.9613.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:56993 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbaKKBya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 20:54:30 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn18so182842igb.9
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 17:54:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use IS_ENABLED(CONFIG_IPV6), to enable this code if IPv6 is
a module.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: c8e6ad0829a7 ("ipv6: honor IPV6_PKTINFO with v4 mapped addresses on sendmsg")
---
 net/ipv4/ip_sockglue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 21894df662622bcb0f4bec01a2e612480276b92b..b7826575d2154dc67934d47adf90c7cd0fc40635 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -195,7 +195,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
-#if defined(CONFIG_IPV6)
+#if IS_ENABLED(CONFIG_IPV6)
 		if (allow_ipv6 &&
 		    cmsg->cmsg_level == SOL_IPV6 &&
 		    cmsg->cmsg_type == IPV6_PKTINFO) {
