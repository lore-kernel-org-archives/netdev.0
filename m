From: Meelis Roos <mroos@linux.ee>
Subject: netem compile failure on PPC (2.4 BK)
Date: Mon, 19 Jul 2004 12:44:28 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0407191231410.14892-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netem fails to compile on PPC in 2.4.27+BK, __init etc are unknown. The
patch below fixes it for me.

gcc -D__KERNEL__ -I/home/mroos/compile/linux-2.4/include -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -fomit-frame-pointer -I/home/mroos/compile/linux-2.4/arch/ppc -fsigned-char -msoft-float -pipe -ffixed-r2 -Wno-uninitialized -mmultiple -mstring -DMODULE -DMODVERSIONS -include /home/mroos/compile/linux-2.4/include/linux/modversions.h  -nostdinc -iwithprefix include -DKBUILD_BASENAME=sch_netem  -c -o sch_netem.o sch_netem.c
sch_netem.c:245: error: parse error before "netem_module_init"
sch_netem.c:246: warning: return type defaults to `int'
sch_netem.c:249: error: parse error before "netem_module_exit"
sch_netem.c:250: warning: return type defaults to `int'
sch_netem.c:254: error: parse error before "module_exit"
sch_netem.c:255: warning: return type defaults to `int'
sch_netem.c:255: warning: function declaration isn't a prototype
sch_netem.c: In function `module_exit':
sch_netem.c:255: error: storage class specified for parameter `__module_license'
sch_netem.c:255: error: parameter `__module_license' is initialized
sch_netem.c:255: warning: `__used__' attribute ignored
sch_netem.c:255: error: section attribute not allowed for `__module_license'
sch_netem.c:255: error: parse error at end of input


===== net/sched/sch_netem.c 1.2 vs edited =====
--- 1.2/net/sched/sch_netem.c	2004-07-07 00:38:40 +03:00
+++ edited/net/sched/sch_netem.c	2004-07-19 12:32:27 +03:00
@@ -19,6 +19,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
+#include <linux/init.h>

 #include <net/pkt_sched.h>


-- 
Meelis Roos (mroos@linux.ee)
