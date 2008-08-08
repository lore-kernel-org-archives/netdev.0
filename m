From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH] IPv6:fix the return interface index when get it while no
 message is received
Date: Fri, 08 Aug 2008 13:59:54 +0800
Message-ID: <489BE0DA.80306@cn.fujitsu.com>
References: <489BCB1A.5040100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58921 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752484AbYHHGAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 02:00:34 -0400
In-Reply-To: <489BCB1A.5040100@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> when I use getsockopt(sk, IPPROTO_IPV6, IPV6_2292PKTOPTIONS,(char *)incmsg, &cnt)
> to get receiving interface index while no message is received,
> 
> What interface index should be returned?

When get receiving interface index while no message is received,
the bounded device's index of the socket should be returned?

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

--- a/ipv6_sockglue.c
+++ b/ipv6_sockglue.c
@@ -911,7 +911,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		} else {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif;
+				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
 				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
 				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 			}
@@ -921,7 +921,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxoinfo) {
 				struct in6_pktinfo src_info;
-				src_info.ipi6_ifindex = np->mcast_oif;
+				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif : sk->sk_bound_dev_if;
 				ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr);
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 			}
-- 
1.5.3.8
