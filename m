From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 03/24] sysctl: cookie: pass ctl_header_cookie to proc_handler
Date: Sat,  2 Apr 2011 04:53:17 +0200
Message-ID: <2c7dffeffbbb6cc768816a904a1dde2d969a1c4e.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791Ab1DBCyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:15 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bulk of this patch changes all proc_handlers in the kernel to
receive the cookie.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/frv/kernel/pm.c               |   22 ++++----
 arch/frv/kernel/sysctl.c           |    4 +-
 arch/mips/lasat/sysctl.c           |   28 ++++++------
 arch/s390/appldata/appldata_base.c |   15 +++---
 arch/s390/kernel/debug.c           |    6 +-
 arch/s390/mm/cmm.c                 |    4 +-
 drivers/cdrom/cdrom.c              |   12 ++--
 drivers/char/random.c              |    6 +-
 drivers/macintosh/mac_hid.c        |    4 +-
 drivers/parport/procfs.c           |   29 +++++------
 drivers/s390/char/sclp_async.c     |    2 +-
 fs/dcache.c                        |    4 +-
 fs/drop_caches.c                   |    5 +-
 fs/file_table.c                    |   10 ++--
 fs/fscache/main.c                  |    6 +-
 fs/inode.c                         |    6 +-
 fs/pipe.c                          |    4 +-
 fs/proc/proc_sysctl.c              |    3 +-
 fs/quota/dquot.c                   |    5 +-
 fs/xfs/linux-2.6/xfs_sysctl.c      |   10 ++--
 include/linux/compaction.h         |    6 ++-
 include/linux/fs.h                 |   12 ++--
 include/linux/ftrace.h             |    4 +-
 include/linux/hugetlb.h            |   13 +++--
 include/linux/kprobes.h            |    6 +-
 include/linux/mm.h                 |    4 +-
 include/linux/mmzone.h             |   23 +++++----
 include/linux/nmi.h                |    4 +-
 include/linux/perf_event.h         |    2 +-
 include/linux/pipe_fs_i.h          |    2 +-
 include/linux/sched.h              |   16 +++---
 include/linux/security.h           |    3 +-
 include/linux/swap.h               |    4 +-
 include/linux/sysctl.h             |   30 ++++++++----
 include/linux/writeback.h          |   18 ++-----
 include/net/ndisc.h                |    7 ++-
 ipc/ipc_sysctl.c                   |   21 +++++----
 ipc/mq_sysctl.c                    |   11 ++--
 kernel/hung_task.c                 |    6 +-
 kernel/kprobes.c                   |    4 +-
 kernel/perf_event.c                |    4 +-
 kernel/sched.c                     |    4 +-
 kernel/sched_fair.c                |    4 +-
 kernel/sysctl.c                    |   91 +++++++++++++++++++++++------------
 kernel/trace/ftrace.c              |    4 +-
 kernel/trace/trace_stack.c         |    4 +-
 kernel/utsname_sysctl.c            |    6 +-
 kernel/watchdog.c                  |   11 ++--
 mm/compaction.c                    |    8 ++-
 mm/hugetlb.c                       |   24 +++++----
 mm/page-writeback.c                |   24 ++++------
 mm/page_alloc.c                    |   25 +++++-----
 mm/vmscan.c                        |    6 +-
 net/bridge/br_netfilter.c          |    6 +-
 net/core/sysctl_net_core.c         |    5 +-
 net/decnet/dn_dev.c                |   10 ++--
 net/decnet/sysctl_net_decnet.c     |    8 ++--
 net/ipv4/devinet.c                 |   18 ++++----
 net/ipv4/route.c                   |    6 +-
 net/ipv4/sysctl_net_ipv4.c         |   25 +++++-----
 net/ipv6/addrconf.c                |   12 ++--
 net/ipv6/ndisc.c                   |   14 +++--
 net/ipv6/route.c                   |    6 +-
 net/irda/irsysctl.c                |   12 ++--
 net/netfilter/ipvs/ip_vs_ctl.c     |   12 ++--
 net/netfilter/nf_log.c             |    5 +-
 net/phonet/sysctl.c                |    6 +-
 net/sunrpc/sysctl.c                |    9 ++--
 net/sunrpc/xprtrdma/svc_rdma.c     |    2 +-
 security/min_addr.c                |    5 +-
 70 files changed, 405 insertions(+), 352 deletions(-)

diff --git a/arch/frv/kernel/pm.c b/arch/frv/kernel/pm.c
index 5fa3889..a929ffb 100644
--- a/arch/frv/kernel/pm.c
+++ b/arch/frv/kernel/pm.c
@@ -150,8 +150,8 @@ static int user_atoi(char __user *ubuf, size_t len)
 /*
  * Send us to sleep.
  */
-static int sysctl_pm_do_suspend(ctl_table *ctl, int write,
-				void __user *buffer, size_t *lenp, loff_t *fpos)
+static int sysctl_pm_do_suspend(ctl_table *ctl, int write, void __user *buffer,
+				size_t *lenp, loff_t *fpos, void *cookie)
 {
 	int retval, mode;
 
@@ -198,13 +198,13 @@ static int try_set_cmode(int new_cmode)
 }
 
 
-static int cmode_procctl(ctl_table *ctl, int write,
-			 void __user *buffer, size_t *lenp, loff_t *fpos)
+static int cmode_procctl(ctl_table *ctl, int write, void __user *buffer,
+			 size_t *lenp, loff_t *fpos, void *cookie)
 {
 	int new_cmode;
 
 	if (!write)
-		return proc_dointvec(ctl, write, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos, NULL);
 
 	new_cmode = user_atoi(buffer, *lenp);
 
@@ -270,26 +270,26 @@ static int try_set_cm(int new_cm)
 	return 0;
 }
 
-static int p0_procctl(ctl_table *ctl, int write,
-		      void __user *buffer, size_t *lenp, loff_t *fpos)
+static int p0_procctl(ctl_table *ctl, int write, void __user *buffer,
+		      size_t *lenp, loff_t *fpos, void *cookie)
 {
 	int new_p0;
 
 	if (!write)
-		return proc_dointvec(ctl, write, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos, NULL);
 
 	new_p0 = user_atoi(buffer, *lenp);
 
 	return try_set_p0(new_p0)?:*lenp;
 }
 
