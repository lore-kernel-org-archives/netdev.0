From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 28/34] net/pktgen: replace
	interruptible_sleep_on_timeout() with wait_event_timeout()
Date: Tue, 25 Jan 2005 16:35:20 -0800
Message-ID: <20050126003520.GT12649@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============86048792617320546=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: robert.olsson@its.uu.se
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============86048792617320546==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Please consider applying.

Description: Use wait_event_timeout() instead of the deprecated
interruptible_sleep_on_timeout(). Current code does not check for signals, so
interruptible seems unnecessary. Patch is compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc2-kj-v/net/core/pktgen.c	2005-01-24 09:34:21.000000000 -0800
+++ 2.6.11-rc2-kj/net/core/pktgen.c	2005-01-24 17:18:52.000000000 -0800
@@ -135,6 +135,7 @@
 #include <linux/ipv6.h>
 #include <linux/udp.h>
 #include <linux/proc_fs.h>
+#include <linux/wait.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -3118,8 +3119,7 @@ static void __exit pg_cleanup(void)
                 struct pktgen_thread *t = pktgen_threads;
                 pktgen_threads->control |= (T_TERMINATE);
 
-                while( t == pktgen_threads) 
-                        interruptible_sleep_on_timeout(&queue, HZ);
+		wait_event_timeout(queue, (t != pktgen_threads), HZ);
         }
 
         /* Un-register us from receiving netdevice events */

--===============86048792617320546==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============86048792617320546==--
