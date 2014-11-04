From: Gregory Fong <gregory.0xf0@gmail.com>
Subject: [PATCH] bridge: include in6.h in if_bridge.h for struct in6_addr
Date: Tue,  4 Nov 2014 11:21:21 -0800
Message-ID: <1415128881-30183-1-git-send-email-gregory.0xf0@gmail.com>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	carlos@redhat.com, eblake@redhat.com,
	Kumar Gala <galak@codeaurora.org>,
	Gregory Fong <gregory.0xf0@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if_bridge.h uses struct in6_addr ip6, but wasn't including the in6.h
header.  Thomas Backlund originally sent a patch to do this, but this
revealed a redefinition issue: https://lkml.org/lkml/2013/1/13/116

The redefinition issue should have been fixed by the following Linux
commits:
ee262ad827f89e2dc7851ec2986953b5b125c6bc inet: defines IPPROTO_* needed for module alias generation
cfd280c91253cc28e4919e349fa7a813b63e71e8 net: sync some IP headers with glibc

and the following glibc commit:
6c82a2f8d7c8e21e39237225c819f182ae438db3 Coordinate IPv6 definitions for Linux and glibc

so actually include the header now.

Reported-by: Colin Guthrie <colin@mageia.org>
Reported-by: Christiaan Welvaart <cjw@daneel.dyndns.org>
Reported-by: Thomas Backlund <tmb@mageia.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
---
 include/uapi/linux/if_bridge.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 39f621a..da17e45 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -15,6 +15,7 @@
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
+#include <linux/in6.h>
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
-- 
1.9.1
