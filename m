From: "David S. Miller" <davem@redhat.com>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Sat, 11 Oct 2003 12:40:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011124025.6cc2ada8.davem@redhat.com>
References: <20031010141646.779f10bb.rddunlap@osdl.org>
	<20031011120852.13fa8ec4.davem@redhat.com>
	<20031011194008.GA2395@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20031011194008.GA2395@mars.ravnborg.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Oct 2003 21:40:08 +0200
Sam Ravnborg <sam@ravnborg.org> wrote:

> Due to this - the real offender:
> 
> from: net/atm/clip.c:
> #ifdef CONFIG_PROC_FS
> #include <linux/proc_fs.h>
> #include <linux/seq_file.h>
> #endif

That makes a whole lot more sense, here is the fix I just
checked in:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1352  -> 1.1353 
#	      net/atm/clip.c	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/11	davem@nuts.ninka.net	1.1353
# [ATM]: Kill PROC_FS ifdef around includes.
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Sat Oct 11 12:43:12 2003
+++ b/net/atm/clip.c	Sat Oct 11 12:43:12 2003
@@ -24,10 +24,8 @@
 #include <linux/if.h> /* for IFF_UP */
 #include <linux/inetdevice.h>
 #include <linux/bitops.h>
-#ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#endif
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
