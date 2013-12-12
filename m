From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH] ipv6: fix incorrect type in initializer
Date: Thu, 12 Dec 2013 11:41:21 +0100
Message-ID: <1386844881-32017-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:37902 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab3LLKlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 05:41:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced by 1397ed35f22d7c30d0b89ba74b6b7829220dfcfd
  "ipv6: add flowinfo for tcp6 pkt_options for all cases"

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ipv6_sockglue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bc4d8a2..dac04d2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1035,7 +1035,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
 			}
 			if (np->rxopt.bits.rxflow) {
-				int flowinfo = np->rcv_flowinfo;
+				__be32 flowinfo = np->rcv_flowinfo;
 				put_cmsg(&msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);
 			}
 		}
-- 
1.8.5.1
