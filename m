From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] pkt_cls.h incompatiables
Date: Thu, 22 Jul 2004 13:45:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
References: <200407161544.59342.arekm@pld-linux.org>
	<20040716103759.1928c2ae@dell_ss3.pdx.osdl.net>
	<200407172357.15832.arekm@pld-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arkadiusz Miskiewicz <arekm@pld-linux.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jamal Hadi Salim <hadi@znyx.com>
In-Reply-To: <200407172357.15832.arekm@pld-linux.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The recent changes to (6 Jul 04) pkt_cls.h are evil, you can't build a version
of 'tc' to work unless you know the kernel config!

It has several API problems:
  - API data structures change on kernel config options
  - new fields should be added at the end of a structure to allow
    binary compatibility.
 
This patch tries to clean this up.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
--- a/include/linux/pkt_cls.h	2004-07-22 13:44:04 -07:00
+++ b/include/linux/pkt_cls.h	2004-07-22 13:44:04 -07:00
@@ -117,17 +117,8 @@
 struct tc_police
 {
 	__u32			index;
-#ifdef CONFIG_NET_CLS_ACT
 	int 			refcnt;
 	int 			bindcnt;
-#endif
-/* Turned off because it requires new tc
- * to work (for now maintain ABI)
- *
-#ifdef CONFIG_NET_CLS_ACT
-	__u32			capab;
-#endif
-*/
 	int			action;
 #define TC_POLICE_UNSPEC	TC_ACT_UNSPEC
 #define TC_POLICE_OK		TC_ACT_OK
@@ -195,12 +186,8 @@
 	TCA_U32_DIVISOR,
 	TCA_U32_SEL,
 	TCA_U32_POLICE,
-#ifdef CONFIG_NET_CLS_ACT
 	TCA_U32_ACT,   
-#endif
-#ifdef CONFIG_NET_CLS_IND
 	TCA_U32_INDEV,
-#endif
 	__TCA_U32_MAX
 };
 
@@ -212,9 +199,7 @@
 	__u32		val;
 	int		off;
 	int		offmask;
-#ifdef CONFIG_CLS_U32_PERF
-	unsigned long	kcnt;
-#endif
+	__u32		kcnt;
 };
 
 struct tc_u32_sel
@@ -229,11 +214,9 @@
 
 	short			hoff;
 	__u32			hmask;
-#ifdef CONFIG_CLS_U32_PERF
+	struct tc_u32_key	keys[0];
 	unsigned long		rcnt;
 	unsigned long		rhit;
-#endif
-	struct tc_u32_key	keys[0];
 };
 
 /* Flags */
@@ -300,12 +283,8 @@
 	TCA_FW_UNSPEC,
 	TCA_FW_CLASSID,
 	TCA_FW_POLICE,
-#ifdef CONFIG_NET_CLS_IND
 	TCA_FW_INDEV,
-#endif
-#ifdef CONFIG_NET_CLS_ACT
 	TCA_FW_ACT,
-#endif
 	__TCA_FW_MAX
 };
 
