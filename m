From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission #4  for S2io 10GbE driver
Date: Sat, 20 Mar 2004 04:56:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405C153A.2020809@pobox.com>
References: <001001c40e34$d2c3c4b0$0300a8c0@S2IOtech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020907080605080708010109"
Cc: netdev@oss.sgi.com, "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <001001c40e34$d2c3c4b0$0300a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020907080605080708010109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

applied to 2.6, thanks.

Note I made the attached changes, otherwise the build would throw a 
bunch of errors and warnings.  Also, I merged it into 
drivers/net/s2io{.c,.h,-regs.h} since there isn't a need for a separate 
directory for just three files.

	Jeff




--------------020907080605080708010109
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/s2io.h 1.1 vs 1.2 =====
--- 1.1/drivers/net/s2io.h	Sat Mar 20 04:38:16 2004
+++ 1.2/drivers/net/s2io.h	Sat Mar 20 04:47:53 2004
@@ -14,8 +14,8 @@
 #define _S2IO_H
 
 #define TBD 0
-#define BIT(loc)        (((u64)0x8000000000000000ULL) >> loc)
-#define vBIT(val, loc, sz)  (((u64)val) << (64-loc-sz))
+#define BIT(loc)		(1ULL << (loc))
+#define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
 
 #ifndef BOOL
 #define BOOL    int
@@ -531,7 +531,7 @@
 	RxD_t rxd[MAX_RXDS_PER_BLOCK];
 
 	u64 reserved_0;
-#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFF
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
 	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd in this blk */
 	u64 reserved_2_pNext_RxD_block;	/*@ Logical ptr to next */
 	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.
@@ -738,7 +738,7 @@
 	u16 last_link_state;
 #define	LINK_DOWN	1
 #define	LINK_UP		2
-} nic_t __cacheline_aligned;
+} nic_t;
 
 #define RESET_ERROR 1;
 #define CMD_ERROR   2;
===== drivers/net/s2io.c 1.1 vs 1.2 =====
--- 1.1/drivers/net/s2io.c	Sat Mar 20 04:38:15 2004
+++ 1.2/drivers/net/s2io.c	Sat Mar 20 04:47:53 2004
@@ -65,7 +65,7 @@
 
 /* local include */
 #include "s2io.h"
-#include "regs.h"
+#include "s2io-regs.h"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "s2io";

--------------020907080605080708010109--
