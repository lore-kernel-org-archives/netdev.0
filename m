From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Sat, 27 Oct 2007 01:08:07 +0200
Message-ID: <20071026230807.GE30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:41347 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751211AbXJZXHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 19:07:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following build error with CONFIG_SYSCTL=n:

<--  snip  -->

...
ERROR: "sysctl_rmem_max" [fs/dlm/dlm.ko] undefined!
ERROR: "sysctl_wmem_max" [drivers/net/rrunner.ko] undefined!
ERROR: "sysctl_rmem_max" [drivers/net/rrunner.ko] undefined!
make[2]: *** [__modpost] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
22ea6cd56e4fa844b0b1bbab2542f09eb6c9a5ab 
diff --git a/net/core/sock.c b/net/core/sock.c
index febbcbc..ee1cc4f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2004,7 +2004,5 @@ EXPORT_SYMBOL(sock_wmalloc);
 EXPORT_SYMBOL(sock_i_uid);
 EXPORT_SYMBOL(sock_i_ino);
 EXPORT_SYMBOL(sysctl_optmem_max);
-#ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(sysctl_rmem_max);
 EXPORT_SYMBOL(sysctl_wmem_max);
-#endif