-static int cm_procctl(ctl_table *ctl, int write,
-		      void __user *buffer, size_t *lenp, loff_t *fpos)
+static int cm_procctl(ctl_table *ctl, int write, void __user *buffer,
+		      size_t *lenp, loff_t *fpos, void *cookie)
 {
 	int new_cm;
 
 	if (!write)
-		return proc_dointvec(ctl, write, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos, NULL);
 
 	new_cm = user_atoi(buffer, *lenp);
 
diff --git a/arch/frv/kernel/sysctl.c b/arch/frv/kernel/sysctl.c
index 6c155d6..e2be463 100644
--- a/arch/frv/kernel/sysctl.c
+++ b/arch/frv/kernel/sysctl.c
@@ -48,7 +48,7 @@ static void frv_change_dcache_mode(unsigned long newmode)
  */
 static int procctl_frv_cachemode(ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp,
-				 loff_t *ppos)
+				 loff_t *ppos, void *cookie)
 {
 	unsigned long hsr0;
 	char buff[8];
@@ -123,7 +123,7 @@ static int procctl_frv_cachemode(ctl_table *table, int write,
 #ifdef CONFIG_MMU
 static int procctl_frv_pin_cxnr(ctl_table *table, int write,
 				void __user *buffer, size_t *lenp,
-				loff_t *ppos)
+				loff_t *ppos, void *cookie)
 {
 	pid_t pid;
 	char buff[16], *p;
diff --git a/arch/mips/lasat/sysctl.c b/arch/mips/lasat/sysctl.c
index d87ffd0..33f408c 100644
--- a/arch/mips/lasat/sysctl.c
+++ b/arch/mips/lasat/sysctl.c
@@ -39,12 +39,12 @@
 
 
 /* And the same for proc */
-int proc_dolasatstring(ctl_table *table, int write,
-		       void *buffer, size_t *lenp, loff_t *ppos)
+int proc_dolasatstring(ctl_table *table, int write, void *buffer,
+		       size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int r;
 
-	r = proc_dostring(table, write, buffer, lenp, ppos);
+	r = proc_dostring(table, write, buffer, lenp, ppos, NULL);
 	if ((!write) || r)
 		return r;
 
@@ -54,12 +54,12 @@ int proc_dolasatstring(ctl_table *table, int write,
 }
 
 /* proc function to write EEPROM after changing int entry */
-int proc_dolasatint(ctl_table *table, int write,
-		       void *buffer, size_t *lenp, loff_t *ppos)
+int proc_dolasatint(ctl_table *table, int write, void *buffer,
+		    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int r;
 
-	r = proc_dointvec(table, write, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if ((!write) || r)
 		return r;
 
@@ -72,8 +72,8 @@ int proc_dolasatint(ctl_table *table, int write,
 static int rtctmp;
 
 /* proc function to read/write RealTime Clock */
-int proc_dolasatrtc(ctl_table *table, int write,
-		       void *buffer, size_t *lenp, loff_t *ppos)
+int proc_dolasatrtc(ctl_table *table, int write, void *buffer,
+		    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct timespec ts;
 	int r;
@@ -85,7 +85,7 @@ int proc_dolasatrtc(ctl_table *table, int write,
 		if (rtctmp < 0)
 			rtctmp = 0;
 	}
-	r = proc_dointvec(table, write, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (r)
 		return r;
 
@@ -97,8 +97,8 @@ int proc_dolasatrtc(ctl_table *table, int write,
 #endif
 
 #ifdef CONFIG_INET
-int proc_lasat_ip(ctl_table *table, int write,
-		       void *buffer, size_t *lenp, loff_t *ppos)
+int proc_lasat_ip(ctl_table *table, int write, void *buffer,
+		    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	unsigned int ip;
 	char *p, c;
@@ -157,12 +157,12 @@ int proc_lasat_ip(ctl_table *table, int write,
 }
 #endif
 
-int proc_lasat_prid(ctl_table *table, int write,
-		       void *buffer, size_t *lenp, loff_t *ppos)
+int proc_lasat_prid(ctl_table *table, int write, void *buffer,
+		    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int r;
 
-	r = proc_dointvec(table, write, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (r < 0)
 		return r;
 	if (write) {
diff --git a/arch/s390/appldata/appldata_base.c b/arch/s390/appldata/appldata_base.c
index 5c91995..866d8c0 100644
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -51,10 +51,11 @@ static struct platform_device *appldata_pdev;
  */
 static const char appldata_proc_name[APPLDATA_PROC_NAME_LENGTH] = "appldata";
 static int appldata_timer_handler(ctl_table *ctl, int write,
-				  void __user *buffer, size_t *lenp, loff_t *ppos);
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos, void *cookie);
 static int appldata_interval_handler(ctl_table *ctl, int write,
-					 void __user *buffer,
-					 size_t *lenp, loff_t *ppos);
+				     void __user *buffer, size_t *lenp,
+				     loff_t *ppos, void *cookie);
 
 static struct ctl_table_header *appldata_sysctl_header;
 static struct ctl_table appldata_table[] = {
@@ -246,8 +247,8 @@ __appldata_vtimer_setup(int cmd)
  * Start/Stop timer, show status of timer (0 = not active, 1 = active)
  */
 static int
-appldata_timer_handler(ctl_table *ctl, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+appldata_timer_handler(ctl_table *ctl, int write, void __user *buffer,
+		       size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int len;
 	char buf[2];
@@ -334,8 +335,8 @@ out:
  * monitoring (0 = not in process, 1 = in process)
  */
 static int
-appldata_generic_handler(ctl_table *ctl, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+appldata_generic_handler(ctl_table *ctl, int write, void __user *buffer,
+			 size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct appldata_ops *ops = NULL, *tmp_ops;
 	int rc, len, found;
diff --git a/arch/s390/kernel/debug.c b/arch/s390/kernel/debug.c
index 5ad6bc0..bcd28c3 100644
--- a/arch/s390/kernel/debug.c
+++ b/arch/s390/kernel/debug.c
@@ -884,11 +884,11 @@ static int debug_active=1;
  * if debug_active is already off
  */
 static int
-s390dbf_procactive(ctl_table *table, int write,
-                     void __user *buffer, size_t *lenp, loff_t *ppos)
+s390dbf_procactive(ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos, void *cookie)
 {
 	if (!write || debug_stoppable || !debug_active)
-		return proc_dointvec(table, write, buffer, lenp, ppos);
+		return proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	else
 		return 0;
 }
diff --git a/arch/s390/mm/cmm.c b/arch/s390/mm/cmm.c
index c66ffd8..1fe48f7 100644
--- a/arch/s390/mm/cmm.c
+++ b/arch/s390/mm/cmm.c
@@ -254,7 +254,7 @@ static int cmm_skip_blanks(char *cp, char **endp)
 static struct ctl_table cmm_table[];
 
 static int cmm_pages_handler(ctl_table *ctl, int write, void __user *buffer,
-			     size_t *lenp, loff_t *ppos)
+			     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	char buf[16], *p;
 	long nr;
@@ -294,7 +294,7 @@ static int cmm_pages_handler(ctl_table *ctl, int write, void __user *buffer,
 }
 
 static int cmm_timeout_handler(ctl_table *ctl, int write,  void __user *buffer,
-			       size_t *lenp, loff_t *ppos)
+			       size_t *lenp, loff_t *ppos, void *cookie)
 {
 	char buf[64], *p;
 	long nr, seconds;
diff --git a/drivers/cdrom/cdrom.c b/drivers/cdrom/cdrom.c
index e2c48a7..2c3d2d5 100644
--- a/drivers/cdrom/cdrom.c
+++ b/drivers/cdrom/cdrom.c
@@ -3469,8 +3469,8 @@ static int cdrom_print_info(const char *header, int val, char *info,
 	return 0;
 }
 
-static int cdrom_sysctl_info(ctl_table *ctl, int write,
-                           void __user *buffer, size_t *lenp, loff_t *ppos)
+static int cdrom_sysctl_info(ctl_table *ctl, int write, void __user *buffer,
+			     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int pos;
 	char *info = cdrom_sysctl_settings.info;
@@ -3546,7 +3546,7 @@ static int cdrom_sysctl_info(ctl_table *ctl, int write,
 		goto done;
 doit:
 	mutex_unlock(&cdrom_mutex);
-	return proc_dostring(ctl, write, buffer, lenp, ppos);
+	return proc_dostring(ctl, write, buffer, lenp, ppos, NULL);
 done:
 	pr_info("info buffer too small\n");
 	goto doit;
@@ -3582,12 +3582,12 @@ static void cdrom_update_settings(void)
 	mutex_unlock(&cdrom_mutex);
 }
 
-static int cdrom_sysctl_handler(ctl_table *ctl, int write,
-				void __user *buffer, size_t *lenp, loff_t *ppos)
+static int cdrom_sysctl_handler(ctl_table *ctl, int write, void __user *buffer,
+				size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int ret;
 	
-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write) {
 	
diff --git a/drivers/char/random.c b/drivers/char/random.c
index 5e29e80..2e54a13 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1227,8 +1227,8 @@ static char sysctl_bootid[16];
  * as an ASCII string in the standard UUID format.  If accesses via the
  * sysctl system call, it is returned as 16 bytes of binary data.
  */
-static int proc_do_uuid(ctl_table *table, int write,
-			void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_do_uuid(ctl_table *table, int write, void __user *buffer,
+			size_t *lenp, loff_t *ppos, void *cookie)
 {
 	ctl_table fake_table;
 	unsigned char buf[64], tmp_uuid[16], *uuid;
@@ -1246,7 +1246,7 @@ static int proc_do_uuid(ctl_table *table, int write,
 	fake_table.data = buf;
 	fake_table.maxlen = sizeof(buf);
 
-	return proc_dostring(&fake_table, write, buffer, lenp, ppos);
+	return proc_dostring(&fake_table, write, buffer, lenp, ppos, NULL);
 }
 
 static int sysctl_poolsize = INPUT_POOL_WORDS * 32;
diff --git a/drivers/macintosh/mac_hid.c b/drivers/macintosh/mac_hid.c
index 6a82388..76ff0f7 100644
--- a/drivers/macintosh/mac_hid.c
+++ b/drivers/macintosh/mac_hid.c
@@ -183,7 +183,7 @@ static void mac_hid_stop_emulation(void)
 
 static int mac_hid_toggle_emumouse(ctl_table *table, int write,
 				   void __user *buffer, size_t *lenp,
-				   loff_t *ppos)
+				   loff_t *ppos, void *cookie)
 {
 	int *valp = table->data;
 	int old_val = *valp;
@@ -193,7 +193,7 @@ static int mac_hid_toggle_emumouse(ctl_table *table, int write,
 	if (rc)
 		return rc;
 
-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	rc = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if (rc == 0 && write && *valp != old_val) {
 		if (*valp == 1)
diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 3f56bc0..fc4aa33 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -31,8 +31,8 @@
 #define PARPORT_MIN_SPINTIME_VALUE 1
 #define PARPORT_MAX_SPINTIME_VALUE 1000
 
-static int do_active_device(ctl_table *table, int write,
-		      void __user *result, size_t *lenp, loff_t *ppos)
+static int do_active_device(ctl_table *table, int write, void __user *result,
+			    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct parport *port = (struct parport *)table->extra1;
 	char buffer[256];
@@ -68,8 +68,8 @@ static int do_active_device(ctl_table *table, int write,
 }
 
 #ifdef CONFIG_PARPORT_1284
-static int do_autoprobe(ctl_table *table, int write,
-			void __user *result, size_t *lenp, loff_t *ppos)
+static int do_autoprobe(ctl_table *table, int write, void __user *result,
+			size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct parport_device_info *info = table->extra2;
 	const char *str;
@@ -110,9 +110,9 @@ static int do_autoprobe(ctl_table *table, int write,
 }
 #endif /* IEEE1284.3 support. */
 
-static int do_hardware_base_addr (ctl_table *table, int write,
-				  void __user *result,
-				  size_t *lenp, loff_t *ppos)
+static int do_hardware_base_addr(ctl_table *table, int write,
+				 void __user *result, size_t *lenp,
+				 loff_t *ppos, void *cookie)
 {
 	struct parport *port = (struct parport *)table->extra1;
 	char buffer[20];
@@ -138,9 +138,8 @@ static int do_hardware_base_addr (ctl_table *table, int write,
 	return copy_to_user(result, buffer, len) ? -EFAULT : 0;
 }
 
-static int do_hardware_irq (ctl_table *table, int write,
-			    void __user *result,
-			    size_t *lenp, loff_t *ppos)
+static int do_hardware_irq(ctl_table *table, int write, void __user *result,
+			   size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct parport *port = (struct parport *)table->extra1;
 	char buffer[20];
@@ -166,9 +165,8 @@ static int do_hardware_irq (ctl_table *table, int write,
 	return copy_to_user(result, buffer, len) ? -EFAULT : 0;
 }
 
-static int do_hardware_dma (ctl_table *table, int write,
-			    void __user *result,
-			    size_t *lenp, loff_t *ppos)
+static int do_hardware_dma(ctl_table *table, int write, void __user *result,
+			   size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct parport *port = (struct parport *)table->extra1;
 	char buffer[20];
@@ -194,9 +192,8 @@ static int do_hardware_dma (ctl_table *table, int write,
 	return copy_to_user(result, buffer, len) ? -EFAULT : 0;
 }
 
-static int do_hardware_modes (ctl_table *table, int write,
-			      void __user *result,
-			      size_t *lenp, loff_t *ppos)
+static int do_hardware_modes(ctl_table *table, int write, void __user *result,
+			     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct parport *port = (struct parport *)table->extra1;
 	char buffer[40];
diff --git a/drivers/s390/char/sclp_async.c b/drivers/s390/char/sclp_async.c
index 7ad30e7..c4da7ea 100644
--- a/drivers/s390/char/sclp_async.c
+++ b/drivers/s390/char/sclp_async.c
@@ -65,7 +65,7 @@ static struct notifier_block call_home_panic_nb = {
 
 static int proc_handler_callhome(struct ctl_table *ctl, int write,
 				 void __user *buffer, size_t *count,
-				 loff_t *ppos)
+				 loff_t *ppos, void *cookie)
 {
 	unsigned long val;
 	int len, rc;
diff --git a/fs/dcache.c b/fs/dcache.c
index ad25c4c..38b78c4 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -140,10 +140,10 @@ static int get_nr_dentry(void)
 }
 
 int proc_nr_dentry(ctl_table *table, int write, void __user *buffer,
-		   size_t *lenp, loff_t *ppos)
+		   size_t *lenp, loff_t *ppos, void *cookie)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 }
 #endif
 
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 98b77c8..78f1ce4 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -47,11 +47,12 @@ static void drop_slab(void)
 }
 
 int drop_caches_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+			       void __user *buffer, size_t *length,
+			       loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (ret)
 		return ret;
 	if (write) {
diff --git a/fs/file_table.c b/fs/file_table.c
index 01e4c1e..d18b9d9 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -78,15 +78,15 @@ EXPORT_SYMBOL_GPL(get_max_files);
  * Handle nr_files sysctl
  */
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
-int proc_nr_files(ctl_table *table, int write,
-                     void __user *buffer, size_t *lenp, loff_t *ppos)
+int proc_nr_files(ctl_table *table, int write, void __user *buffer,
+		  size_t *lenp, loff_t *ppos, void *cookie)
 {
 	files_stat.nr_files = get_nr_files();
-	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos, NULL);
 }
 #else
-int proc_nr_files(ctl_table *table, int write,
-                     void __user *buffer, size_t *lenp, loff_t *ppos)
+int proc_nr_files(ctl_table *table, int write, void __user *buffer,
+		  size_t *lenp, loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index f9d8567..00415f6 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -54,14 +54,14 @@ static unsigned fscache_op_max_active = 2;
 static struct ctl_table_header *fscache_sysctl_header;
 
 static int fscache_max_active_sysctl(struct ctl_table *table, int write,
-				     void __user *buffer,
-				     size_t *lenp, loff_t *ppos)
+				     void __user *buffer, size_t *lenp,
+				     loff_t *ppos, void *cookie)
 {
 	struct workqueue_struct **wqp = table->extra1;
 	unsigned int *datap = table->data;
 	int ret;
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0)
 		workqueue_set_max_active(*wqp, *datap);
 	return ret;
diff --git a/fs/inode.c b/fs/inode.c
index 5f4e11a..ec96079 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -158,11 +158,11 @@ int get_nr_dirty_inodes(void)
  * Handle nr_inode sysctl
  */
 #ifdef CONFIG_SYSCTL
-int proc_nr_inodes(ctl_table *table, int write,
-		   void __user *buffer, size_t *lenp, loff_t *ppos)
+int proc_nr_inodes(ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos, void *cookie)
 {
 	inodes_stat.nr_inodes = get_nr_inodes();
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 }
 #endif
 
diff --git a/fs/pipe.c b/fs/pipe.c
index da42f7d..c37413bd 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1186,11 +1186,11 @@ static inline unsigned int round_pipe_size(unsigned int size)
  * will return an error.
  */
 int pipe_proc_fn(struct ctl_table *table, int write, void __user *buf,
-		 size_t *lenp, loff_t *ppos)
+		 size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buf, lenp, ppos);
+	ret = proc_dointvec_minmax(table, write, buf, lenp, ppos, NULL);
 	if (ret < 0 || !write)
 		return ret;
 
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f50133c..f1e91e7 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -155,7 +155,8 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 
 	/* careful: calling conventions are nasty here */
 	res = count;
-	error = table->proc_handler(table, write, buf, &res, ppos);
+	error = table->proc_handler(table, write, buf, &res,
+				    ppos, head->ctl_header_cookie);
 	if (!error)
 		error = res;
 out:
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index fcc8ae7..894ed7b 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -2517,14 +2517,15 @@ const struct quotactl_ops dquot_quotactl_ops = {
 EXPORT_SYMBOL(dquot_quotactl_ops);
 
 static int do_proc_dqstats(struct ctl_table *table, int write,
-		     void __user *buffer, size_t *lenp, loff_t *ppos)
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie)
 {
 	unsigned int type = (int *)table->data - dqstats.stat;
 
 	/* Update global table */
 	dqstats.stat[type] =
 			percpu_counter_sum_positive(&dqstats.counter[type]);
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 }
 
 static ctl_table fs_dqstats_table[] = {
diff --git a/fs/xfs/linux-2.6/xfs_sysctl.c b/fs/xfs/linux-2.6/xfs_sysctl.c
index ee2d2ad..1d2a781 100644
--- a/fs/xfs/linux-2.6/xfs_sysctl.c
+++ b/fs/xfs/linux-2.6/xfs_sysctl.c
@@ -29,12 +29,13 @@ xfs_stats_clear_proc_handler(
 	int		write,
 	void		__user *buffer,
 	size_t		*lenp,
-	loff_t		*ppos)
+	loff_t		*ppos,
+	void		*cookie)
 {
 	int		c, ret, *valp = ctl->data;
 	__uint32_t	vn_active;
 
-	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (!ret && write && *valp) {
 		xfs_notice(NULL, "Clearing xfsstats");
@@ -59,11 +60,12 @@ xfs_panic_mask_proc_handler(
 	int		write,
 	void		__user *buffer,
 	size_t		*lenp,
-	loff_t		*ppos)
+	loff_t		*ppos,
+	void		*cookie)
 {
 	int		ret, *valp = ctl->data;
 
-	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos, NULL);
 	if (!ret && write) {
 		xfs_panic_mask = *valp;
 #ifdef DEBUG
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index cc9f7a4..aa898e5 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -14,10 +14,12 @@
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos);
+				     void __user *buffer, size_t *length,
+				     loff_t *ppos, void *cookie);
 extern int sysctl_extfrag_threshold;
 extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos);
+				  void __user *buffer, size_t *length,
+				  loff_t *ppos, void *cookie);
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 52f283c..1096299 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2562,12 +2562,12 @@ ssize_t simple_attr_write(struct file *file, const char __user *buf,
 			  size_t len, loff_t *ppos);
 
 struct ctl_table;
-int proc_nr_files(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos);
-int proc_nr_dentry(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos);
-int proc_nr_inodes(struct ctl_table *table, int write,
-		   void __user *buffer, size_t *lenp, loff_t *ppos);
+int proc_nr_files(struct ctl_table *table, int write, void __user *buffer,
+		  size_t *lenp, loff_t *ppos, void *cookie);
+int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos, void *cookie);
+int proc_nr_inodes(struct ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos, void *cookie);
 int __init get_filesystem_list(char *buf);
 
 #define __FMODE_EXEC		((__force int) FMODE_EXEC)
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index ca29e03..6e3a3d9 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -25,7 +25,7 @@ extern int ftrace_enabled;
 extern int
 ftrace_enable_sysctl(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp,
-		     loff_t *ppos);
+		     loff_t *ppos, void *cookie);
 
 typedef void (*ftrace_func_t)(unsigned long ip, unsigned long parent_ip);
 
@@ -104,7 +104,7 @@ extern int stack_tracer_enabled;
 int
 stack_trace_sysctl(struct ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp,
-		   loff_t *ppos);
+		   loff_t *ppos, void *cookie);
 #endif
 
 struct ftrace_func_command {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 943c76b..4bb40ca 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -16,13 +16,16 @@ struct user_struct;
 int PageHuge(struct page *page);
 
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
-int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
-int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
-int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *,
+			   size_t *, loff_t *, void *);
+int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *,
+			       size_t *, loff_t *, void *);
+int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *,
+				  size_t *, loff_t *, void *);
 
 #ifdef CONFIG_NUMA
-int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int, void __user *,
+				     size_t *, loff_t *, void *);
 #endif
 
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index dd7c12e..f5c5357 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -288,9 +288,9 @@ extern void opt_pre_handler(struct kprobe *p, struct pt_regs *regs);
 
 #ifdef CONFIG_SYSCTL
 extern int sysctl_kprobes_optimization;
-extern int proc_kprobes_optimization_handler(struct ctl_table *table,
-					     int write, void __user *buffer,
-					     size_t *length, loff_t *ppos);
+extern int proc_kprobes_optimization_handler(struct ctl_table *table, int write,
+					     void __user *buffer, size_t *len,
+					     loff_t *ppos, void *cookie);
 #endif
 
 #endif /* CONFIG_OPTPROBES */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7606d7d..b0793e5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1602,8 +1602,8 @@ int in_gate_area_no_mm(unsigned long addr);
 #define in_gate_area(mm, addr) ({(void)mm; in_gate_area_no_mm(addr);})
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-int drop_caches_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+int drop_caches_sysctl_handler(struct ctl_table *, int, void __user *,
+			       size_t *, loff_t *, void *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			unsigned long lru_pages);
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e56f835..7592afd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -764,20 +764,21 @@ static inline int is_dma(struct zone *zone)
 
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
-int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+int min_free_kbytes_sysctl_handler(struct ctl_table *, int, void __user *,
+				   size_t *, loff_t *, void *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
-int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, void __user *,
+					size_t *, loff_t *, void *);
 int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+					    void __user *, size_t *,
+					    loff_t *, void *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
-			void __user *, size_t *, loff_t *);
-int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
-			void __user *, size_t *, loff_t *);
-
-extern int numa_zonelist_order_handler(struct ctl_table *, int,
-			void __user *, size_t *, loff_t *);
+					     void __user *, size_t *,
+					     loff_t *, void *);
+int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int, void __user *,
+					 size_t *, loff_t *, void *);
+int numa_zonelist_order_handler(struct ctl_table *, int, void __user *,
+				size_t *, loff_t *, void *);
 extern char numa_zonelist_order[];
 #define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
 
diff --git a/include/linux/nmi.h b/include/linux/nmi.h
index c536f85..96eb9c7 100644
--- a/include/linux/nmi.h
+++ b/include/linux/nmi.h
@@ -48,8 +48,8 @@ int hw_nmi_is_cpu_stuck(struct pt_regs *);
 u64 hw_nmi_get_sample_period(void);
 extern int watchdog_enabled;
 struct ctl_table;
-extern int proc_dowatchdog_enabled(struct ctl_table *, int ,
-			void __user *, size_t *, loff_t *);
+extern int proc_dowatchdog_enabled(struct ctl_table *, int, void __user *,
+				   size_t *, loff_t *, void *);
 #endif
 
 #endif
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 311b4dc..840c93b 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -1119,7 +1119,7 @@ extern int sysctl_perf_event_sample_rate;
 
 extern int perf_proc_update_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+		loff_t *ppos, void *cookie);
 
 static inline bool perf_paranoid_tracepoint_raw(void)
 {
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index 77257c9..b79fc92 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -141,7 +141,7 @@ void pipe_unlock(struct pipe_inode_info *);
 void pipe_double_lock(struct pipe_inode_info *, struct pipe_inode_info *);
 
 extern unsigned int pipe_max_size, pipe_min_size;
-int pipe_proc_fn(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int pipe_proc_fn(struct ctl_table *, int, void __user *, size_t *, loff_t *, void *);
 
 
 /* Drop the inode semaphore and wait for a pipe event, atomically */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 83bd2e2..0f7ee29 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -312,8 +312,8 @@ extern void touch_softlockup_watchdog(void);
 extern void touch_softlockup_watchdog_sync(void);
 extern void touch_all_softlockup_watchdogs(void);
 extern int proc_dowatchdog_thresh(struct ctl_table *table, int write,
-				  void __user *buffer,
-				  size_t *lenp, loff_t *ppos);
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos, void *cookie);
 extern unsigned int  softlockup_panic;
 extern int softlockup_thresh;
 void lockup_detector_init(void);
@@ -338,8 +338,8 @@ extern unsigned long sysctl_hung_task_check_count;
 extern unsigned long sysctl_hung_task_timeout_secs;
 extern unsigned long sysctl_hung_task_warnings;
 extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-					 void __user *buffer,
-					 size_t *lenp, loff_t *ppos);
+					 void __user *buffer, size_t *lenp,
+					 loff_t *ppos, void *cookie);
 #else
 /* Avoid need for ifdefs elsewhere in the code */
 enum { sysctl_hung_task_timeout_secs = 0 };
@@ -1929,8 +1929,8 @@ extern unsigned int sysctl_timer_migration;
 extern unsigned int sysctl_sched_shares_window;
 
 int sched_proc_update_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *length,
-		loff_t *ppos);
+			      void __user *buffer, size_t *length,
+			      loff_t *ppos, void *cookie);
 #endif
 #ifdef CONFIG_SCHED_DEBUG
 static inline unsigned int get_sysctl_timer_migration(void)
@@ -1947,8 +1947,8 @@ extern unsigned int sysctl_sched_rt_period;
 extern int sysctl_sched_rt_runtime;
 
 int sched_rt_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+		     void __user *buffer, size_t *lenp,
+		     loff_t *ppos, void *cookie);
 
 #ifdef CONFIG_SCHED_AUTOGROUP
 extern unsigned int sysctl_sched_autogroup_enabled;
diff --git a/include/linux/security.h b/include/linux/security.h
index ca02f17..cc2e816 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -144,7 +144,8 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 	return hint;
 }
 extern int mmap_min_addr_handler(struct ctl_table *table, int write,
-				 void __user *buffer, size_t *lenp, loff_t *ppos);
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, void *cookie);
 #endif
 
 #ifdef CONFIG_SECURITY
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a5c6da5..921b3b4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -281,8 +281,8 @@ extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
 
 extern unsigned long scan_unevictable_pages;
-extern int scan_unevictable_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+extern int scan_unevictable_handler(struct ctl_table *, int, void __user *,
+				    size_t *, loff_t *, void *);
 #ifdef CONFIG_NUMA
 extern int scan_unevictable_register_node(struct node *node);
 extern void scan_unevictable_unregister_node(struct node *node);
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index f82d456..f0eb817 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -963,26 +963,36 @@ extern int sysctl_perm(struct ctl_table_root *root,
 typedef struct ctl_table ctl_table;
 
 typedef int proc_handler (struct ctl_table *ctl, int write,
-			  void __user *buffer, size_t *lenp, loff_t *ppos);
+			  void __user *buffer, size_t *lenp,
+			  loff_t *ppos, void *cookie);
 
 extern int proc_dostring(struct ctl_table *, int,
-			 void __user *, size_t *, loff_t *);
+			 void __user *, size_t *,
+			 loff_t *, void *);
 extern int proc_dointvec(struct ctl_table *, int,
-			 void __user *, size_t *, loff_t *);
+			 void __user *, size_t *,
+			 loff_t *, void *);
 extern int proc_dointvec_minmax(struct ctl_table *, int,
-				void __user *, size_t *, loff_t *);
+				void __user *, size_t *,
+				loff_t *, void *);
 extern int proc_dointvec_jiffies(struct ctl_table *, int,
-				 void __user *, size_t *, loff_t *);
+				 void __user *, size_t *,
+				 loff_t *, void *);
 extern int proc_dointvec_userhz_jiffies(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
+					void __user *, size_t *,
+					loff_t *, void *);
 extern int proc_dointvec_ms_jiffies(struct ctl_table *, int,
-				    void __user *, size_t *, loff_t *);
+				    void __user *, size_t *,
+				    loff_t *, void *);
 extern int proc_doulongvec_minmax(struct ctl_table *, int,
-				  void __user *, size_t *, loff_t *);
+				  void __user *, size_t *,
+				  loff_t *, void *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
-				      void __user *, size_t *, loff_t *);
+					     void __user *, size_t *,
+					     loff_t *, void *);
 extern int proc_do_large_bitmap(struct ctl_table *, int,
-				void __user *, size_t *, loff_t *);
+				void __user *, size_t *,
+				loff_t *, void *);
 
 /*
  * Register a set of sysctl names by calling register_sysctl_table
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 17e7ccc..6bd24aa 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -108,21 +108,15 @@ extern int laptop_mode;
 extern unsigned long determine_dirtyable_memory(void);
 
 extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie);
 extern int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie);
 extern int dirty_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie);
 extern int dirty_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
-
-struct ctl_table;
-int dirty_writeback_centisecs_handler(struct ctl_table *, int,
-				      void __user *, size_t *, loff_t *);
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie);
+extern int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie);
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index e0e594f..35837cd 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -137,10 +137,13 @@ extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
 							   int write,
 							   void __user *buffer,
 							   size_t *lenp,
-							   loff_t *ppos);
+							   loff_t *ppos,
+							   void *cookie);
+
 int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl,
 				 void __user *oldval, size_t __user *oldlenp,
-				 void __user *newval, size_t newlen);
+				 void __user *newval, size_t newlen,
+				 void *cookie);
 #endif
 
 extern void 			inet6_ifinfo_notify(int event,
diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index 56410fa..f44cb1a 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -27,18 +27,19 @@ static void *get_ipc(ctl_table *table)
 }
 
 #ifdef CONFIG_PROC_SYSCTL
-static int proc_ipc_dointvec(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_ipc_dointvec(ctl_table *table, int write, void __user *buffer,
+			     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct ctl_table ipc_table;
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
-	return proc_dointvec(&ipc_table, write, buffer, lenp, ppos);
+	return proc_dointvec(&ipc_table, write, buffer, lenp, ppos, NULL);
 }
 
 static int proc_ipc_callback_dointvec(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+				      void __user *buffer, size_t *lenp,
+				      loff_t *ppos, void *cookie)
 {
 	struct ctl_table ipc_table;
 	size_t lenp_bef = *lenp;
@@ -47,7 +48,7 @@ static int proc_ipc_callback_dointvec(ctl_table *table, int write,
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
-	rc = proc_dointvec(&ipc_table, write, buffer, lenp, ppos);
+	rc = proc_dointvec(&ipc_table, write, buffer, lenp, ppos, NULL);
 
 	if (write && !rc && lenp_bef == *lenp)
 		/*
@@ -61,14 +62,15 @@ static int proc_ipc_callback_dointvec(ctl_table *table, int write,
 }
 
 static int proc_ipc_doulongvec_minmax(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+				      void __user *buffer, size_t *lenp,
+				      loff_t *ppos, void *cookie)
 {
 	struct ctl_table ipc_table;
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
 	return proc_doulongvec_minmax(&ipc_table, write, buffer,
-					lenp, ppos);
+				      lenp, ppos, NULL);
 }
 
 /*
@@ -95,7 +97,8 @@ static void ipc_auto_callback(int val)
 }
 
 static int proc_ipcauto_dointvec_minmax(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+					void __user *buffer, size_t *lenp,
+					loff_t *ppos, void *cookie)
 {
 	struct ctl_table ipc_table;
 	size_t lenp_bef = *lenp;
@@ -106,7 +109,7 @@ static int proc_ipcauto_dointvec_minmax(ctl_table *table, int write,
 	ipc_table.data = get_ipc(table);
 	oldval = *((int *)(ipc_table.data));
 
-	rc = proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos);
+	rc = proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos, NULL);
 
 	if (write && !rc && lenp_bef == *lenp) {
 		int newval = *((int *)(ipc_table.data));
diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
index 0c09366..384af7d 100644
--- a/ipc/mq_sysctl.c
+++ b/ipc/mq_sysctl.c
@@ -31,25 +31,26 @@ static void *get_mq(ctl_table *table)
 	return which;
 }
 
-static int proc_mq_dointvec(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_mq_dointvec(ctl_table *table, int write, void __user *buffer,
+			    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct ctl_table mq_table;
 	memcpy(&mq_table, table, sizeof(mq_table));
 	mq_table.data = get_mq(table);
 
-	return proc_dointvec(&mq_table, write, buffer, lenp, ppos);
+	return proc_dointvec(&mq_table, write, buffer, lenp, ppos, NULL);
 }
 
 static int proc_mq_dointvec_minmax(ctl_table *table, int write,
-	void __user *buffer, size_t *lenp, loff_t *ppos)
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos, void *cookie)
 {
 	struct ctl_table mq_table;
 	memcpy(&mq_table, table, sizeof(mq_table));
 	mq_table.data = get_mq(table);
 
 	return proc_dointvec_minmax(&mq_table, write, buffer,
-					lenp, ppos);
+				    lenp, ppos, NULL);
 }
 #else
 #define proc_mq_dointvec NULL
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 53ead17..edae933 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -171,12 +171,12 @@ static unsigned long timeout_jiffies(unsigned long timeout)
  * Process updating of timeout sysctl
  */
 int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-				  void __user *buffer,
