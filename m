From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net] openvswitch: Fix dependency on IPv6 defrag.
Date: Fri, 11 Sep 2015 15:01:16 -0700
Message-ID: <1442008876-19462-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: pshelar@nicira.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When NF_CONNTRACK is built-in, NF_DEFRAG_IPV6 is a module, and
OPENVSWITCH is built-in, the following build error would occur:

net/built-in.o: In function `ovs_ct_execute':
(.text+0x10f587): undefined reference to `nf_ct_frag6_gather'

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 2a071f4..d143aa9 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -5,7 +5,8 @@
 config OPENVSWITCH
 	tristate "Open vSwitch"
 	depends on INET
-	depends on (!NF_CONNTRACK || NF_CONNTRACK)
+	depends on !NF_CONNTRACK || \
+		   (NF_CONNTRACK && (!NF_DEFRAG_IPV6 || NF_DEFRAG_IPV6))
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
-- 
2.1.4
