From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ip6mr: limit IPv6 MRT_TABLE identifiers
Date: Thu, 24 Jan 2013 09:38:34 +0300
Message-ID: <20130124063834.GA5611@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22821 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664Ab3AXGjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 01:39:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We did this for IPv4 in b49d3c1e1c "net: ipmr: limit MRT_TABLE
identifiers" but we need to do it for IPv6 as well.  On IPv6 the name
is "pim6reg" instead of "pimreg" so there is one less digit allowed.

The strcpy() is in ip6mr_reg_vif().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index acc3249..351ce98 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1766,6 +1766,9 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 			return -EINVAL;
 		if (get_user(v, (u32 __user *)optval))
 			return -EFAULT;
+		/* "pim6reg%u" should not exceed 16 bytes (IFNAMSIZ) */
+		if (v != RT_TABLE_DEFAULT && v >= 100000000)
+			return -EINVAL;
 		if (sk == mrt->mroute6_sk)
 			return -EBUSY;
 