-				  size_t *lenp, loff_t *ppos)
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos, NULL);
 
 	if (ret || !write)
 		goto out;
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 7798181..8fce3c7 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -826,13 +826,13 @@ static void __kprobes unoptimize_all_kprobes(void)
 int sysctl_kprobes_optimization;
 int proc_kprobes_optimization_handler(struct ctl_table *table, int write,
 				      void __user *buffer, size_t *length,
-				      loff_t *ppos)
+				      loff_t *ppos, void *cookie)
 {
 	int ret;
 
 	mutex_lock(&kprobe_mutex);
 	sysctl_kprobes_optimization = kprobes_allow_optimization ? 1 : 0;
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 
 	if (sysctl_kprobes_optimization)
 		optimize_all_kprobes();
diff --git a/kernel/perf_event.c b/kernel/perf_event.c
index c75925c..fc00e0e 100644
--- a/kernel/perf_event.c
+++ b/kernel/perf_event.c
@@ -158,9 +158,9 @@ static int max_samples_per_tick __read_mostly =
 
 int perf_proc_update_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		loff_t *ppos, void *cookie)
 {
-	int ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	int ret = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if (ret || !write)
 		return ret;
diff --git a/kernel/sched.c b/kernel/sched.c
index f592ce6..c787ddf 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -8982,7 +8982,7 @@ static int sched_rt_global_constraints(void)
 
 int sched_rt_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		loff_t *ppos, void *cookie)
 {
 	int ret;
 	int old_period, old_runtime;
@@ -8992,7 +8992,7 @@ int sched_rt_handler(struct ctl_table *table, int write,
 	old_period = sysctl_sched_rt_period;
 	old_runtime = sysctl_sched_rt_runtime;
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if (!ret && write) {
 		ret = sched_rt_global_constraints();
diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
index 3f7ec9e..28ee577 100644
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -448,9 +448,9 @@ static struct sched_entity *__pick_last_entity(struct cfs_rq *cfs_rq)
 
 int sched_proc_update_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		loff_t *ppos, void *cookie)
 {
-	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos, NULL);
 	int factor = get_update_sysctl_factor();
 
 	if (ret || !write)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dd3d061..cd7340d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -165,14 +165,17 @@ extern int unaligned_dump_stack;
 
 #ifdef CONFIG_PROC_SYSCTL
 static int proc_do_cad_pid(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos);
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie);
 static int proc_taint(struct ctl_table *table, int write,
-			       void __user *buffer, size_t *lenp, loff_t *ppos);
+		      void __user *buffer, size_t *lenp,
+		      loff_t *ppos, void *cookie);
 #endif
 
 #ifdef CONFIG_PRINTK
 static int proc_dmesg_restrict(struct ctl_table *table, int write,
-				void __user *buffer, size_t *lenp, loff_t *ppos);
+			       void __user *buffer, size_t *lenp,
+			       loff_t *ppos, void *cookie);
 #endif
 
 #ifdef CONFIG_MAGIC_SYSRQ
