From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] wl3501: fix module_param types/warnings
Date: Mon, 10 Jan 2005 15:04:11 -0800
Message-ID: <20050110150411.4bbef660.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>, acme@conectiva.com.br
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Linux 2.6.10-bk13

Fix gcc warning:
drivers/net/wireless/wl3501_cs.c:2282: warning: return from incompatible pointer type

module_param() isn't happy about different types for irq_mask;
unsigned long vs. int.  Make it uint consistently.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/wireless/wl3501_cs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -Naurp ./drivers/net/wireless/wl3501_cs.c~wl3501_types ./drivers/net/wireless/wl3501_cs.c
--- ./drivers/net/wireless/wl3501_cs.c~wl3501_types	2005-01-10 10:38:39.908438288 -0800
+++ ./drivers/net/wireless/wl3501_cs.c	2005-01-10 12:40:44.175980376 -0800
@@ -100,7 +100,7 @@ module_param(pc_debug, int, 0);
 /* Parameters that can be set with 'insmod' */
 /* Bit map of interrupts to choose from */
 /* This means pick from 15, 14, 12, 11, 10, 9, 7, 5, 4, and 3 */
-static unsigned long wl3501_irq_mask = 0xdeb8;
+static unsigned int wl3501_irq_mask = 0xdeb8;
 static int wl3501_irq_list[4] = { -1 };
 
 /*
@@ -2279,7 +2279,7 @@ static void __exit wl3501_exit_module(vo
 module_init(wl3501_init_module);
 module_exit(wl3501_exit_module);
 
-module_param(wl3501_irq_mask, int, 0);
+module_param(wl3501_irq_mask, uint, 0);
 module_param_array(wl3501_irq_list, int, NULL, 0);
 MODULE_AUTHOR("Fox Chen <mhchen@golf.ccl.itri.org.tw>, "
 	      "Arnaldo Carvalho de Melo <acme@conectiva.com.br>,"

---
