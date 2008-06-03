From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Tue,  3 Jun 2008 15:08:42 +0400
Message-ID: <1212491322-9161-1-git-send-email-den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	"Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10809 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbYFCLJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 07:09:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_sk_dst_lookup returns held dst entry. It should be released on all paths
beyond this point. Add missed release when up->pending is set.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/udp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1fd784f..3235528 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -813,6 +813,7 @@ back_from_confirm:
 		/* The socket is already corked while preparing it. */
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
+		dst_release(dst);
 
 		LIMIT_NETDEBUG(KERN_DEBUG "udp cork app bug 2\n");
 		err = -EINVAL;
-- 
1.5.3.rc5

