From: Stephen Hemminger <stephen@networkplumber.org>
Subject: PATCH] Revert "bridge: include in6.h in if_bridge.h for struct
 in6_addr"
Date: Tue, 9 Dec 2014 20:30:07 -0800
Message-ID: <20141209203007.188651df@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Gregory Fong <gregory.0xf0@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45528 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbaLJEaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:30:18 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so1982919pdj.13
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:30:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7.

iproute2 uses sanitized kernel headers, and this change broke the build.
The problem is that the iproute2 ip/iplink_bridge_slave.c include if_bridge.h
but this causes a redefintion error when Glibc <netlink/in.h> is included.

Since iproute2 is arguably the most important user of network headers,
the uapi header change should be reverted.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Please update stable as well.

 include/uapi/linux/if_bridge.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index b03ee8f..439fd0d 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -15,7 +15,6 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
-#include <linux/in6.h>
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
-- 
2.1.3
