From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 06/12] NET: ne3210: Fix bucketload full of section mismatches.
Date: Sun, 26 Jun 2011 12:26:26 +0100
Message-ID: <956509cd581fe584bd7ad1107eccf76cd99aec59.1309182743.git.ralf@linux-mips.org>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

WARNING: drivers/net/ne3210.o(.data+0x40): Section mismatch in reference from the variable ne3210_eisa_driver to the function .init.text:ne3210_eisa_probe()
The variable ne3210_eisa_driver references
the function __init ne3210_eisa_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console

Fixing this mismatch triggers yet more mismatches, fix those as well.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
---
 drivers/net/ne3210.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index 243ed2a..e30b8ff 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -80,17 +80,19 @@ static void ne3210_block_output(struct net_device *dev, int count, const unsigne
 
 #define NE3210_DEBUG	0x0
 
-static unsigned char irq_map[] __initdata = {15, 12, 11, 10, 9, 7, 5, 3};
-static unsigned int shmem_map[] __initdata = {0xff0, 0xfe0, 0xfff0, 0xd8, 0xffe0, 0xffc0, 0xd0, 0x0};
-static const char *ifmap[] __initdata = {"UTP", "?", "BNC", "AUI"};
-static int ifmap_val[] __initdata = {
+static unsigned char irq_map[] __devinitdata = {15, 12, 11, 10, 9, 7, 5, 3};
+static unsigned int shmem_map[] __devinitdata = {
+	0xff0, 0xfe0, 0xfff0, 0xd8, 0xffe0, 0xffc0, 0xd0, 0x0
+};
+static const char *ifmap[] __devinitdata = {"UTP", "?", "BNC", "AUI"};
+static int ifmap_val[] __devinitdata = {
 		IF_PORT_10BASET,
 		IF_PORT_UNKNOWN,
 		IF_PORT_10BASE2,
 		IF_PORT_AUI,
 };
 
-static int __init ne3210_eisa_probe (struct device *device)
+static int __devinit ne3210_eisa_probe (struct device *device)
 {
 	unsigned long ioaddr, phys_mem;
 	int i, retval, port_index;
-- 
1.7.4.4
