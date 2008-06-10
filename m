From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH 3/3] IPv4:Check IP_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 15:51:47 +0800
Message-ID: <484E3293.8000507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58083 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbYFJHwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 03:52:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IP_MULTICAST_LOOP option can only be set with o or 1. When 
other valuse are set, the kernel should return an error of EINVAL.

In addition, the option should not be uesd by SOCK_STREAM type,
same as IP_MULTICAST_IF, IP_MULTICAST_TTL.
  
But the kernel doesn't check them.

Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv4/ip_sockglue.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e0514e8..82196a5 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -558,8 +558,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->mc_ttl = val;
 		break;
 	case IP_MULTICAST_LOOP:
+		if (sk->sk_type == SOCK_STREAM)
+			goto e_inval;
 		if (optlen<1)
 			goto e_inval;
+		if (val < 0 || val > 1)
+			goto e_inval;
 		inet->mc_loop = !!val;
 		break;
 	case IP_MULTICAST_IF:
-- 
1.5.4.4

