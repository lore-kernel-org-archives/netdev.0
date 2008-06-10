From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH 2/3] IPv6:Check IPV6_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 15:51:19 +0800
Message-ID: <484E3277.5030808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53141 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbYFJHwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 03:52:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC3493 says, IPV6_MULTICAST_LOOP option can only be set with o or 1.
when other valuse are set, the kernel should return an error of EINVAL.

In addition, the option should not be uesd by SOCK_STREAM type, same as
IPV6_MULTICAST_IF, IPV6_MULTICAST_HOPS.
  
But the kernel doesn't check them.

Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 26b83e5..3b45def 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -456,8 +456,12 @@ done:
 		break;
 
 	case IPV6_MULTICAST_LOOP:
+		if (sk->sk_type == SOCK_STREAM)
+			goto e_inval;
 		if (optlen < sizeof(int))
 			goto e_inval;
+		if (val > 1 || val < 0)
+			goto e_inval;
 		np->mc_loop = valbool;
 		retv = 0;
 		break;
-- 


