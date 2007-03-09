From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full
 length for sticky options.
Date: Fri, 09 Mar 2007 10:13:28 +0900 (JST)
Message-ID: <20070309.101328.78855655.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34456 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992863AbXCIBNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 20:13:02 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bug noticed by Chris Wright <chrisw@sous-sol.org>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ipv6_sockglue.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 44ccdf0..6ad8921 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -824,9 +824,9 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 		return 0;
 
 	len = min_t(int, len, ipv6_optlen(hdr));
-	if (copy_to_user(optval, hdr, ipv6_optlen(hdr)))
+	if (copy_to_user(optval, hdr, len));
 		return -EFAULT;
-	return len;
+	return ipv6_optlen(hdr);
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
-- 
1.4.4.1.g562ce

