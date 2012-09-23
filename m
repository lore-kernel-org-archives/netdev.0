From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] inet_diag: make config INET_DIAG bool
Date: Sun, 23 Sep 2012 11:49:14 +0800
Message-ID: <1348372154-20663-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:6254 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753480Ab2IWDtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 23:49:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when inet_diag being compiled as module, inet_diag_handler_dump
set netlink_dump_control.dump to inet_diag_dump,so if module
inet_diag is unloaded,netlink will still try to call this function
in netlink_dump. this will cause kernel panic.

this patch makes config INET_DIAG bool to avoid inet_diag being
compiled as module.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 5a19aeb..da56f84 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -403,7 +403,7 @@ config INET_LRO
 	  If unsure, say Y.
 
 config INET_DIAG
-	tristate "INET: socket monitoring interface"
+	bool "INET: socket monitoring interface"
 	default y
 	---help---
 	  Support for INET (TCP, DCCP, etc) socket monitoring interface used by
-- 
1.7.7.6
