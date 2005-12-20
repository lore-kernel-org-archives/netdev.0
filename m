From: "Jaco Kroon" <jaco@kroon.co.za>
Subject: [KJ] [PATCH] Deinitialise static variables in net/core/pktgen.c
Date: Tue, 20 Dec 2005 09:59:23 +0200 (SAST)
Message-ID: <17299.192.96.150.57.1135065563.squirrel@mail.interexcel.co.za>
Reply-To: jaco@kroon.co.za
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@lists.osdl.org, lkml@vger.kernel.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

static variables should not be explicitly initialised to 0.  This causes
them to be placed in .data instead of .bss.  This patch de-initialises 3
static variables in net/core/pktgen.c.

There are approximately 800 more such variables in the source tree
(2.6.15rc5).  If there is more interrest I'd be willing to track down the
rest of these as well and de-initialise them as well.

--- linux-2.6.15-rc5.orig/net/core/pktgen.c     2005-12-14
10:15:12.000000000 +0200
+++ linux-2.6.15-rc5/net/core/pktgen.c  2005-12-20 09:50:28.000000000 +0200
@@ -487,9 +487,9 @@

 /* Module parameters, defaults. */
 static int pg_count_d = 1000; /* 1000 pkts by default */
-static int pg_delay_d = 0;
-static int pg_clone_skb_d = 0;
-static int debug = 0;
+static int pg_delay_d;
+static int pg_clone_skb_d;
+static int debug;

 static DECLARE_MUTEX(pktgen_sem);
 static struct pktgen_thread *pktgen_threads = NULL;

-- 
There are 10 kinds of people in the world, those who understand binary,
and those who don't.