@@ -181,11 +184,11 @@ static int __sysrq_enabled = SYSRQ_DEFAULT_ENABLE;
 
 static int sysrq_sysctl_handler(ctl_table *table, int write,
 				void __user *buffer, size_t *lenp,
-				loff_t *ppos)
+				loff_t *ppos, void *cookie)
 {
 	int error;
 
-	error = proc_dointvec(table, write, buffer, lenp, ppos);
+	error = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (error)
 		return error;
 
@@ -2089,6 +2092,7 @@ static int _proc_do_string(void* data, int maxlen, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes a string from/to the user buffer. If the kernel
  * buffer provided is not large enough to hold the string, the
@@ -2100,7 +2104,8 @@ static int _proc_do_string(void* data, int maxlen, int write,
  * Returns 0 on success.
  */
 int proc_dostring(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos)
+		  void __user *buffer, size_t *lenp,
+		  loff_t *ppos, void *cookie)
 {
 	return _proc_do_string(table->data, table->maxlen, write,
 			       buffer, lenp, ppos);
@@ -2355,6 +2360,7 @@ static int do_proc_dointvec(struct ctl_table *table, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
  * values from/to the user buffer, treated as an ASCII string. 
@@ -2362,7 +2368,8 @@ static int do_proc_dointvec(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_dointvec(struct ctl_table *table, int write,
-		     void __user *buffer, size_t *lenp, loff_t *ppos)
+		  void __user *buffer, size_t *lenp,
+		  loff_t *ppos, void *cookie)
 {
     return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    NULL,NULL);
@@ -2373,7 +2380,8 @@ int proc_dointvec(struct ctl_table *table, int write,
  * This means we can safely use a temporary.
  */
 static int proc_taint(struct ctl_table *table, int write,
-			       void __user *buffer, size_t *lenp, loff_t *ppos)
+		      void __user *buffer, size_t *lenp,
+		      loff_t *ppos, void *cookie)
 {
 	struct ctl_table t;
 	unsigned long tmptaint = get_taint();
@@ -2384,7 +2392,7 @@ static int proc_taint(struct ctl_table *table, int write,
 
 	t = *table;
 	t.data = &tmptaint;
-	err = proc_doulongvec_minmax(&t, write, buffer, lenp, ppos);
+	err = proc_doulongvec_minmax(&t, write, buffer, lenp, ppos, NULL);
 	if (err < 0)
 		return err;
 
@@ -2405,12 +2413,13 @@ static int proc_taint(struct ctl_table *table, int write,
 
 #ifdef CONFIG_PRINTK
 static int proc_dmesg_restrict(struct ctl_table *table, int write,
-				void __user *buffer, size_t *lenp, loff_t *ppos)
+			       void __user *buffer, size_t *lenp,
+			       loff_t *ppos, void *cookie)
 {
 	if (write && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	return proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	return proc_dointvec_minmax(table, write, buffer, lenp, ppos, NULL);
 }
 #endif
 
@@ -2450,6 +2459,7 @@ static int do_proc_dointvec_minmax_conv(bool *negp, unsigned long *lvalp,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
  * values from/to the user buffer, treated as an ASCII string.
@@ -2460,7 +2470,8 @@ static int do_proc_dointvec_minmax_conv(bool *negp, unsigned long *lvalp,
  * Returns 0 on success.
  */
 int proc_dointvec_minmax(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos)
+			 void __user *buffer, size_t *lenp,
+			 loff_t *ppos, void *cookie)
 {
 	struct do_proc_dointvec_minmax_conv_param param = {
 		.min = (int *) table->extra1,
@@ -2567,6 +2578,7 @@ static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned long) unsigned long
  * values from/to the user buffer, treated as an ASCII string.
@@ -2577,7 +2589,8 @@ static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_doulongvec_minmax(struct ctl_table *table, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie)
 {
     return do_proc_doulongvec_minmax(table, write, buffer, lenp, ppos, 1l, 1l);
 }
@@ -2589,6 +2602,7 @@ int proc_doulongvec_minmax(struct ctl_table *table, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned long) unsigned long
  * values from/to the user buffer, treated as an ASCII string. The values
@@ -2600,8 +2614,8 @@ int proc_doulongvec_minmax(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
-				      void __user *buffer,
-				      size_t *lenp, loff_t *ppos)
+				      void __user *buffer, size_t *lenp,
+				      loff_t *ppos, void *cookie)
 {
     return do_proc_doulongvec_minmax(table, write, buffer,
 				     lenp, ppos, HZ, 1000l);
@@ -2682,6 +2696,7 @@ static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
  * values from/to the user buffer, treated as an ASCII string. 
@@ -2691,7 +2706,8 @@ static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
  * Returns 0 on success.
  */
 int proc_dointvec_jiffies(struct ctl_table *table, int write,
-			  void __user *buffer, size_t *lenp, loff_t *ppos)
+			  void __user *buffer, size_t *lenp,
+			  loff_t *ppos, void *cookie)
 {
     return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    do_proc_dointvec_jiffies_conv,NULL);
@@ -2703,7 +2719,8 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write,
  * @write: %TRUE if this is a write to the sysctl file
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
- * @ppos: pointer to the file position
+ * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
  * values from/to the user buffer, treated as an ASCII string. 
@@ -2713,7 +2730,8 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
-				 void __user *buffer, size_t *lenp, loff_t *ppos)
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, void *cookie)
 {
     return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    do_proc_dointvec_userhz_jiffies_conv,NULL);
@@ -2726,7 +2744,7 @@ int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
- * @ppos: the current position in the file
+ * @cookie: ignored by this handler
  *
  * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
  * values from/to the user buffer, treated as an ASCII string. 
@@ -2736,14 +2754,16 @@ int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_dointvec_ms_jiffies(struct ctl_table *table, int write,
-			     void __user *buffer, size_t *lenp, loff_t *ppos)
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos, void *cookie)
 {
 	return do_proc_dointvec(table, write, buffer, lenp, ppos,
 				do_proc_dointvec_ms_jiffies_conv, NULL);
 }
 
 static int proc_do_cad_pid(struct ctl_table *table, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie)
 {
 	struct pid *new_pid;
 	pid_t tmp;
@@ -2771,6 +2791,7 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
+ * @cookie: ignored by this handler
  *
  * The bitmap is stored at table->data and the bitmap length (in bits)
  * in table->maxlen.
@@ -2782,7 +2803,8 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
  * Returns 0 on success.
  */
 int proc_do_large_bitmap(struct ctl_table *table, int write,
-			 void __user *buffer, size_t *lenp, loff_t *ppos)
+			 void __user *buffer, size_t *lenp,
+			 loff_t *ppos, void *cookie)
 {
 	int err = 0;
 	bool first = 1;
@@ -2918,50 +2940,57 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
 #else /* CONFIG_PROC_SYSCTL */
 
 int proc_dostring(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos)
+		  void __user *buffer, size_t *lenp,
+		  loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_dointvec(struct ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos)
+		  void __user *buffer, size_t *lenp,
+		  loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_dointvec_minmax(struct ctl_table *table, int write,
-		    void __user *buffer, size_t *lenp, loff_t *ppos)
+			 void __user *buffer, size_t *lenp,
+			 loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_dointvec_jiffies(struct ctl_table *table, int write,
-		    void __user *buffer, size_t *lenp, loff_t *ppos)
+			  void __user *buffer, size_t *lenp,
+			  loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
-		    void __user *buffer, size_t *lenp, loff_t *ppos)
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_dointvec_ms_jiffies(struct ctl_table *table, int write,
-			     void __user *buffer, size_t *lenp, loff_t *ppos)
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_doulongvec_minmax(struct ctl_table *table, int write,
-		    void __user *buffer, size_t *lenp, loff_t *ppos)
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie)
 {
 	return -ENOSYS;
 }
 
 int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
-				      void __user *buffer,
-				      size_t *lenp, loff_t *ppos)
+				      void __user *buffer, size_t *lenp,
+				      loff_t *ppos, void *cookie)
 {
     return -ENOSYS;
 }
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index c075f4e..91a4d03 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -3178,7 +3178,7 @@ int unregister_ftrace_function(struct ftrace_ops *ops)
 int
 ftrace_enable_sysctl(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp,
-		     loff_t *ppos)
+		     loff_t *ppos, void *cookie)
 {
 	int ret;
 
@@ -3187,7 +3187,7 @@ ftrace_enable_sysctl(struct ctl_table *table, int write,
 
 	mutex_lock(&ftrace_lock);
 
-	ret  = proc_dointvec(table, write, buffer, lenp, ppos);
+	ret  = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if (ret || !write || (last_ftrace_enabled == !!ftrace_enabled))
 		goto out;
diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
index 4c5dead..9ac91f2 100644
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -322,13 +322,13 @@ static const struct file_operations stack_trace_fops = {
 int
 stack_trace_sysctl(struct ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp,
-		   loff_t *ppos)
+		   loff_t *ppos, void *cookie)
 {
 	int ret;
 
 	mutex_lock(&stack_sysctl_mutex);
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if (ret || !write ||
 	    (last_stack_tracer_enabled == !!stack_tracer_enabled))
diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index a2cd77e..a4d0d8c 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -42,14 +42,14 @@ static void put_uts(ctl_table *table, int write, void *which)
  *	Special case of dostring for the UTS structure. This has locks
  *	to observe. Should this be in kernel/sys.c ????
  */
-static int proc_do_uts_string(ctl_table *table, int write,
-		  void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_do_uts_string(ctl_table *table, int write, void __user *buffer,
+			      size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct ctl_table uts_table;
 	int r;
 	memcpy(&uts_table, table, sizeof(uts_table));
 	uts_table.data = get_uts(table, write);
-	r = proc_dostring(&uts_table,write,buffer,lenp, ppos);
+	r = proc_dostring(&uts_table,write,buffer,lenp, ppos, NULL);
 	put_uts(table, write, uts_table.data);
 	return r;
 }
diff --git a/kernel/watchdog.c b/kernel/watchdog.c
index 140dce7..23f78c0 100644
--- a/kernel/watchdog.c
+++ b/kernel/watchdog.c
@@ -502,9 +502,10 @@ static void watchdog_disable_all_cpus(void)
  */
 
 int proc_dowatchdog_enabled(struct ctl_table *table, int write,
-		     void __user *buffer, size_t *length, loff_t *ppos)
+			    void __user *buffer, size_t *length,
+			    loff_t *ppos, void *cookie)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos, NULL);
 
 	if (write) {
 		if (watchdog_enabled)
@@ -516,10 +517,10 @@ int proc_dowatchdog_enabled(struct ctl_table *table, int write,
 }
 
 int proc_dowatchdog_thresh(struct ctl_table *table, int write,
-			     void __user *buffer,
-			     size_t *lenp, loff_t *ppos)
+			   void __user *buffer, size_t *lenp,
+			   loff_t *ppos, void *cookie)
 {
-	return proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	return proc_dointvec_minmax(table, write, buffer, lenp, ppos, NULL);
 }
 #endif /* CONFIG_SYSCTL */
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..18dd3e7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -676,7 +676,8 @@ int sysctl_compact_memory;
 
 /* This is the entry point for compacting all nodes via /proc/sys/vm */
 int sysctl_compaction_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos)
+			      void __user *buffer, size_t *length,
+			      loff_t *ppos, void *cookie)
 {
 	if (write)
 		return compact_nodes();
@@ -685,9 +686,10 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 }
 
 int sysctl_extfrag_handler(struct ctl_table *table, int write,
-			void __user *buffer, size_t *length, loff_t *ppos)
+			   void __user *buffer, size_t *length,
+			   loff_t *ppos, void *cookie)
 {
-	proc_dointvec_minmax(table, write, buffer, length, ppos);
+	proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 
 	return 0;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06de5aa..2f3f60e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1879,7 +1879,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (ret)
 		goto out;
 
@@ -1901,27 +1901,29 @@ out:
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
-			  void __user *buffer, size_t *length, loff_t *ppos)
+			   void __user *buffer, size_t *length,
+			   loff_t *ppos, void *cookie)
 {
 
 	return hugetlb_sysctl_handler_common(false, table, write,
-							buffer, length, ppos);
+					     buffer, length, ppos);
 }
 
 #ifdef CONFIG_NUMA
 int hugetlb_mempolicy_sysctl_handler(struct ctl_table *table, int write,
-			  void __user *buffer, size_t *length, loff_t *ppos)
+				     void __user *buffer, size_t *length,
+				     loff_t *ppos, void *cookie)
 {
 	return hugetlb_sysctl_handler_common(true, table, write,
-							buffer, length, ppos);
+					     buffer, length, ppos);
 }
 #endif /* CONFIG_NUMA */
 
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
-			void __user *buffer,
-			size_t *length, loff_t *ppos)
+				  void __user *buffer, size_t *length,
+				  loff_t *ppos, void *cookie)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos, NULL);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
 	else
