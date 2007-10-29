From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 1/5] fix send buffer check
Date: Mon, 29 Oct 2007 17:22:53 -0400
Message-ID: <47264F2D.3010105@redhat.com>
References: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010608070306000903080100"
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546AbXJ2V0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:26:00 -0400
In-Reply-To: <47264E2D.4080109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010608070306000903080100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch introduces sndbuf size check before memory allocation for
send buffer.

--
Hideo Aoki
Hitachi Computer Products (America) Inc.

--------------010608070306000903080100
Content-Type: text/x-patch;
 name="ip_append_data_sndbuf_check.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_append_data_sndbuf_check.patch"


Signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Signed-off-by: Hideo Aoki <haoki@redhat.com>

 ip_output.c |    5 +++++
 1 file changed, 5 insertions(+)

diff -pruN linux-2.6.24-rc1/net/ipv4/ip_output.c linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/ip_output.c
--- linux-2.6.24-rc1/net/ipv4/ip_output.c	2007-10-24 11:34:34.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p1/net/ipv4/ip_output.c	2007-10-24 11:46:43.000000000 -0400
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

--------------010608070306000903080100--
