From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/9][ATM]: [ambassador] fix text section references to __init text and __initdata
Date: Mon, 07 Mar 2005 17:06:31 -0500
Message-ID: <200503072206.j27M6V7g020979@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 14:31:55-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [ambassador] fix text section references to __init text and __initdata
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/ambassador.c
#   2005/03/07 14:31:37-05:00 chas@relax.cmf.nrl.navy.mil +14 -14
#   [ATM]: [ambassador] fix text section references to __init text and __initdata
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2005-03-07 15:34:59 -05:00
+++ b/drivers/atm/ambassador.c	2005-03-07 15:34:59 -05:00
@@ -296,16 +296,16 @@
 #endif
 #define UCODE2(x) #x
 
-static u32 __initdata ucode_start = 
+static u32 __devinitdata ucode_start = 
 #include UCODE(start)
 ;
 
-static region __initdata ucode_regions[] = {
+static region __devinitdata ucode_regions[] = {
 #include UCODE(regions)
   { 0, 0 }
 };
 
-static u32 __initdata ucode_data[] = {
+static u32 __devinitdata ucode_data[] = {
 #include UCODE(data)
   0xdeadbeef
 };
@@ -1539,7 +1539,7 @@
 
 /********** creation of communication queues **********/
 
-static int __init create_queues (amb_dev * dev, unsigned int cmds,
+static int __devinit create_queues (amb_dev * dev, unsigned int cmds,
 				 unsigned int txs, unsigned int * rxs,
 				 unsigned int * rx_buffer_sizes) {
   unsigned char pool;
@@ -1769,7 +1769,7 @@
 	return res;
 }
 
-static int __init do_loader_command (volatile loader_block * lb,
+static int __devinit do_loader_command (volatile loader_block * lb,
 				     const amb_dev * dev, loader_command cmd) {
   
   unsigned long timeout;
@@ -1825,7 +1825,7 @@
 
 /* loader: determine loader version */
 
-static int __init get_loader_version (loader_block * lb,
+static int __devinit get_loader_version (loader_block * lb,
 				      const amb_dev * dev, u32 * version) {
   int res;
   
@@ -1841,7 +1841,7 @@
 
 /* loader: write memory data blocks */
 
-static int __init loader_write (loader_block * lb,
+static int __devinit loader_write (loader_block * lb,
 				const amb_dev * dev, const u32 * data,
 				u32 address, unsigned int count) {
   unsigned int i;
@@ -1860,7 +1860,7 @@
 
 /* loader: verify memory data blocks */
 
-static int __init loader_verify (loader_block * lb,
+static int __devinit loader_verify (loader_block * lb,
 				 const amb_dev * dev, const u32 * data,
 				 u32 address, unsigned int count) {
   unsigned int i;
@@ -1885,7 +1885,7 @@
 
 /* loader: start microcode */
 
-static int __init loader_start (loader_block * lb,
+static int __devinit loader_start (loader_block * lb,
 				const amb_dev * dev, u32 address) {
   PRINTD (DBG_FLOW|DBG_LOAD, "loader_start");
   
@@ -1961,7 +1961,7 @@
 
 /********** transfer and start the microcode **********/
 
-static int __init ucode_init (loader_block * lb, amb_dev * dev) {
+static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   unsigned int i = 0;
   unsigned int total = 0;
   const u32 * pointer = ucode_data;
@@ -2011,7 +2011,7 @@
     return cpu_to_be32 (virt_to_bus (addr));
 }
 
-static int __init amb_talk (amb_dev * dev) {
+static int __devinit amb_talk (amb_dev * dev) {
   adap_talk_block a;
   unsigned char pool;
   unsigned long timeout;
@@ -2058,7 +2058,7 @@
 }
 
 // get microcode version
-static void __init amb_ucode_version (amb_dev * dev) {
+static void __devinit amb_ucode_version (amb_dev * dev) {
   u32 major;
   u32 minor;
   command cmd;
@@ -2085,7 +2085,7 @@
 }
 
 // get end station address
-static void __init amb_esi (amb_dev * dev, u8 * esi) {
+static void __devinit amb_esi (amb_dev * dev, u8 * esi) {
   u32 lower4;
   u16 upper2;
   command cmd;
@@ -2131,7 +2131,7 @@
 	return;
 }
 
-static int __init amb_init (amb_dev * dev)
+static int __devinit amb_init (amb_dev * dev)
 {
   loader_block lb;
   
