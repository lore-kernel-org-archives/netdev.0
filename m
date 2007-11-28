From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 1/4] udp: fix send buffer check
Date: Wed, 28 Nov 2007 13:52:47 -0500
Message-ID: <474DB8FF.2040609@redhat.com>
References: <474DB80E.5070403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbXK1SyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:54:25 -0500
In-Reply-To: <474DB80E.5070403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces sndbuf size check before memory allocation for
send buffer.

signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 ip_output.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -pruN net-2.6/net/ipv4/ip_output.c net-2.6-udp-take9a2-p1/net/ipv4/ip_output.c
--- net-2.6/net/ipv4/ip_output.c	2007-11-14 10:49:06.000000000 -0500
+++ net-2.6-udp-take9a2-p1/net/ipv4/ip_output.c	2007-11-27 11:11:37.000000000 -0500
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
