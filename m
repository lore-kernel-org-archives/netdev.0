From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] fix br_fdb_fini() section mismatch
Date: Thu, 6 Dec 2007 10:56:58 +0530
Message-ID: <20071206052658.GD30235@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:36690 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbXLFGDA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 01:03:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When compiling a kernel (current linus git or 2.6.24-rc4) with built-in
CONFIG_BRIDGE, I get the following error:

  LD      .tmp_vmlinux1
`br_fdb_fini' referenced in section `.init.text' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
make: *** [.tmp_vmlinux1] Error 1

This patch fixes it.

Signed-off-by: Harald Welte <laforge@gnumonks.org>

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index eb57502..bc40377 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -44,7 +44,7 @@ int __init br_fdb_init(void)
 	return 0;
 }
 
-void __exit br_fdb_fini(void)
+void br_fdb_fini(void)
 {
 	kmem_cache_destroy(br_fdb_cache);
 }
-- 
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
