From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH V2 2/2] net: socket: return EADDRNOTAVAIL when IPV6_PKTINFO's ipi6_addr is not available
Date: Tue,  5 Apr 2016 22:19:46 +0800
Message-ID: <1459865986-18271-3-git-send-email-zlpnobody@163.com>
References: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:55841 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758342AbcDEOUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 10:20:37 -0400
In-Reply-To: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

We can use IPV6_PKTINFO to specify the ipv6 source address when call
sendmsg() to send packet, but if the address is not available, call will
fail and EINVAL is returned. This error code is not very appropriate,
it failed maybe just because of a temporary network problem, i.e. when
the network recovery, sendmsg() call will become ok. Also RFC3542,
section 6.6 describe an example in error scenario that returns
EADDRNOTAVAIL: "ipi6_ifindex specifies an interface but the address
ipi6_addr is not available for use on that interface.". So return
EADDRNOTAVAIL instead of EINVAL here.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
---
 net/ipv6/datagram.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a73d701..20a968b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -753,7 +753,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 						   strict ? dev : NULL, 0) &&
 				    !ipv6_chk_acast_addr_src(net, dev,
 							     &src_info->ipi6_addr))
-					err = -EINVAL;
+					err = -EADDRNOTAVAIL;
 				else
 					fl6->saddr = src_info->ipi6_addr;
 			}
-- 
1.7.9.5