@@ -1930,8 +1932,8 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 }
 
 int hugetlb_overcommit_handler(struct ctl_table *table, int write,
-			void __user *buffer,
-			size_t *length, loff_t *ppos)
+			       void __user *buffer, size_t *length,
+			       loff_t *ppos, void *cookie)
 {
 	struct hstate *h = &default_hstate;
 	unsigned long tmp;
@@ -1944,7 +1946,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (ret)
 		goto out;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 31f6988..b8cb0b0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -159,37 +159,34 @@ static void update_completion_period(void)
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0 && write)
 		dirty_background_bytes = 0;
 	return ret;
 }
 
 int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0 && write)
 		dirty_background_ratio = 0;
 	return ret;
 }
 
 int dirty_ratio_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int old_ratio = vm_dirty_ratio;
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
 		update_completion_period();
 		vm_dirty_bytes = 0;
@@ -199,13 +196,12 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 
 
 int dirty_bytes_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie)
 {
 	unsigned long old_bytes = vm_dirty_bytes;
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
 		update_completion_period();
 		vm_dirty_ratio = 0;
@@ -684,9 +680,9 @@ void throttle_vm_writeout(gfp_t gfp_mask)
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
 int dirty_writeback_centisecs_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+		void __user *buffer, size_t *lenp, loff_t *ppos, void *cookie)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	bdi_arm_supers_timer();
 	return 0;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d6e7ba7..0e46115 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2721,8 +2721,7 @@ early_param("numa_zonelist_order", setup_numa_zonelist_order);
  * sysctl handler for numa_zonelist_order
  */
 int numa_zonelist_order_handler(ctl_table *table, int write,
-		void __user *buffer, size_t *length,
-		loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
 	char saved_string[NUMA_ZONELIST_ORDER_LEN];
 	int ret;
@@ -2731,7 +2730,7 @@ int numa_zonelist_order_handler(ctl_table *table, int write,
 	mutex_lock(&zl_order_mutex);
 	if (write)
 		strcpy(saved_string, (char*)table->data);
-	ret = proc_dostring(table, write, buffer, length, ppos);
+	ret = proc_dostring(table, write, buffer, length, ppos, NULL);
 	if (ret)
 		goto out;
 	if (write) {
@@ -5142,9 +5141,9 @@ module_init(init_per_zone_wmark_min)
  *	changes.
  */
 int min_free_kbytes_sysctl_handler(ctl_table *table, int write, 
-	void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
-	proc_dointvec(table, write, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos, NULL);
 	if (write)
 		setup_per_zone_wmarks();
 	return 0;
@@ -5152,12 +5151,12 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 
 #ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
 	struct zone *zone;
 	int rc;
 
-	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (rc)
 		return rc;
 
@@ -5168,12 +5167,12 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 }
 
 int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
 	struct zone *zone;
 	int rc;
 
-	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (rc)
 		return rc;
 
@@ -5194,9 +5193,9 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  * if in function of the boot time zone sizes.
  */
 int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
-	proc_dointvec_minmax(table, write, buffer, length, ppos);
+	proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
@@ -5208,13 +5207,13 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
  */
 
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos, void *cookie)
 {
 	struct zone *zone;
 	unsigned int cpu;
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos, NULL);
 	if (!write || (ret == -EINVAL))
 		return ret;
 	for_each_populated_zone(zone) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f73b865..6a578af 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3273,10 +3273,10 @@ static void scan_all_zones_unevictable_pages(void)
 unsigned long scan_unevictable_pages;
 
 int scan_unevictable_handler(struct ctl_table *table, int write,
-			   void __user *buffer,
-			   size_t *length, loff_t *ppos)
+			     void __user *buffer, size_t *length,
+			     loff_t *ppos, void *cookie)
 {
-	proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	proc_doulongvec_minmax(table, write, buffer, length, ppos, NULL);
 
 	if (write && *(unsigned long *)table->data)
 		scan_all_zones_unevictable_pages();
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..5d5ac11 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -932,12 +932,12 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 
 #ifdef CONFIG_SYSCTL
 static
-int brnf_sysctl_call_tables(ctl_table * ctl, int write,
-			    void __user * buffer, size_t * lenp, loff_t * ppos)
+int brnf_sysctl_call_tables(ctl_table * ctl, int write, void __user * buffer,
+			    size_t * lenp, loff_t * ppos, void * cookie)
 {
 	int ret;
 
-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write && *(int *)(ctl->data))
 		*(int *)(ctl->data) = 1;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 385b609..923ae0f 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -20,7 +20,8 @@
 
 #ifdef CONFIG_RPS
 static int rps_sock_flow_sysctl(ctl_table *table, int write,
-				void __user *buffer, size_t *lenp, loff_t *ppos)
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos, void *cookie)
 {
 	unsigned int orig_size, size;
 	int ret, i;
@@ -38,7 +39,7 @@ static int rps_sock_flow_sysctl(ctl_table *table, int write,
 					lockdep_is_held(&sock_flow_mutex));
 	size = orig_size = orig_sock_table ? orig_sock_table->mask + 1 : 0;
 
-	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);
+	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos, NULL);
 
 	if (write) {
 		if (size) {
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 0dcaa90..6935f42 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -159,8 +159,8 @@ static int max_t3[] = { 8191 }; /* Must fit in 16 bits when multiplied by BCT3MU
 static int min_priority[1];
 static int max_priority[] = { 127 }; /* From DECnet spec */
 
-static int dn_forwarding_proc(ctl_table *, int,
-			void __user *, size_t *, loff_t *);
+static int dn_forwarding_proc(ctl_table *, int, void __user *,
+			      size_t *, loff_t *, void *);
 static struct dn_dev_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table dn_dev_vars[5];
@@ -255,8 +255,8 @@ static void dn_dev_sysctl_unregister(struct dn_dev_parms *parms)
 }
 
 static int dn_forwarding_proc(ctl_table *table, int write,
-				void __user *buffer,
-				size_t *lenp, loff_t *ppos)
+			      void __user *buffer, size_t *lenp,
+			      loff_t *ppos, void *cookie)
 {
 #ifdef CONFIG_DECNET_ROUTER
 	struct net_device *dev = table->extra1;
@@ -270,7 +270,7 @@ static int dn_forwarding_proc(ctl_table *table, int write,
 	dn_db = rcu_dereference_raw(dev->dn_ptr);
 	old = dn_db->parms.forwarding;
 
-	err = proc_dointvec(table, write, buffer, lenp, ppos);
+	err = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 
 	if ((err >= 0) && write) {
 		if (dn_db->parms.forwarding < 0)
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 28f8b5e..90e87a7 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -132,8 +132,8 @@ static int parse_addr(__le16 *addr, char *str)
 }
 
 static int dn_node_address_handler(ctl_table *table, int write,
-				void __user *buffer,
-				size_t *lenp, loff_t *ppos)
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos, void *cookie)
 {
 	char addr[DN_ASCBUF_LEN];
 	size_t len;
@@ -183,8 +183,8 @@ static int dn_node_address_handler(ctl_table *table, int write,
 }
 
 static int dn_def_dev_handler(ctl_table *table, int write,
-				void __user *buffer,
-				size_t *lenp, loff_t *ppos)
+			      void __user *buffer, size_t *lenp,
+			      loff_t *ppos, void *cookie)
 {
 	size_t len;
 	struct net_device *dev;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd9ca08..551786f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1487,10 +1487,10 @@ static void inet_forward_change(struct net *net)
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
-			     void __user *buffer,
-			     size_t *lenp, loff_t *ppos)
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos, void *cookie)
 {
-	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write) {
 		struct ipv4_devconf *cnf = ctl->extra1;
@@ -1507,13 +1507,13 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 }
 
 static int devinet_sysctl_forward(ctl_table *ctl, int write,
-				  void __user *buffer,
-				  size_t *lenp, loff_t *ppos)
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos, void *cookie)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
-	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write && *valp != val) {
 		struct net *net = ctl->extra2;
@@ -1542,12 +1542,12 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 }
 
 static int ipv4_doint_and_flush(ctl_table *ctl, int write,
-				void __user *buffer,
-				size_t *lenp, loff_t *ppos)
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos, void *cookie)
 {
 	int *valp = ctl->data;
 	int val = *valp;
-	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 	struct net *net = ctl->extra2;
 
 	if (write && *valp != val)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4b0c811..0c66ea6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3009,8 +3009,8 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 
 #ifdef CONFIG_SYSCTL
 static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
-					void __user *buffer,
-					size_t *lenp, loff_t *ppos)
+				     void __user *buffer, size_t *lenp,
+				     loff_t *ppos, void *cookie)
 {
 	if (write) {
 		int flush_delay;
@@ -3019,7 +3019,7 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 
 		memcpy(&ctl, __ctl, sizeof(ctl));
 		ctl.data = &flush_delay;
-		proc_dointvec(&ctl, write, buffer, lenp, ppos);
+		proc_dointvec(&ctl, write, buffer, lenp, ppos, NULL);
 
 		net = (struct net *)__ctl->extra1;
 		rt_cache_flush(net, flush_delay);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1a45665..1766d2e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -42,8 +42,8 @@ static void set_local_port_range(int range[2])
 
 /* Validate changes from /proc interface. */
 static int ipv4_local_port_range(ctl_table *table, int write,
-				 void __user *buffer,
-				 size_t *lenp, loff_t *ppos)
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, void *cookie)
 {
 	int ret;
 	int range[2];
@@ -56,7 +56,7 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 	};
 
 	inet_get_local_port_range(range, range + 1);
-	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos, NULL);
 
 	if (write && ret == 0) {
 		if (range[1] < range[0])
@@ -69,7 +69,8 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 }
 
 static int proc_tcp_congestion_control(ctl_table *ctl, int write,
-				       void __user *buffer, size_t *lenp, loff_t *ppos)
+				       void __user *buffer, size_t *lenp,
+				       loff_t *ppos, void *cookie)
 {
 	char val[TCP_CA_NAME_MAX];
 	ctl_table tbl = {
@@ -80,16 +81,15 @@ static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 
 	tcp_get_default_congestion_control(val);
 
-	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos, NULL);
 	if (write && ret == 0)
 		ret = tcp_set_default_congestion_control(val);
 	return ret;
 }
 
