From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] lto, wan/sbni: Make inline assembler symbols visible and assembler global
Date: Mon,  5 Aug 2013 15:18:14 -0700
Message-ID: <1375741094-8166-1-git-send-email-andi@firstfloor.org>
Cc: Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14089 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755357Ab3HEWSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 18:18:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

- Inline assembler defining C callable code has to be global
- The function has to be visible

Do this in wan/sbni

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/wan/sbni.c | 6 +++---
 drivers/net/wan/sbni.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index d43f4ef..b914ab3 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -160,7 +160,7 @@ static int  scandone	__initdata = 0;
 static int  num		__initdata = 0;
 
 static unsigned char  rxl_tab[];
-static u32  crc32tab[];
+__visible u32  sbni_crc32tab[];
 
 /* A list of all installed devices, for removing the driver module. */
 static struct net_device  *sbni_cards[ SBNI_MAX_NUM_CARDS ];
@@ -1563,7 +1563,7 @@ calc_crc32( u32  crc,  u8  *p,  u32  len )
 		"xorl	%%ebx, %%ebx\n"
 		"movl	%2, %%esi\n" 
 		"movl	%3, %%ecx\n" 
-		"movl	$crc32tab, %%edi\n"
+		"movl	$sbni_crc32tab, %%edi\n"
 		"shrl	$2, %%ecx\n"
 		"jz	1f\n"
 
@@ -1645,7 +1645,7 @@ calc_crc32( u32  crc,  u8  *p,  u32  len )
 #endif	/* ASM_CRC */
 
 
-static u32  crc32tab[] __attribute__ ((aligned(8))) = {
+__visible u32  sbni_crc32tab[] __attribute__ ((aligned(8))) = {
 	0xD202EF8D,  0xA505DF1B,  0x3C0C8EA1,  0x4B0BBE37,
 	0xD56F2B94,  0xA2681B02,  0x3B614AB8,  0x4C667A2E,
 	0xDCD967BF,  0xABDE5729,  0x32D70693,  0x45D03605,
diff --git a/drivers/net/wan/sbni.h b/drivers/net/wan/sbni.h
index 8426451..7e6d980 100644
--- a/drivers/net/wan/sbni.h
+++ b/drivers/net/wan/sbni.h
@@ -132,7 +132,7 @@ struct sbni_flags {
 /*
  * CRC-32 stuff
  */
-#define CRC32(c,crc) (crc32tab[((size_t)(crc) ^ (c)) & 0xff] ^ (((crc) >> 8) & 0x00FFFFFF))
+#define CRC32(c,crc) (sbni_crc32tab[((size_t)(crc) ^ (c)) & 0xff] ^ (((crc) >> 8) & 0x00FFFFFF))
       /* CRC generator 0xEDB88320 */
       /* CRC remainder 0x2144DF1C */
       /* CRC initial value 0x00000000 */
-- 
1.8.3.1
