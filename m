From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] ipcomp: fix crypto_alloc_comp() error check
Date: Mon, 27 Nov 2006 14:07:22 +0900
Message-ID: <20061127050722.GG1231@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.205]:24277 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1757009AbWK0FOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 00:14:31 -0500
Received: by nz-out-0102.google.com with SMTP id s1so614725nze
        for <netdev@vger.kernel.org>; Sun, 26 Nov 2006 21:14:30 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of crypto_alloc_comp() should be checked by
IS_ERR().

Cc: David Miller <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 net/ipv4/ipcomp.c  |    2 +-
 net/ipv6/ipcomp6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: work-fault-inject/net/ipv6/ipcomp6.c
===================================================================
--- work-fault-inject.orig/net/ipv6/ipcomp6.c
+++ work-fault-inject/net/ipv6/ipcomp6.c
@@ -368,7 +368,7 @@ static struct crypto_comp **ipcomp6_allo
 	for_each_possible_cpu(cpu) {
 		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
 							    CRYPTO_ALG_ASYNC);
-		if (!tfm)
+		if (IS_ERR(tfm))
 			goto error;
 		*per_cpu_ptr(tfms, cpu) = tfm;
 	}
Index: work-fault-inject/net/ipv4/ipcomp.c
===================================================================
--- work-fault-inject.orig/net/ipv4/ipcomp.c
+++ work-fault-inject/net/ipv4/ipcomp.c
@@ -369,7 +369,7 @@ static struct crypto_comp **ipcomp_alloc
 	for_each_possible_cpu(cpu) {
 		struct crypto_comp *tfm = crypto_alloc_comp(alg_name, 0,
 							    CRYPTO_ALG_ASYNC);
-		if (!tfm)
+		if (IS_ERR(tfm))
 			goto error;
 		*per_cpu_ptr(tfms, cpu) = tfm;
 	}
