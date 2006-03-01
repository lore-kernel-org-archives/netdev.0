From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH] pktgen: Convert thread lock to mutexes.
Date: Wed, 1 Mar 2006 10:52:21 -0300
Message-ID: <20060301105221.1e0ff884@home.brethil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932116AbWCANvv@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Hi!

 pktgen's thread semaphores are strict mutexes, convert them to the mutex
implementation.

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

---

 net/core/pktgen.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

1185abd5dacbca3052ccd93e059c497bbc8869b2
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2221b86..2618a7b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -113,6 +113,7 @@
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/smp_lock.h>
+#include <linux/mutex.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
@@ -153,7 +154,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.65: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.66: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)
@@ -180,8 +181,8 @@
 #define T_REMDEV      (1<<4)	/* Remove one dev */
 
 /* Locks */
-#define   thread_lock()        down(&pktgen_sem)
-#define   thread_unlock()      up(&pktgen_sem)
+#define   thread_lock()        mutex_lock(&pktgen_mutex)
+#define   thread_unlock()      mutex_unlock(&pktgen_mutex)
 
 /* If lock -- can be removed after some work */
 #define   if_lock(t)           spin_lock(&(t->if_lock));
@@ -493,7 +494,7 @@ static int pg_delay_d;
 static int pg_clone_skb_d;
 static int debug;
 
-static DECLARE_MUTEX(pktgen_sem);
+static DEFINE_MUTEX(pktgen_mutex);
 static LIST_HEAD(pktgen_threads);
 
 static struct notifier_block pktgen_notifier_block = {
-- 
1.2.3.g8fcf1

-- 
Luiz Fernando N. Capitulino
