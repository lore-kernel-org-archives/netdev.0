From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: use "unsigned int" in __xfrm6_pref_hash()
Date: Fri, 24 Mar 2017 01:53:09 +0300
Message-ID: <20170323225309.GC31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34652 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754645AbdCWWxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 18:53:14 -0400
Received: by mail-lf0-f66.google.com with SMTP id y193so18356610lfd.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 15:53:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
for address calculations.

Space savings:

	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-58 (-58)
	function                                     old     new   delta
	xfrm_hash_resize                            2752    2743      -9
	policy_hash_bysel                            985     973     -12
	policy_hash_direct                          1036     999     -37

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/xfrm/xfrm_hash.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -54,8 +54,8 @@ static inline unsigned int __xfrm4_dpref_spref_hash(const xfrm_address_t *daddr,
 static inline unsigned int __xfrm6_pref_hash(const xfrm_address_t *addr,
 					     __u8 prefixlen)
 {
-	int pdw;
-	int pbi;
+	unsigned int pdw;
+	unsigned int pbi;
 	u32 initval = 0;
 
 	pdw = prefixlen >> 5;     /* num of whole u32 in prefix */
