From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: [PATCH 1/6] netlink: Move netlink attribute parsing support to lib/
Date: Wed, 25 Feb 2009 14:43:09 +0100
Message-ID: <1235569394-15217-2-git-send-email-Geert.Uytterhoeven@sonycom.com>
References: <1235569394-15217-1-git-send-email-Geert.Uytterhoeven@sonycom.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1235569394-15217-1-git-send-email-Geert.Uytterhoeven@sonycom.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netlink attribute parsing may be used even if CONFIG_NET is not set.
Move it from net/netlink to lib and control its inclusion based on the new
config symbol CONFIG_NLATTR, which is selected by CONFIG_NET.

Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 lib/Kconfig                        |    6 ++++++
 lib/Makefile                       |    2 ++
 net/netlink/attr.c => lib/nlattr.c |    0
 net/Kconfig                        |    1 +
 net/netlink/Makefile               |    2 +-
 5 files changed, 10 insertions(+), 1 deletions(-)
 rename net/netlink/attr.c => lib/nlattr.c (100%)

diff --git a/lib/Kconfig b/lib/Kconfig
index 03c2c24..cea9e30 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -174,4 +174,10 @@ config DISABLE_OBSOLETE_CPUMASK_FUNCTIONS
        bool "Disable obsolete cpumask functions" if DEBUG_PER_CPU_MAPS
        depends on EXPERIMENTAL && BROKEN
 
+#
+# Netlink attribute parsing support is select'ed if needed
+#
+config NLATTR
+	bool
+
 endmenu
diff --git a/lib/Makefile b/lib/Makefile
index 32b0e64..b2c09da 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -84,6 +84,8 @@ obj-$(CONFIG_HAVE_ARCH_TRACEHOOK) += syscall.o
 
 obj-$(CONFIG_DYNAMIC_PRINTK_DEBUG) += dynamic_printk.o
 
+obj-$(CONFIG_NLATTR) += nlattr.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
diff --git a/net/netlink/attr.c b/lib/nlattr.c
similarity index 100%
rename from net/netlink/attr.c
rename to lib/nlattr.c
diff --git a/net/Kconfig b/net/Kconfig
index cdb8fde..eab40a4 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -4,6 +4,7 @@
 
 menuconfig NET
 	bool "Networking support"
+	select NLATTR
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
 	  The reason is that some programs need kernel networking support even
diff --git a/net/netlink/Makefile b/net/netlink/Makefile
index e3589c2..bdd6ddf 100644
--- a/net/netlink/Makefile
+++ b/net/netlink/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the netlink driver.
 #
 
-obj-y  				:= af_netlink.o attr.o genetlink.o
+obj-y  				:= af_netlink.o genetlink.o
-- 
1.6.0.4

