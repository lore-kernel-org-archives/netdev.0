From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 1/5] fix send buffer check
Date: Tue, 13 Nov 2007 21:47:49 -0500
Message-ID: <473A61D5.8020203@redhat.com>
References: <473A5FD6.5010209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <haoki@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219AbXKNCtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 21:49:14 -0500
In-Reply-To: <473A5FD6.5010209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces sndbuf size check before memory allocation for
send buffer.

signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

  ip_output.c |    5 +++++
  1 file changed, 5 insertions(+)

diff -pruN net-2.6/net/ipv4/ip_output.c net-2.6-udp-p1/net/ipv4/ip_output.c
--- net-2.6/net/ipv4/ip_output.c	2007-11-13 08:19:57.000000000 -0500
+++ net-2.6-udp-p1/net/ipv4/ip_output.c	2007-11-13 16:10:03.000000000 -0500
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
Hideo Aoki
Hitachi Computer Products (America) Inc.
