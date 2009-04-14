From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]ipv6:remove useless check
Date: Tue, 14 Apr 2009 09:51:00 +0800
Message-ID: <49E3EC04.5000105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60332 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbZDNBul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 21:50:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After switch (rthdr->type) {...},the check below is completely useless.Because:
if the type is 2,then hdrlen must be 2 and segments_left must be 1,clearly the
check is redundant;if the type is not 2,then goto sticky_done,the check is useless
too.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

---
 net/ipv6/ipv6_sockglue.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d31df0f..a7fdf9a 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -380,10 +380,6 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			default:
 				goto sticky_done;
 			}
-
-			if ((rthdr->hdrlen & 1) ||
-			    (rthdr->hdrlen >> 1) != rthdr->segments_left)
-				goto sticky_done;
 		}
 
 		retv = 0;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
