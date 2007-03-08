From: Chris Wright <chrisw@sous-sol.org>
Subject: IPV6: make ipv6_getsockopt_sticky honor user's buffer size
Date: Wed, 7 Mar 2007 23:10:48 -0800
Message-ID: <20070308071048.GD10574@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:52326 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932699AbXCHHK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 02:10:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure not to copy_to_user more than user's buffer can handle (we
already checked the min, just use it) in ipv6_getsockopt_sticky.  And
while there, minor whitespace cleanup now that ipv6_getsockopt_sticky
call can nicely fit on one line.

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4e0561a..9396551 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -805,7 +805,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	hdr = opt->hopopt;
 
 	len = min_t(int, len, ipv6_optlen(hdr));
-	if (copy_to_user(optval, hdr, ipv6_optlen(hdr)))
+	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
 	return len;
 }
@@ -944,8 +944,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	{
 
 		lock_sock(sk);
-		len = ipv6_getsockopt_sticky(sk, np->opt,
-					     optval, len);
+		len = ipv6_getsockopt_sticky(sk, np->opt, optval, len);
 		release_sock(sk);
 		return put_user(len, optlen);
 	}
