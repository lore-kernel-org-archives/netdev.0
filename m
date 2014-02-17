From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv4: validate source address if the packet is for us
Date: Mon, 17 Feb 2014 13:03:31 +0800
Message-ID: <53019823.20700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:38317 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaBQFEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 00:04:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


otherwise the host may deal with the invaild packet.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/fib_frontend.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c7539e2..4423a1a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -321,6 +321,7 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
 	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
+	    oif != LOOPBACK_IFINDEX &&
 	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
 		*itag = 0;
 		return 0;
-- 
1.8.3.1
