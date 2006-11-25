From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [XFRM] STATE: Fix to respond error to get operation if no matching entry exists.
Date: Sat, 25 Nov 2006 13:23:59 +0900
Message-ID: <11644286393508-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>,
	TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:5053 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S935105AbWKYE26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 23:28:58 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When application uses XFRM_MSG_GETSA to get state entry through netlink
socket and kernel has no matching one, the application expects reply
message with error status by kernel.

Kernel doesn't send the message back in the case of Mobile IPv6 route
optimization protocols (i.e. routing header or destination options
header). This is caused by incorrect return code "0" from
net/xfrm/xfrm_user.c(xfrm_user_state_lookup) and it makes kernel skip to
acknowledge at net/netlink/af_netlink.c(netlink_rcv_skb).

This patch fix to reply ESRCH to application.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>
---
 net/xfrm/xfrm_user.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c4cde57..2ee14f8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -495,6 +495,7 @@ static struct xfrm_state *xfrm_user_stat
 			goto out;
 		}
 
+		err = -ESRCH;
 		x = xfrm_state_lookup_byaddr(&p->daddr, saddr, p->proto,
 					     p->family);
 	}
-- 
1.4.2

