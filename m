From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: Allow inet6_dump_addr() to handle more than 64 addresses
Date: Mon, 09 Nov 2009 18:40:17 +0100
Message-ID: <4AF85401.3020906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58459 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZKIRkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 12:40:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently, inet6_dump_addr() is not able to handle more than
64 ipv6 addresses per device. We must break from inner loops
in case skb is full, or else cursor is put at the end of list.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/addrconf.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 024bba3..1b072fe 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3519,6 +3519,8 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 							cb->nlh->nlmsg_seq,
 							RTM_NEWADDR,
 							NLM_F_MULTI);
+				if (err <= 0)
+					break;
 			}
 			break;
 		case MULTICAST_ADDR:
@@ -3532,6 +3534,8 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 							  cb->nlh->nlmsg_seq,
 							  RTM_GETMULTICAST,
 							  NLM_F_MULTI);
+				if (err <= 0)
+					break;
 			}
 			break;
 		case ANYCAST_ADDR:
@@ -3545,6 +3549,8 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 							  cb->nlh->nlmsg_seq,
 							  RTM_GETANYCAST,
 							  NLM_F_MULTI);
+				if (err <= 0)
+					break;
 			}
 			break;
 		default:
