From: domen@coderock.org
Subject: [patch 3/5] net/svcsock: replace schedule_timeout() with msleep()
Date: Sun, 06 Mar 2005 23:21:14 +0100
Message-ID: <20050306222115.2A8E21EC90@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Use msleep() instead of schedule_timeout() to guarantee the task
delays as expected. The code, as is, is not wrong; however I see two reasons to
use msleep(): 1) consistency across the kernel; and 2) milliseconds are far more
human-comprehensible than jiffies.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/sunrpc/svcsock.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN net/sunrpc/svcsock.c~msleep-net_sunrpc_svcsock net/sunrpc/svcsock.c
--- kj/net/sunrpc/svcsock.c~msleep-net_sunrpc_svcsock	2005-03-05 16:10:59.000000000 +0100
+++ kj-domen/net/sunrpc/svcsock.c	2005-03-05 16:10:59.000000000 +0100
@@ -31,6 +31,7 @@
 #include <linux/slab.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/delay.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -1167,8 +1168,7 @@ svc_recv(struct svc_serv *serv, struct s
 	while (rqstp->rq_arghi < pages) {
 		struct page *p = alloc_page(GFP_KERNEL);
 		if (!p) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ/2);
+			msleep(500);
 			continue;
 		}
 		rqstp->rq_argpages[rqstp->rq_arghi++] = p;
_
