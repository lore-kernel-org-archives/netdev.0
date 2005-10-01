From: Russell King <rmk@arm.linux.org.uk>
Subject: [PATCH] sysctl_net.c:36: error: 'core_table' undeclared here
Date: Sat, 1 Oct 2005 14:35:18 +0100
Message-ID: <20051001133518.GA11254@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

During the build for ARM machine type "fortunet", this error occurred:

  CC      net/sysctl_net.o
net/sysctl_net.c:36: error: 'core_table' undeclared here (not in a function)

The ARM configuration which produced this error can be found in:
 arch/arm/configs/fortunet_defconfig

where the relevant options are:
CONFIG_SYSCTL=y
CONFIG_NET=y
# CONFIG_INET is not set

core_table appears to be declared in net/sock.h.  if CONFIG_INET were
defined, net/sock.h would have been included via:
  sysctl_net.c -> net/ip.h -> linux/ip.h -> net/sock.h

so include it directly.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

(This patch is completely untested atm; we're waiting for the machine
to complete an existing build run.  However, I think this is fairly
obviously correct.)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -16,6 +16,8 @@
 #include <linux/mm.h>
 #include <linux/sysctl.h>
 
+#include <net/sock.h>
+
 #ifdef CONFIG_INET
 #include <net/ip.h>
 #endif


-- 
Russell King