-static int proc_tcp_available_congestion_control(ctl_table *ctl,
-						 int write,
+static int proc_tcp_available_congestion_control(ctl_table *ctl, int write,
 						 void __user *buffer, size_t *lenp,
-						 loff_t *ppos)
+						 loff_t *ppos, void *cookie)
 {
 	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX, };
 	int ret;
@@ -98,15 +98,14 @@ static int proc_tcp_available_congestion_control(ctl_table *ctl,
 	if (!tbl.data)
 		return -ENOMEM;
 	tcp_get_available_congestion_control(tbl.data, TCP_CA_BUF_MAX);
-	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos, NULL);
 	kfree(tbl.data);
 	return ret;
 }
 
-static int proc_allowed_congestion_control(ctl_table *ctl,
-					   int write,
+static int proc_allowed_congestion_control(ctl_table *ctl, int write,
 					   void __user *buffer, size_t *lenp,
-					   loff_t *ppos)
+					   loff_t *ppos, void *cookie)
 {
 	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
 	int ret;
@@ -116,7 +115,7 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 		return -ENOMEM;
 
 	tcp_get_allowed_congestion_control(tbl.data, tbl.maxlen);
-	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos, NULL);
 	if (write && ret == 0)
 		ret = tcp_set_allowed_congestion_control(tbl.data);
 	kfree(tbl.data);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b1654a4..4a28442 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4156,15 +4156,15 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 #ifdef CONFIG_SYSCTL
 
 static
