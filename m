From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] atm/lanai: fix section references
Date: Fri, 4 Mar 2005 15:19:37 -0800
Message-ID: <20050304151937.68eb11c0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, akpm <akpm@osdl.org>
To: chas@cmf.nrl.navy.mil
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


atm/lanai: fix text section references to __init text;
  they should be __devinit instead of __init;

Error: ./drivers/atm/lanai.o .text refers to 0000000000002105 R_X86_64_PC32     .init.text+0x0000000000000021
Error: ./drivers/atm/lanai.o .text refers to 0000000000002116 R_X86_64_PC32     .init.text+0x0000000000000021
Error: ./drivers/atm/lanai.o .text refers to 0000000000002132 R_X86_64_PC32     .init.text+0x0000000000000021

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/atm/lanai.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff -Naurp ./drivers/atm/lanai.c~atm_lanai_sections ./drivers/atm/lanai.c
--- ./drivers/atm/lanai.c~atm_lanai_sections	2005-03-01 23:37:50.000000000 -0800
+++ ./drivers/atm/lanai.c	2005-03-04 13:44:45.000000000 -0800
@@ -566,7 +566,7 @@ static int __init sram_test_word(
 	return -EIO;
 }
 
-static int __init sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
+static int __devinit sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
 {
 	int offset, result = 0;
 	for (offset = 0; offset < SRAM_BYTES && result == 0; offset += 4)
@@ -574,7 +574,7 @@ static int __init sram_test_pass(const s
 	return result;
 }
 
-static int __init sram_test_and_clear(const struct lanai_dev *lanai)
+static int __devinit sram_test_and_clear(const struct lanai_dev *lanai)
 {
 #ifdef FULL_MEMORY_TEST
 	int result;
@@ -860,7 +860,7 @@ static inline void aal0_buffer_free(stru
 #ifndef READ_EEPROM
 
 /* Stub functions to use if EEPROM reading is disabled */
-static int __init eeprom_read(struct lanai_dev *lanai)
+static int __devinit eeprom_read(struct lanai_dev *lanai)
 {
 	printk(KERN_INFO DEV_LABEL "(itf %d): *NOT* reading EEPROM\n",
 	    lanai->number);
@@ -868,7 +868,7 @@ static int __init eeprom_read(struct lan
 	return 0;
 }
 
-static int __init eeprom_validate(struct lanai_dev *lanai)
+static int __devinit eeprom_validate(struct lanai_dev *lanai)
 {
 	lanai->serialno = 0;
 	lanai->magicno = EEPROM_MAGIC_VALUE;
@@ -877,7 +877,7 @@ static int __init eeprom_validate(struct
 
 #else /* READ_EEPROM */
 
-static int __init eeprom_read(struct lanai_dev *lanai)
+static int __devinit eeprom_read(struct lanai_dev *lanai)
 {
 	int i, address;
 	u8 data;
@@ -953,7 +953,7 @@ static inline u32 eeprom_be4(const struc
 }
 
 /* Checksum/validate EEPROM contents */
-static int __init eeprom_validate(struct lanai_dev *lanai)
+static int __devinit eeprom_validate(struct lanai_dev *lanai)
 {
 	int i, s;
 	u32 v;
@@ -1449,7 +1449,7 @@ static void vcc_rx_aal0(struct lanai_dev
 #include <linux/vmalloc.h>
 #endif
 
-static int __init vcc_table_allocate(struct lanai_dev *lanai)
+static int __devinit vcc_table_allocate(struct lanai_dev *lanai)
 {
 #ifdef VCCTABLE_GETFREEPAGE
 	APRINTK((lanai->num_vci) * sizeof(struct lanai_vcc *) <= PAGE_SIZE,
@@ -1596,7 +1596,7 @@ static void lanai_reset(struct lanai_dev
 /*
  * Allocate service buffer and tell card about it
  */
-static int __init service_buffer_allocate(struct lanai_dev *lanai)
+static int __devinit service_buffer_allocate(struct lanai_dev *lanai)
 {
 	lanai_buf_allocate(&lanai->service, SERVICE_ENTRIES * 4, 8,
 	    lanai->pci);
@@ -1952,7 +1952,7 @@ static int check_board_id_and_rev(const 
 
 /* -------------------- PCI INITIALIZATION/SHUTDOWN: */
 
-static int __init lanai_pci_start(struct lanai_dev *lanai)
+static int __devinit lanai_pci_start(struct lanai_dev *lanai)
 {
 	struct pci_dev *pci = lanai->pci;
 	int result;
@@ -2148,7 +2148,7 @@ static inline void lanai_cbr_shutdown(st
 /* -------------------- OPERATIONS: */
 
 /* setup a newly detected device */
-static int __init lanai_dev_open(struct atm_dev *atmdev)
+static int __devinit lanai_dev_open(struct atm_dev *atmdev)
 {
 	struct lanai_dev *lanai = (struct lanai_dev *) atmdev->dev_data;
 	unsigned long raw_base;


---
