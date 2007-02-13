From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6.20.y & net-2.6] [IPV6] HASHTABLES: Use appropriate seed
 for caluculating ehash index.
Date: Tue, 13 Feb 2007 09:48:41 +0900 (JST)
Message-ID: <20070213.094841.17517365.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, yoshfuji@linux-ipv6.org,
	handat@pm.nttdata.co.jp
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54502 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbXBMAsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 19:48:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <handat@pm.nttdata.co.jp> told me that connect(2) with TCPv6
socket almost always took a few minutes to return when we did not have any
ports available in the range of net.ipv4.ip_local_port_range.

The reason was that we used incorrect seed for calculating index of
hash when we check established sockets in __inet6_check_established().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/inet6_hashtables.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 30b16da..ae6b0e7 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -172,7 +172,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const struct in6_addr *saddr = &np->daddr;
 	const int dif = sk->sk_bound_dev_if;
 	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
-	const unsigned int hash = inet6_ehashfn(daddr, inet->num, saddr,
+	const unsigned int hash = inet6_ehashfn(daddr, lport, saddr,
 						inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	struct sock *sk2;
-- 
1.4.4.1.g562ce

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