-int addrconf_sysctl_forward(ctl_table *ctl, int write,
-			   void __user *buffer, size_t *lenp, loff_t *ppos)
+int addrconf_sysctl_forward(ctl_table *ctl, int write, void __user *buffer,
+			    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
 	int ret;
 
-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write)
 		ret = addrconf_fixup_forwarding(ctl, valp, val);
@@ -4229,15 +4229,15 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
 }
 
 static
-int addrconf_sysctl_disable(ctl_table *ctl, int write,
-			    void __user *buffer, size_t *lenp, loff_t *ppos)
+int addrconf_sysctl_disable(ctl_table *ctl, int write, void __user *buffer,
+			    size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
 	int ret;
 
-	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	if (write)
 		ret = addrconf_disable_ipv6(ctl, valp, val);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0e49c9d..61ff29b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1751,7 +1751,9 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 	}
 }
 
-int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *buffer, size_t *lenp, loff_t *ppos)
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write,
+			       void __user *buffer, size_t *lenp,
+			       loff_t *ppos, void *cookie)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
@@ -1762,16 +1764,16 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 		ndisc_warn_deprecated_sysctl(ctl, "syscall", dev ? dev->name : "default");
 
 	if (strcmp(ctl->procname, "retrans_time") == 0)
-		ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+		ret = proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 
 	else if (strcmp(ctl->procname, "base_reachable_time") == 0)
