From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Remove X86_TSC dependency in net profile code
Date: Wed, 3 Sep 2003 01:00:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902230057.GA5424@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This removes one of the remaining users of CONFIG_X86_TSC

Replace it with a runtime test instead. In some configurations it 
will be still properly optimized because cpu_has_tsc will expand
to a constant then.

This also makes it handle x86-64.

I did not actually compile test this because net profile is commented
out since a long time and doesn't compile. An alternative if noone comes
up to fix it would be just to remove it completely.

-Andi

--- linux-2.6.0test4/include/net/profile.h-o	2003-05-27 03:00:21.000000000 +0200
+++ linux-2.6.0test4/include/net/profile.h	2003-08-29 19:48:11.000000000 +0200
@@ -29,11 +29,14 @@
 extern struct timeval net_profile_adjust;
 extern void net_profile_irq_adjust(struct timeval *entered, struct timeval* leaved);
 
-#ifdef CONFIG_X86_TSC
+#ifdef CONFIG_X86
 
 static inline void  net_profile_stamp(struct timeval *pstamp)
 {
-	rdtsc(pstamp->tv_usec, pstamp->tv_sec);
+	if (cpu_has_tsc)
+		rdtsc(pstamp->tv_usec, pstamp->tv_sec);
+	else
+		do_gettimeofday(pstamp);
 }
 
 static inline void  net_profile_accumulate(struct timeval *entered,
