From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] pktgen: sprintf arg type warning
Date: Fri, 8 Oct 2004 20:30:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008203027.643a2a97.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix sprintf arg type error (gcc 3.3.3), although it looks more like
a gcc problem than a kernel source code problem to me.
Doesn't matter on x86-32.  Fixes a warning on x86-64.

net/core/pktgen.c:607: warning: long long unsigned int format, long unsigned int arg (arg 4)

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>


diffstat:=
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./net/core/pktgen.c~pktgen_type ./net/core/pktgen.c
--- ./net/core/pktgen.c~pktgen_type	2004-10-06 15:04:06.260548504 -0700
+++ ./net/core/pktgen.c	2004-10-08 20:16:57.191340296 -0700
@@ -603,7 +603,7 @@ static void show_results(struct pktgen_i
 	do_div(idle, cpu_speed);
 
 	p += sprintf(p, "OK: %llu(c%llu+d%lu) usec, %llu (%dbyte,%dfrags)\n",
-		     total, total - idle, idle,
+		     total, total - (__u64)idle, idle,
 		     info->sofar, size, nr_frags);
 
 	pps = info->sofar * USEC_PER_SEC;


--
~Randy
