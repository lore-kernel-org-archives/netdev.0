From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] atm/zatm: fix section references
Date: Fri, 4 Mar 2005 15:21:05 -0800
Message-ID: <20050304152105.20b50328.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
To: chas@cmf.nrl.navy.mil, akpm <akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


atm/zatm: fix text section references to __init text and __initdata;
  they should be __devinit instead of __init;

Error: ./drivers/atm/zatm.o .text refers to 0000000000001abb R_X86_64_PC32     .init.text+0x0000000000000154
Error: ./drivers/atm/zatm.o .text refers to 0000000000001ad3 R_X86_64_PC32     .init.text+0x0000000000000154

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/atm/zatm.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff -Naurp ./drivers/atm/zatm.c~atm_zatm_sections ./drivers/atm/zatm.c
--- ./drivers/atm/zatm.c~atm_zatm_sections	2005-03-01 23:37:50.000000000 -0800
+++ ./drivers/atm/zatm.c	2005-03-04 13:16:50.000000000 -0800
@@ -1090,7 +1090,7 @@ static irqreturn_t zatm_int(int irq,void
 /*----------------------------- (E)EPROM access -----------------------------*/
 
 
-static void __init eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
+static void __devinit eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
     unsigned short cmd)
 {
 	int error;
@@ -1101,7 +1101,7 @@ static void __init eprom_set(struct zatm
 }
 
 
-static unsigned long __init eprom_get(struct zatm_dev *zatm_dev,
+static unsigned long __devinit eprom_get(struct zatm_dev *zatm_dev,
     unsigned short cmd)
 {
 	unsigned int value;
@@ -1114,7 +1114,7 @@ static unsigned long __init eprom_get(st
 }
 
 
-static void __init eprom_put_bits(struct zatm_dev *zatm_dev,
+static void __devinit eprom_put_bits(struct zatm_dev *zatm_dev,
     unsigned long data,int bits,unsigned short cmd)
 {
 	unsigned long value;
@@ -1129,7 +1129,7 @@ static void __init eprom_put_bits(struct
 }
 
 
-static void __init eprom_get_byte(struct zatm_dev *zatm_dev,
+static void __devinit eprom_get_byte(struct zatm_dev *zatm_dev,
     unsigned char *byte,unsigned short cmd)
 {
 	int i;
@@ -1145,7 +1145,7 @@ static void __init eprom_get_byte(struct
 }
 
 
-static unsigned char __init eprom_try_esi(struct atm_dev *dev,
+static unsigned char __devinit eprom_try_esi(struct atm_dev *dev,
     unsigned short cmd,int offset,int swap)
 {
 	unsigned char buf[ZEPROM_SIZE];
@@ -1166,7 +1166,7 @@ static unsigned char __init eprom_try_es
 }
 
 
-static void __init eprom_get_esi(struct atm_dev *dev)
+static void __devinit eprom_get_esi(struct atm_dev *dev)
 {
 	if (eprom_try_esi(dev,ZEPROM_V1_REG,ZEPROM_V1_ESI_OFF,1)) return;
 	(void) eprom_try_esi(dev,ZEPROM_V2_REG,ZEPROM_V2_ESI_OFF,0);


---
