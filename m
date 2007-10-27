From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/ipv{4,6}/esp{4,6}.c must #include
	<linux/scatterlist.h>
Date: Sat, 27 Oct 2007 04:34:48 +0200
Message-ID: <20071027023448.GP30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:38428 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751378AbXJ0Ce2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 22:34:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following compile errors in some configurations:

<--  snip  -->

...
  CC      net/ipv4/esp4.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/esp4.c: In function 'esp_output':
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/esp4.c:113: error: implicit declaration of function 'sg_init_table'
make[3]: *** [net/ipv4/esp4.o] Error 1
...
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv6/esp6.c: In function 'esp6_output':
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv6/esp6.c:112: error: implicit declaration of function 'sg_init_table'
make[3]: *** [net/ipv6/esp6.o] Error 1


<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/ipv4/esp4.c |    2 +-
 net/ipv6/esp6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

ecf93220d6af83516dbe04dcd09474a0423ce2ef 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index ba98401..23b647c 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -3,7 +3,7 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/esp.h>
-#include <asm/scatterlist.h>
+#include <linux/scatterlist.h>
 #include <linux/crypto.h>
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index f67d51a..f8bb136 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -29,7 +29,7 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/esp.h>
-#include <asm/scatterlist.h>
+#include <linux/scatterlist.h>
 #include <linux/crypto.h>
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>

