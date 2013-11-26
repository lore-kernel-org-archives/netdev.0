From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: judge the accept_ra_defrtr before calling rt6_route_rcv
Date: Tue, 26 Nov 2013 15:46:56 +0800
Message-ID: <529451F0.1060707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:25335 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751553Ab3KZHtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Nov 2013 02:49:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


when dealing with a RA message, if accept_ra_defrtr is false,
the kernel will not add the default route, and then deal with
the following route information options. Unfortunately, those
options maybe contain default route, so let's judge the
accept_ra_defrtr before calling rt6_route_rcv.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ndisc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3512177..3008651 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1277,6 +1277,9 @@ skip_linkparms:
 			    ri->prefix_len == 0)
 				continue;
 #endif
+			if (ri->prefix_len == 0 &&
+			    !in6_dev->cnf.accept_ra_defrtr)
+				continue;
 			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
 			rt6_route_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3,
-- 
1.8.3.1
