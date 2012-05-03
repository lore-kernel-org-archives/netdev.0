From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Thu, 03 May 2012 02:26:26 -0400 (EDT)
Message-ID: <20120503.022626.788447039512782116.davem@davemloft.net>
References: <20120503161623.ad219e088031fd66be212407@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab2ECG2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 02:28:36 -0400
In-Reply-To: <20120503161623.ad219e088031fd66be212407@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 3 May 2012 16:16:23 +1000

> After merging the final tree, today's linux-next build (sparc32 defconfig)
> failed like this:
> 
> net/core/sock.c: In function '__release_sock':
> net/core/sock.c:1703:4: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
> 
> Caused by commit e4cbb02a1070 ("net: add a prefetch in socket backlog
> processing").
> 
> I have reverted that commit for today.

Fixed as follows:

--------------------
net: Add missing linux/prefetch.h include to net/core/sock.c

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 1a88351..b8c818e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -113,6 +113,7 @@
 #include <linux/user_namespace.h>
 #include <linux/static_key.h>
 #include <linux/memcontrol.h>
+#include <linux/prefetch.h>
 
 #include <asm/uaccess.h>
 
-- 
1.7.10
