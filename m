From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/25) sk98: elimnate nested macro.
Date: Mon, 15 Nov 2004 15:22:08 -0800
Message-ID: <20041115152208.6684c483@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace nested macros to handle defining 64bit constants with
simpler macro. Would prefer to just remove it but it gets used in multiple
OS common code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:48 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:48 -08:00
@@ -110,8 +110,8 @@
 
 typedef struct s_DrvRlmtMbuf SK_MBUF;
 
-#define	SK_CONST64	INT64_C
-#define	SK_CONSTU64	UINT64_C
+#define	SK_CONST64(x)	(x##ll)
+#define	SK_CONSTU64(x)	(x##ull)
 
 #define SK_MEMCPY(dest,src,size)	memcpy(dest,src,size)
 #define SK_MEMCMP(s1,s2,size)		memcmp(s1,s2,size)
@@ -139,13 +139,6 @@
 #define t_scalar_t	int
 #define t_uscalar_t	unsigned int
 #define uintptr_t	unsigned long
-
-#define __CONCAT__(A,B) A##B
-
-#define INT32_C(a)		__CONCAT__(a,L)
-#define INT64_C(a)		__CONCAT__(a,LL)
-#define UINT32_C(a)		__CONCAT__(a,UL)
-#define UINT64_C(a)		__CONCAT__(a,ULL)
 
 #ifdef DEBUG
 #define SK_DBG_PRINTF		printk
