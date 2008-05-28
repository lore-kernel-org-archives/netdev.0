From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 2/2]IPv6: Fix the data length of get destination options with
 short length
Date: Wed, 28 May 2008 16:27:28 +0800
Message-ID: <483D1770.3040005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54371 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbYE1I2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 04:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 If get destination options with length which is not enough for that
option,getsockopt() will still return the real length of the option,
which is larger then the buffer space.
 This is because ipv6_getsockopt_sticky() returns the real length of
the option.

This patch fix this problem.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com> 

---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa7bedf..9293b9f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -832,7 +832,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
-	return ipv6_optlen(hdr);
+	return len;
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
-- 
1.5.3.8

