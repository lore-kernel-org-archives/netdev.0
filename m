From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 13/39] wimax: Makefile,
	Kconfig and docbook linkage for the stack
Date: Tue, 25 Nov 2008 23:39:09 -0800
Message-ID: <2fcfe5f5a92fa03f831addc1916dba3f3759b600.1227684996.git.inaky@linux.intel.com>
References: <cover.1227684995.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1227684995.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

This patch provides Makefile and KConfig for the WiMAX stack,
integrating them into the networking stack's Makefile, Kconfig and
doc-book templates.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 Documentation/DocBook/networking.tmpl |    8 +++++++
 net/Kconfig                           |    2 +
 net/Makefile                          |    1 +
 net/wimax/Kconfig                     |   36 +++++++++++++++++++++++++++++++++
 net/wimax/Makefile                    |   12 +++++++++++
 5 files changed, 59 insertions(+), 0 deletions(-)
 create mode 100644 net/wimax/Kconfig
 create mode 100644 net/wimax/Makefile

diff --git a/Documentation/DocBook/networking.tmpl b/Documentation/DocBook/networking.tmpl
index f24f9e8..7053c1c 100644
--- a/Documentation/DocBook/networking.tmpl
+++ b/Documentation/DocBook/networking.tmpl
@@ -101,6 +101,14 @@ X!Enet/core/wireless.c
      <sect1><title>Synchronous PPP</title>
 !Edrivers/net/wan/syncppp.c
      </sect1>
+     <sect1><title>WiMAX</title>
+!Enet/wimax/op-msg.c
+!Enet/wimax/op-reset.c
+!Enet/wimax/op-rfkill.c
+!Enet/wimax/stack.c
+!Iinclude/net/wimax.h
+!Iinclude/linux/wimax.h
+     </sect1>
   </chapter>
 
 </book>
diff --git a/net/Kconfig b/net/Kconfig
index d789d79..3bff221 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -251,6 +251,8 @@ source "net/ieee80211/Kconfig"
 
 endif # WIRELESS
 
+source "net/wimax/Kconfig"
+
 source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 
diff --git a/net/Makefile b/net/Makefile
index 27d1f10..620a505 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -61,3 +61,4 @@ obj-$(CONFIG_NET_9P)		+= 9p/
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
+obj-$(CONFIG_WIMAX)		+= wimax/
diff --git a/net/wimax/Kconfig b/net/wimax/Kconfig
new file mode 100644
index 0000000..67d5f4d
--- /dev/null
+++ b/net/wimax/Kconfig
@@ -0,0 +1,36 @@
+#
+# WiMAX LAN device configuration
+#
+
+menuconfig WIMAX
+       tristate "WiMAX Wireless Broadband support"
+       help
+
+         Select to configure support for devices that provide wireless
+         broadband connectivity using the WiMAX protocol (IEEE 802.16).
+
+         Please note that most of these devices require signing up for
+         a service plan with a provider.
+
+         The different WiMAX drivers can be enabled in the menu entry
+
+         Device Drivers > Network device support > WiMAX Wireless Broadband devices
+
+         If unsure, it is safe to select M (module).
+
+config WIMAX_DEBUG_LEVEL
+       int "WiMAX debug level"
+       depends on WIMAX
+       default 8
+       help
+
+         Select the maximum debug verbosity level to be compiled into
+         the WiMAX stack code.
+
+         By default, debug messages are disabled at runtime and can be
+         selectively enabled for different parts of the code using the
+         sysfs debug-levels file.
+
+         If set at zero, this will compile out all the debug code.
+
+         It is recommended that it is left at 8.
diff --git a/net/wimax/Makefile b/net/wimax/Makefile
new file mode 100644
index 0000000..22d5a28
--- /dev/null
+++ b/net/wimax/Makefile
@@ -0,0 +1,12 @@
+
+obj-$(CONFIG_WIMAX)		+= wimax.o
+
+wimax-objs :=		\
+	id-table.o	\
+	op-msg.o	\
+	op-open.o	\
+	op-reset.o	\
+	op-rfkill.o	\
+	stack.o
+
+
-- 
1.5.6.5
