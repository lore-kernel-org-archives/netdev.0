From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] atm/ambassador: fix init section references
Date: Fri, 4 Mar 2005 15:19:56 -0800
Message-ID: <20050304151956.5725d408.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, akpm <akpm@osdl.org>
To: myxie@debian.org, chas@cmf.nrl.navy.mil
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


atm/ambassador: fix text section references to __init text and __initdata;

The biggest negative about this AFAIK is that it makes ucode_data
non-initdata, and that moves about 8 KB of data from .init.data
to .data.  Similarly, .text increases by approx. 1300 bytes (on x86-32).

Error: ./drivers/atm/ambassador.o .text refers to 0000000000002a07 R_X86_64_PC32     .init.text+0x0000000000000149
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002a45 R_X86_64_32S      .init.data+0x0000000000000040
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002a7c R_X86_64_PC32     .init.data+0x0000000000000020
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002a83 R_X86_64_PC32     .init.data+0x000000000000001c
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002b40 R_X86_64_PC32     .init.text+0x0000000000000149
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002bbc R_X86_64_PC32     .init.text+0x0000000000000149
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002c0f R_X86_64_32S      .init.data+0x0000000000000024
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002c17 R_X86_64_32S      .init.data+0x0000000000000020
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002c3c R_X86_64_PC32     .init.data+0xfffffffffffffffc
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002c6a R_X86_64_PC32     .init.text+0x0000000000000149
Error: ./drivers/atm/ambassador.o .text refers to 0000000000002c77 R_X86_64_32S      .init.data+0x0000000000000040

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/atm/ambassador.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff -Naurp ./drivers/atm/ambassador.c~atm_ambass_sections ./drivers/atm/ambassador.c
--- ./drivers/atm/ambassador.c~atm_ambass_sections	2005-03-01 23:37:48.000000000 -0800
+++ ./drivers/atm/ambassador.c	2005-03-04 14:31:49.000000000 -0800
@@ -296,16 +296,16 @@ static inline void __init show_version (
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
@@ -1539,7 +1539,7 @@ static void do_housekeeping (unsigned lo
 
 /********** creation of communication queues **********/
 
-static int __init create_queues (amb_dev * dev, unsigned int cmds,
+static int __devinit create_queues (amb_dev * dev, unsigned int cmds,
 				 unsigned int txs, unsigned int * rxs,
 				 unsigned int * rx_buffer_sizes) {
   unsigned char pool;
@@ -1769,7 +1769,7 @@ static  int decode_loader_result (loader
 	return res;
 }
 
-static int __init do_loader_command (volatile loader_block * lb,
+static int __devinit do_loader_command (volatile loader_block * lb,
 				     const amb_dev * dev, loader_command cmd) {
   
   unsigned long timeout;
@@ -1825,7 +1825,7 @@ static int __init do_loader_command (vol
 
 /* loader: determine loader version */
 
-static int __init get_loader_version (loader_block * lb,
+static int __devinit get_loader_version (loader_block * lb,
 				      const amb_dev * dev, u32 * version) {
   int res;
   
@@ -1841,7 +1841,7 @@ static int __init get_loader_version (lo
 
 /* loader: write memory data blocks */
 
-static int __init loader_write (loader_block * lb,
+static int __devinit loader_write (loader_block * lb,
 				const amb_dev * dev, const u32 * data,
 				u32 address, unsigned int count) {
   unsigned int i;
@@ -1860,7 +1860,7 @@ static int __init loader_write (loader_b
 
 /* loader: verify memory data blocks */
 
-static int __init loader_verify (loader_block * lb,
+static int __devinit loader_verify (loader_block * lb,
 				 const amb_dev * dev, const u32 * data,
 				 u32 address, unsigned int count) {
   unsigned int i;
@@ -1885,7 +1885,7 @@ static int __init loader_verify (loader_
 
 /* loader: start microcode */
 
-static int __init loader_start (loader_block * lb,
+static int __devinit loader_start (loader_block * lb,
 				const amb_dev * dev, u32 address) {
   PRINTD (DBG_FLOW|DBG_LOAD, "loader_start");
   
@@ -1961,7 +1961,7 @@ static int amb_reset (amb_dev * dev, int
 
 /********** transfer and start the microcode **********/
 
-static int __init ucode_init (loader_block * lb, amb_dev * dev) {
+static int __devinit ucode_init (loader_block * lb, amb_dev * dev) {
   unsigned int i = 0;
   unsigned int total = 0;
   const u32 * pointer = ucode_data;
@@ -2011,7 +2011,7 @@ static inline u32 bus_addr(void * addr) 
     return cpu_to_be32 (virt_to_bus (addr));
 }
 
-static int __init amb_talk (amb_dev * dev) {
+static int __devinit amb_talk (amb_dev * dev) {
   adap_talk_block a;
   unsigned char pool;
   unsigned long timeout;
@@ -2058,7 +2058,7 @@ static int __init amb_talk (amb_dev * de
 }
 
 // get microcode version
-static void __init amb_ucode_version (amb_dev * dev) {
+static void __devinit amb_ucode_version (amb_dev * dev) {
   u32 major;
   u32 minor;
   command cmd;
@@ -2085,7 +2085,7 @@ static u8 bit_swap (u8 byte)
 }
 
 // get end station address
-static void __init amb_esi (amb_dev * dev, u8 * esi) {
+static void __devinit amb_esi (amb_dev * dev, u8 * esi) {
   u32 lower4;
   u16 upper2;
   command cmd;
@@ -2131,7 +2131,7 @@ static void fixup_plx_window (amb_dev *d
 	return;
 }
 
-static int __init amb_init (amb_dev * dev)
+static int __devinit amb_init (amb_dev * dev)
 {
   loader_block lb;
   


---
