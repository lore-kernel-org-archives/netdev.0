From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 5/8] tty: cpm_uart: replace CONFIG_8xx by CONFIG_CPM1
Date: Thu, 12 Mar 2015 16:23:59 +0100 (CET)
Message-ID: <20150312152359.B611E1A2420@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two config options exist to define powerpc MPC8xx:
* CONFIG_PPC_8xx
* CONFIG_8xx
In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
communication co-processor

arch/powerpc/platforms/Kconfig.cputype has contained the following
comment about CONFIG_8xx item for some years:
"# this is temp to handle compat with arch=ppc"

It looks like not many places still have that old CONFIG_8xx used,
so it is likely to be a good time to get rid of it completely ?

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 drivers/tty/serial/Kconfig             | 2 +-
 drivers/tty/serial/cpm_uart/Makefile   | 2 +-
 drivers/tty/serial/cpm_uart/cpm_uart.h | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/tty/serial/Kconfig b/drivers/tty/serial/Kconfig
index c9dbc62..6086586 100644
--- a/drivers/tty/serial/Kconfig
+++ b/drivers/tty/serial/Kconfig
@@ -868,7 +868,7 @@ config SERIAL_PMACZILOG_CONSOLE
 
 config SERIAL_CPM
 	tristate "CPM SCC/SMC serial port support"
-	depends on CPM2 || 8xx
+	depends on CPM2 || CPM1
 	select SERIAL_CORE
 	help
 	  This driver supports the SCC and SMC serial ports on Motorola 
diff --git a/drivers/tty/serial/cpm_uart/Makefile b/drivers/tty/serial/cpm_uart/Makefile
index e072724..896a5d5 100644
--- a/drivers/tty/serial/cpm_uart/Makefile
+++ b/drivers/tty/serial/cpm_uart/Makefile
@@ -6,6 +6,6 @@ obj-$(CONFIG_SERIAL_CPM) += cpm_uart.o
 
 # Select the correct platform objects.
 cpm_uart-objs-$(CONFIG_CPM2)	+= cpm_uart_cpm2.o
-cpm_uart-objs-$(CONFIG_8xx)	+= cpm_uart_cpm1.o
+cpm_uart-objs-$(CONFIG_CPM1)	+= cpm_uart_cpm1.o
 
 cpm_uart-objs	:= cpm_uart_core.o $(cpm_uart-objs-y)
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart.h b/drivers/tty/serial/cpm_uart/cpm_uart.h
index cf34d26..0ad027b 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart.h
+++ b/drivers/tty/serial/cpm_uart/cpm_uart.h
@@ -19,7 +19,7 @@
 
 #if defined(CONFIG_CPM2)
 #include "cpm_uart_cpm2.h"
-#elif defined(CONFIG_8xx)
+#elif defined(CONFIG_CPM1)
 #include "cpm_uart_cpm1.h"
 #endif
 
-- 
2.1.0
