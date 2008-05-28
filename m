From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH] IPv6: Fix the data length of get destination options with
 short length
Date: Wed, 28 May 2008 15:15:27 +0800
Message-ID: <483D068F.8050201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@sunset.davemloft.net
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52338 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750847AbYE1HQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 03:16:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 If get destination options with length which is not enough for that
option,getsockopt() will still return the real length of the option,
which is larger then the buffer space.
 This is because ipv6_getsockopt_sticky() returns the real length of
the option.

This patch fix this problem.

Signed-off-by: Yang Hongyang <yaonghy@cn.fujitsu.cm> 

--- a/net/ipv6/ipv6_sockglue.c	2008-05-28 09:17:14.000000000 +0800
+++ b/net/ipv6/ipv6_sockglue.c	2008-05-28 12:41:01.000000000 +0800
@@ -832,7 +832,7 @@ static int ipv6_getsockopt_sticky(struct
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
-	return ipv6_optlen(hdr);
+	return len;
 }
 


