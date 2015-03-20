From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next:master 925/931] include/linux/rhashtable.h:522:13:
 error: 'EEXIST' undeclared
Date: Sat, 21 Mar 2015 08:32:51 +1100
Message-ID: <20150320213251.GD23301@gondor.apana.org.au>
References: <201503210420.crMKxZr4%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:44571 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbbCTVdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:33:01 -0400
Content-Disposition: inline
In-Reply-To: <201503210420.crMKxZr4%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 04:49:22AM +0800, kbuild test robot wrote:
>
> All error/warnings:
> 
>    In file included from net/tipc/socket.c:37:0:
>    include/linux/rhashtable.h: In function '__rhashtable_insert_fast':
> >> include/linux/rhashtable.h:522:13: error: 'EEXIST' undeclared (first use in this function)
>      int err = -EEXIST;

Thanks for the report, this should fix it:

---8<---
rhashtable: Fix undeclared EEXIST build error on ia64

We need to include linux/errno.h in rhashtable.h since it doesn't
always get included otherwise.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index e5b76cf..18a6488 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -18,6 +18,7 @@
 #define _LINUX_RHASHTABLE_H
 
 #include <linux/compiler.h>
+#include <linux/errno.h>
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
