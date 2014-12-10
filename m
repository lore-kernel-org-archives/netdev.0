From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2] if_bridge: fix conflict with glibc
Date: Tue, 9 Dec 2014 21:41:22 -0800
Message-ID: <20141209214122.76b15851@urahara>
References: <20141209203007.188651df@urahara>
	<20141209.234954.1634249639621060084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregory.0xf0@gmail.com, f.fainelli@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60065 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbaLJFld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 00:41:33 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so2085333pdb.4
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 21:41:32 -0800 (PST)
In-Reply-To: <20141209.234954.1634249639621060084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though kernel and glibc headers have same effective values
Gcc complains about redefinitions. Since this is a header expected
to be used by userspace, use glibc header.

This supersedes change in commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7
and fixes build of iproute2 with Glibc-2.19. This follows similar usage
in include/uapi/linux for l2tp.h

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/if_bridge.h	2014-12-09 20:25:21.656016605 -0800
+++ b/include/uapi/linux/if_bridge.h	2014-12-09 21:32:01.391034756 -0800
@@ -15,7 +15,9 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
-#include <linux/in6.h>
+#ifndef __KERNEL__
+#include <netinet/in.h>
+#endif
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
