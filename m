From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: sched: pkt_cls: remove unused macros from uapi
Date: Thu, 21 May 2015 02:26:24 +0200
Message-ID: <1432167984-3612-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33159 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751962AbbEUA0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal points out that this header also contains kernel internal magic that
cannot be used from userspace for anything meaningful.

Lets remove what the kernel doesn't use anymore and wrap remainder with
__KERNEL__.

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 iproute2 still compiles with the exported pkt_cls.h header.

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 39fb53d..4f0d1bc 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 #include <linux/pkt_sched.h>
 
+#ifdef __KERNEL__
 /* I think i could have done better macros ; for now this is stolen from
  * some arch/mips code - jhs
 */
@@ -35,23 +36,6 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
  *
  * */
 
-#ifndef __KERNEL__
-/* backwards compat for userspace only */
-#define TC_MUNGED          _TC_MAKEMASK1(0)
-#define SET_TC_MUNGED(v)   ( TC_MUNGED | (v & ~TC_MUNGED))
-#define CLR_TC_MUNGED(v)   ( v & ~TC_MUNGED)
-
-#define TC_OK2MUNGE        _TC_MAKEMASK1(1)
-#define SET_TC_OK2MUNGE(v)   ( TC_OK2MUNGE | (v & ~TC_OK2MUNGE))
-#define CLR_TC_OK2MUNGE(v)   ( v & ~TC_OK2MUNGE)
-
-#define S_TC_VERD          _TC_MAKE32(2)
-#define M_TC_VERD          _TC_MAKEMASK(4,S_TC_VERD)
-#define G_TC_VERD(x)       _TC_GETVALUE(x,S_TC_VERD,M_TC_VERD)
-#define V_TC_VERD(x)       _TC_MAKEVALUE(x,S_TC_VERD)
-#define SET_TC_VERD(v,n)   ((V_TC_VERD(n)) | (v & ~M_TC_VERD))
-#endif
-
 #define S_TC_FROM          _TC_MAKE32(6)
 #define M_TC_FROM          _TC_MAKEMASK(2,S_TC_FROM)
 #define G_TC_FROM(x)       _TC_GETVALUE(x,S_TC_FROM,M_TC_FROM)
@@ -65,20 +49,16 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
 #define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
 
-#ifndef __KERNEL__
-#define S_TC_RTTL          _TC_MAKE32(9)
-#define M_TC_RTTL          _TC_MAKEMASK(3,S_TC_RTTL)
-#define G_TC_RTTL(x)       _TC_GETVALUE(x,S_TC_RTTL,M_TC_RTTL)
-#define V_TC_RTTL(x)       _TC_MAKEVALUE(x,S_TC_RTTL)
-#define SET_TC_RTTL(v,n)   ((V_TC_RTTL(n)) | (v & ~M_TC_RTTL))
-#endif
-
 #define S_TC_AT          _TC_MAKE32(12)
 #define M_TC_AT          _TC_MAKEMASK(2,S_TC_AT)
 #define G_TC_AT(x)       _TC_GETVALUE(x,S_TC_AT,M_TC_AT)
 #define V_TC_AT(x)       _TC_MAKEVALUE(x,S_TC_AT)
 #define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
 
+#define MAX_REC_LOOP 4
+#define MAX_RED_LOOP 4
+#endif
+
 /* Action attributes */
 enum {
 	TCA_ACT_UNSPEC,
@@ -98,8 +78,6 @@ enum {
 #define TCA_ACT_NOUNBIND	0
 #define TCA_ACT_REPLACE		1
 #define TCA_ACT_NOREPLACE	0
-#define MAX_REC_LOOP 4
-#define MAX_RED_LOOP 4
 
 #define TC_ACT_UNSPEC	(-1)
 #define TC_ACT_OK		0
-- 
2.0.5
