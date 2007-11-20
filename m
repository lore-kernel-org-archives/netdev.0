From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: PATCH 1/4] [IPV4] TCPMD5: Omit redundant NULL check for kfree()
 argument.
Date: Wed, 21 Nov 2007 01:50:51 +0900 (JST)
Message-ID: <20071121.015051.84409851.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35803 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbXKTQur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 11:50:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/tcp_ipv4.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e566f3c..ff36096 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -900,8 +900,7 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 				       sizeof(*keys) * md5sig->entries4);
 
 			/* Free old key list, and reference new one */
-			if (md5sig->keys4)
-				kfree(md5sig->keys4);
+			kfree(md5sig->keys4);
 			md5sig->keys4 = keys;
 			md5sig->alloced4++;
 		}
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
