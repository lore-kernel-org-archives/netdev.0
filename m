From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/4] [IPV4] TCPMD5: Use memmove() instead of memcpy()
 because we have overlaps.
Date: Wed, 21 Nov 2007 01:51:28 +0900 (JST)
Message-ID: <20071121.015128.16115326.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35809 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757137AbXKTQvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 11:51:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/tcp_ipv4.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ff36096..652c323 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -938,10 +938,10 @@ int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 				tp->md5sig_info->alloced4 = 0;
 			} else if (tp->md5sig_info->entries4 != i) {
 				/* Need to do some manipulation */
-				memcpy(&tp->md5sig_info->keys4[i],
-				       &tp->md5sig_info->keys4[i+1],
-				       (tp->md5sig_info->entries4 - i) *
-					sizeof(struct tcp4_md5sig_key));
+				memmove(&tp->md5sig_info->keys4[i],
+					&tp->md5sig_info->keys4[i+1],
+					(tp->md5sig_info->entries4 - i) *
+					 sizeof(struct tcp4_md5sig_key));
 			}
 			tcp_free_md5sig_pool();
 			return 0;
-- 
1.4.4.4

