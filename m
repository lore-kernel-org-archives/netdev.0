From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 1/4] [UDP]: fix send buffer check
Date: Sat, 15 Dec 2007 00:14:51 -0500
Message-ID: <476362CB.1070004@redhat.com>
References: <47636120.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbXLOFUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 00:20:35 -0500
In-Reply-To: <47636120.4050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces sndbuf size check before memory allocation for
send buffer.

signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 ip_output.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -pruN net-2.6/net/ipv4/ip_output.c net-2.6-udp-take10a4-p1/net/ipv4/ip_output.c
--- net-2.6/net/ipv4/ip_output.c	2007-12-11 10:54:55.000000000 -0500
+++ net-2.6-udp-take10a4-p1/net/ipv4/ip_output.c	2007-12-14 16:42:04.000000000 -0500
@@ -1004,6 +1004,11 @@ alloc_new_skb:
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
+				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
+				    > 2 * sk->sk_sndbuf) {
+					err = -ENOBUFS;
+					goto error;
+				}
 				if (copy > PAGE_SIZE)
 					copy = PAGE_SIZE;
 				page = alloc_pages(sk->sk_allocation, 0);
-- 
Hitachi Computer Products (America) Inc.