-		ret = proc_dointvec_jiffies(ctl, write,
-					    buffer, lenp, ppos);
+		ret = proc_dointvec_jiffies(ctl, write, buffer,
+					    lenp, ppos, NULL);
 
 	else if ((strcmp(ctl->procname, "retrans_time_ms") == 0) ||
 		 (strcmp(ctl->procname, "base_reachable_time_ms") == 0))
-		ret = proc_dointvec_ms_jiffies(ctl, write,
-					       buffer, lenp, ppos);
+		ret = proc_dointvec_ms_jiffies(ctl, write, buffer,
+					       lenp, ppos, NULL);
 	else
 		ret = -1;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..48ec0b7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2593,8 +2593,8 @@ static const struct file_operations rt6_stats_seq_fops = {
 #ifdef CONFIG_SYSCTL
 
 static
-int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
-			      void __user *buffer, size_t *lenp, loff_t *ppos)
+int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write, void __user *buffer,
+			      size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct net *net;
 	int delay;
@@ -2603,7 +2603,7 @@ int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 
 	net = (struct net *)ctl->extra1;
 	delay = net->ipv6.sysctl.flush_delay;
-	proc_dointvec(ctl, write, buffer, lenp, ppos);
+	proc_dointvec(ctl, write, buffer, lenp, ppos, NULL);
 	fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
 	return 0;
 }
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index d0b70da..1ee0226 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -73,12 +73,12 @@ static int min_lap_keepalive_time = 100;	/* 100us */
 /* For other sysctl, I've no idea of the range. Maybe Dag could help
  * us on that - Jean II */
 
-static int do_devname(ctl_table *table, int write,
-		      void __user *buffer, size_t *lenp, loff_t *ppos)
+static int do_devname(ctl_table *table, int write, void __user *buffer,
+		      size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int ret;
 
-	ret = proc_dostring(table, write, buffer, lenp, ppos);
+	ret = proc_dostring(table, write, buffer, lenp, ppos, NULL);
 	if (ret == 0 && write) {
 		struct ias_value *val;
 
@@ -90,12 +90,12 @@ static int do_devname(ctl_table *table, int write,
 }
 
 
-static int do_discovery(ctl_table *table, int write,
-                    void __user *buffer, size_t *lenp, loff_t *ppos)
+static int do_discovery(ctl_table *table, int write, void __user *buffer,
+			size_t *lenp, loff_t *ppos, void *cookie)
 {
        int ret;
 
-       ret = proc_dointvec(table, write, buffer, lenp, ppos);
+       ret = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
        if (ret)
 	       return ret;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 33733c8..6269b13 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1514,15 +1514,15 @@ static int ip_vs_zero_all(struct net *net)
 
 #ifdef CONFIG_SYSCTL
 static int
-proc_do_defense_mode(ctl_table *table, int write,
-		     void __user *buffer, size_t *lenp, loff_t *ppos)
+proc_do_defense_mode(ctl_table *table, int write, void __user *buffer,
+		     size_t *lenp, loff_t *ppos, void *cookie)
 {
 	struct net *net = current->nsproxy->net_ns;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
 
-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	rc = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (write && (*valp != val)) {
 		if ((*valp < 0) || (*valp > 3)) {
 			/* Restore the correct value */
@@ -1535,8 +1535,8 @@ proc_do_defense_mode(ctl_table *table, int write,
 }
 
 static int
-proc_do_sync_threshold(ctl_table *table, int write,
-		       void __user *buffer, size_t *lenp, loff_t *ppos)
+proc_do_sync_threshold(ctl_table *table, int write, void __user *buffer,
+		       size_t *lenp, loff_t *ppos, void *cookie)
 {
 	int *valp = table->data;
 	int val[2];
@@ -1545,7 +1545,7 @@ proc_do_sync_threshold(ctl_table *table, int write,
 	/* backup the value first */
 	memcpy(val, valp, sizeof(val));
 
-	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	rc = proc_dointvec(table, write, buffer, lenp, ppos, NULL);
 	if (write && (valp[0] < 0 || valp[1] < 0 || valp[0] >= valp[1])) {
 		/* Restore the correct value */
 		memcpy(valp, val, sizeof(val));
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 20714ed..9bd1f90 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -226,7 +226,8 @@ static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 static struct ctl_table_header *nf_log_dir_header;
 
 static int nf_log_proc_dostring(ctl_table *table, int write,
-			 void __user *buffer, size_t *lenp, loff_t *ppos)
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos, void *cookie)
 {
 	const struct nf_logger *logger;
 	char buf[NFLOGGER_NAME_LEN];
@@ -260,7 +261,7 @@ static int nf_log_proc_dostring(ctl_table *table, int write,
 			table->data = "NONE";
 		else
 			table->data = logger->name;
-		r = proc_dostring(table, write, buffer, lenp, ppos);
+		r = proc_dostring(table, write, buffer, lenp, ppos, NULL);
 		mutex_unlock(&nf_log_mutex);
 	}
 
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index cea1c7d..7bdaf3e 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -57,8 +57,8 @@ void phonet_get_local_port_range(int *min, int *max)
 }
 
 static int proc_local_port_range(ctl_table *table, int write,
-				void __user *buffer,
-				size_t *lenp, loff_t *ppos)
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, void *cookie)
 {
 	int ret;
 	int range[2] = {local_port_range[0], local_port_range[1]};
@@ -70,7 +70,7 @@ static int proc_local_port_range(ctl_table *table, int write,
 		.extra2 = &local_port_range_max,
 	};
 
-	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos, NULL);
 
 	if (write && ret == 0) {
 		if (range[1] < range[0])
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index e65dcc6..30fc555 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -56,8 +56,8 @@ rpc_unregister_sysctl(void)
 	}
 }
 
-static int proc_do_xprt(ctl_table *table, int write,
-			void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_do_xprt(ctl_table *table, int write, void __user *buffer,
+			size_t *lenp, loff_t *ppos, void *cookie)
 {
 	char tmpbuf[256];
 	size_t len;
@@ -70,9 +70,8 @@ static int proc_do_xprt(ctl_table *table, int write,
 	return simple_read_from_buffer(buffer, *lenp, ppos, tmpbuf, len);
 }
 
-static int
-proc_dodebug(ctl_table *table, int write,
-				void __user *buffer, size_t *lenp, loff_t *ppos)
+static int proc_dodebug(ctl_table *table, int write, void __user *buffer,
+			size_t *lenp, loff_t *ppos, void *cookie)
 {
 	char		tmpbuf[20], c, *s;
 	char __user *p;
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 09af4fa..fef4bf7 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -85,7 +85,7 @@ struct workqueue_struct *svc_rdma_wq;
  */
 static int read_reset_stat(ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp,
-			   loff_t *ppos)
+			   loff_t *ppos, void *cookie)
 {
 	atomic_t *stat = (atomic_t *)table->data;
 
diff --git a/security/min_addr.c b/security/min_addr.c
index f728728..340ae41 100644
--- a/security/min_addr.c
+++ b/security/min_addr.c
@@ -29,14 +29,15 @@ static void update_mmap_min_addr(void)
  * calls update_mmap_min_addr() so non MAP_FIXED hints get rounded properly
  */
 int mmap_min_addr_handler(struct ctl_table *table, int write,
-			  void __user *buffer, size_t *lenp, loff_t *ppos)
+			  void __user *buffer, size_t *lenp,
+			  loff_t *ppos, void *cookie)
 {
 	int ret;
 
 	if (write && !capable(CAP_SYS_RAWIO))
 		return -EPERM;
 
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos, NULL);
 
 	update_mmap_min_addr();
 
-- 
1.7.5.rc0

