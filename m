From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] IPv6: Fail with appropriate error code when sending RH0
Date: Fri, 27 Jun 2008 12:28:52 +0800
Message-ID: <48646C84.1000207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56134 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbYF0FAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending IPv6 packet with RH0(Type 0 Routing Header),
return EINVAL instead of EPERM.

Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 86e28a7..0101d4f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -377,12 +377,15 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 				break;
 #endif
 			default:
+				retv = -EINVAL;
 				goto sticky_done;
 			}
 
 			if ((rthdr->hdrlen & 1) ||
-			    (rthdr->hdrlen >> 1) != rthdr->segments_left)
+			    (rthdr->hdrlen >> 1) != rthdr->segments_left) {
+				retv = -EINVAL;
 				goto sticky_done;
+			}
 		}
 
 		retv = 0;
-- 
1.5.4.4 

