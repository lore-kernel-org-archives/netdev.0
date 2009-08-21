From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] sysctl: remove "struct file *" argument of ->proc_handler
Date: Fri, 21 Aug 2009 23:53:44 +0400
Message-ID: <20090821195343.GA2519@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dhowells@redhat.com, ebiederm@xmission.com, viro@zeniv.linux.org.uk
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932408AbZHUTxw@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's unused.

It isn't needed -- read or write flag is already passed and
sysctl shouldn't care about the rest.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 It _is_ used in two places at arch/frv for some disgusting
 reason.

 arch/frv/kernel/pm.c               |   14 +++---
 arch/mips/lasat/sysctl.c           |   18 ++++----
 arch/s390/appldata/appldata_base.c |    9 +---
 arch/s390/kernel/debug.c           |    4 -
 arch/s390/mm/cmm.c                 |    4 -
 arch/x86/include/asm/nmi.h         |    3 -
 arch/x86/kernel/apic/nmi.c         |    4 -
 arch/x86/kernel/vsyscall_64.c      |   10 ----
 drivers/cdrom/cdrom.c              |    8 +--
 drivers/char/random.c              |    4 -
 drivers/net/wireless/arlan-proc.c  |   28 ++++++-------
 drivers/parport/procfs.c           |   12 ++---
 fs/coda/coda_int.h                 |    1 
 fs/drop_caches.c                   |    4 -
 fs/file_table.c                    |    6 +-
 fs/proc/proc_sysctl.c              |    2 
 fs/xfs/linux-2.6/xfs_sysctl.c      |    3 -
 include/linux/fs.h                 |    2 
 include/linux/ftrace.h             |    4 -
 include/linux/hugetlb.h            |    6 +-
 include/linux/mm.h                 |    2 
 include/linux/mmzone.h             |   13 ++----
 include/linux/sched.h              |    8 +--
 include/linux/security.h           |    2 
 include/linux/swap.h               |    2 
 include/linux/sysctl.h             |   19 ++++-----
 include/linux/writeback.h          |   11 ++---
 include/net/ip.h                   |    2 
 include/net/ndisc.h                |    2 
 ipc/ipc_sysctl.c                   |   16 +++----
 ipc/mq_sysctl.c                    |    8 +--
 kernel/hung_task.c                 |    4 -
 kernel/sched.c                     |    4 -
 kernel/sched_fair.c                |    4 -
 kernel/slow-work.c                 |   12 ++---
 kernel/softlockup.c                |    4 -
 kernel/sysctl.c                    |   78 +++++++++++++++----------------------
 kernel/trace/ftrace.c              |    4 -
 kernel/trace/trace_stack.c         |    4 -
 kernel/utsname_sysctl.c            |    4 -
 mm/hugetlb.c                       |   12 ++---
 mm/page-writeback.c                |   20 ++++-----
 mm/page_alloc.c                    |   24 +++++------
 mm/vmscan.c                        |    4 -
 net/bridge/br_netfilter.c          |    4 -
 net/decnet/dn_dev.c                |    5 --
 net/decnet/sysctl_net_decnet.c     |    2 
 net/ipv4/devinet.c                 |   12 ++---
 net/ipv4/route.c                   |    7 +--
 net/ipv4/sysctl_net_ipv4.c         |   16 +++----
 net/ipv6/addrconf.c                |    8 +--
 net/ipv6/ndisc.c                   |    8 +--
 net/ipv6/route.c                   |    4 -
 net/irda/irsysctl.c                |    8 +--
 net/netfilter/ipvs/ip_vs_ctl.c     |    8 +--
 net/netfilter/nf_log.c             |    4 -
 net/phonet/sysctl.c                |    4 -
 net/sunrpc/sysctl.c                |    4 -
 net/sunrpc/xprtrdma/svc_rdma.c     |    2 
 security/min_addr.c                |    4 -
 60 files changed, 239 insertions(+), 270 deletions(-)

--- a/arch/frv/kernel/pm.c
+++ b/arch/frv/kernel/pm.c
@@ -150,7 +150,7 @@ static int user_atoi(char __user *ubuf, size_t len)
 /*
  * Send us to sleep.
  */
-static int sysctl_pm_do_suspend(ctl_table *ctl, int write, struct file *filp,
+static int sysctl_pm_do_suspend(ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp, loff_t *fpos)
 {
 	int retval, mode;
@@ -198,13 +198,13 @@ static int try_set_cmode(int new_cmode)
 }
 
 
-static int cmode_procctl(ctl_table *ctl, int write, struct file *filp,
+static int cmode_procctl(ctl_table *ctl, int write,
 			 void __user *buffer, size_t *lenp, loff_t *fpos)
 {
 	int new_cmode;
 
 	if (!write)
-		return proc_dointvec(ctl, write, filp, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos);
 
 	new_cmode = user_atoi(buffer, *lenp);
 
@@ -301,13 +301,13 @@ static int try_set_cm(int new_cm)
 	return 0;
 }
 
-static int p0_procctl(ctl_table *ctl, int write, struct file *filp,
+static int p0_procctl(ctl_table *ctl, int write,
 		      void __user *buffer, size_t *lenp, loff_t *fpos)
 {
 	int new_p0;
 
 	if (!write)
-		return proc_dointvec(ctl, write, filp, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos);
 
 	new_p0 = user_atoi(buffer, *lenp);
 
@@ -345,13 +345,13 @@ static int p0_sysctl(ctl_table *table,
 	return 1;
 }
 
-static int cm_procctl(ctl_table *ctl, int write, struct file *filp,
+static int cm_procctl(ctl_table *ctl, int write,
 		      void __user *buffer, size_t *lenp, loff_t *fpos)
 {
 	int new_cm;
 
 	if (!write)
-		return proc_dointvec(ctl, write, filp, buffer, lenp, fpos);
+		return proc_dointvec(ctl, write, buffer, lenp, fpos);
 
 	new_cm = user_atoi(buffer, *lenp);
 
--- a/arch/mips/lasat/sysctl.c
+++ b/arch/mips/lasat/sysctl.c
@@ -56,12 +56,12 @@ int sysctl_lasatstring(ctl_table *table,
 
 
 /* And the same for proc */
-int proc_dolasatstring(ctl_table *table, int write, struct file *filp,
+int proc_dolasatstring(ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
 	int r;
 
-	r = proc_dostring(table, write, filp, buffer, lenp, ppos);
+	r = proc_dostring(table, write, buffer, lenp, ppos);
 	if ((!write) || r)
 		return r;
 
@@ -71,12 +71,12 @@ int proc_dolasatstring(ctl_table *table, int write, struct file *filp,
 }
 
 /* proc function to write EEPROM after changing int entry */
-int proc_dolasatint(ctl_table *table, int write, struct file *filp,
+int proc_dolasatint(ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
 	int r;
 
-	r = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos);
 	if ((!write) || r)
 		return r;
 
@@ -89,7 +89,7 @@ int proc_dolasatint(ctl_table *table, int write, struct file *filp,
 static int rtctmp;
 
 /* proc function to read/write RealTime Clock */
-int proc_dolasatrtc(ctl_table *table, int write, struct file *filp,
+int proc_dolasatrtc(ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
 	int r;
@@ -100,7 +100,7 @@ int proc_dolasatrtc(ctl_table *table, int write, struct file *filp,
 		if (rtctmp < 0)
 			rtctmp = 0;
 	}
-	r = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos);
 	if (r)
 		return r;
 
@@ -150,7 +150,7 @@ int sysctl_lasat_rtc(ctl_table *table,
 #endif
 
 #ifdef CONFIG_INET
-int proc_lasat_ip(ctl_table *table, int write, struct file *filp,
+int proc_lasat_ip(ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
 	unsigned int ip;
@@ -227,12 +227,12 @@ static int sysctl_lasat_prid(ctl_table *table,
 	return 0;
 }
 
-int proc_lasat_prid(ctl_table *table, int write, struct file *filp,
+int proc_lasat_prid(ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
 	int r;
 
-	r = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	r = proc_dointvec(table, write, buffer, lenp, ppos);
 	if (r < 0)
 		return r;
 	if (write) {
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -50,10 +50,9 @@ static struct platform_device *appldata_pdev;
  * /proc entries (sysctl)
  */
 static const char appldata_proc_name[APPLDATA_PROC_NAME_LENGTH] = "appldata";
-static int appldata_timer_handler(ctl_table *ctl, int write, struct file *filp,
+static int appldata_timer_handler(ctl_table *ctl, int write,
 				  void __user *buffer, size_t *lenp, loff_t *ppos);
 static int appldata_interval_handler(ctl_table *ctl, int write,
-					 struct file *filp,
 					 void __user *buffer,
 					 size_t *lenp, loff_t *ppos);
 
@@ -247,7 +246,7 @@ __appldata_vtimer_setup(int cmd)
  * Start/Stop timer, show status of timer (0 = not active, 1 = active)
  */
 static int
-appldata_timer_handler(ctl_table *ctl, int write, struct file *filp,
+appldata_timer_handler(ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int len;
@@ -289,7 +288,7 @@ out:
  * current timer interval.
  */
 static int
-appldata_interval_handler(ctl_table *ctl, int write, struct file *filp,
+appldata_interval_handler(ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int len, interval;
@@ -335,7 +334,7 @@ out:
  * monitoring (0 = not in process, 1 = in process)
  */
 static int
-appldata_generic_handler(ctl_table *ctl, int write, struct file *filp,
+appldata_generic_handler(ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct appldata_ops *ops = NULL, *tmp_ops;
--- a/arch/s390/kernel/debug.c
+++ b/arch/s390/kernel/debug.c
@@ -883,11 +883,11 @@ static int debug_active=1;
  * if debug_active is already off
  */
 static int
-s390dbf_procactive(ctl_table *table, int write, struct file *filp,
+s390dbf_procactive(ctl_table *table, int write,
                      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	if (!write || debug_stoppable || !debug_active)
-		return proc_dointvec(table, write, filp, buffer, lenp, ppos);
+		return proc_dointvec(table, write, buffer, lenp, ppos);
 	else
 		return 0;
 }
--- a/arch/s390/mm/cmm.c
+++ b/arch/s390/mm/cmm.c
@@ -262,7 +262,7 @@ cmm_skip_blanks(char *cp, char **endp)
 static struct ctl_table cmm_table[];
 
 static int
-cmm_pages_handler(ctl_table *ctl, int write, struct file *filp,
+cmm_pages_handler(ctl_table *ctl, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char buf[16], *p;
@@ -303,7 +303,7 @@ cmm_pages_handler(ctl_table *ctl, int write, struct file *filp,
 }
 
 static int
-cmm_timeout_handler(ctl_table *ctl, int write, struct file *filp,
+cmm_timeout_handler(ctl_table *ctl, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char buf[64], *p;
--- a/arch/x86/include/asm/nmi.h
+++ b/arch/x86/include/asm/nmi.h
@@ -40,8 +40,7 @@ extern unsigned int nmi_watchdog;
 #define NMI_INVALID	3
 
 struct ctl_table;
-struct file;
-extern int proc_nmi_enabled(struct ctl_table *, int , struct file *,
+extern int proc_nmi_enabled(struct ctl_table *, int ,
 			void __user *, size_t *, loff_t *);
 extern int unknown_nmi_panic;
 
--- a/arch/x86/kernel/apic/nmi.c
+++ b/arch/x86/kernel/apic/nmi.c
@@ -506,14 +506,14 @@ static int unknown_nmi_panic_callback(struct pt_regs *regs, int cpu)
 /*
  * proc handler for /proc/sys/kernel/nmi
  */
-int proc_nmi_enabled(struct ctl_table *table, int write, struct file *file,
+int proc_nmi_enabled(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos)
 {
 	int old_state;
 
 	nmi_watchdog_enabled = (atomic_read(&nmi_active) > 0) ? 1 : 0;
 	old_state = nmi_watchdog_enabled;
-	proc_dointvec(table, write, file, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos);
 	if (!!old_state == !!nmi_watchdog_enabled)
 		return 0;
 
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -227,19 +227,11 @@ static long __vsyscall(3) venosys_1(void)
 }
 
 #ifdef CONFIG_SYSCTL
-
-static int
-vsyscall_sysctl_change(ctl_table *ctl, int write, struct file * filp,
-		       void __user *buffer, size_t *lenp, loff_t *ppos)
-{
-	return proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
-}
-
 static ctl_table kernel_table2[] = {
 	{ .procname = "vsyscall64",
 	  .data = &vsyscall_gtod_data.sysctl_enabled, .maxlen = sizeof(int),
 	  .mode = 0644,
-	  .proc_handler = vsyscall_sysctl_change },
+	  .proc_handler = proc_dointvec },
 	{}
 };
 
--- a/drivers/cdrom/cdrom.c
+++ b/drivers/cdrom/cdrom.c
@@ -3412,7 +3412,7 @@ static int cdrom_print_info(const char *header, int val, char *info,
 	return 0;
 }
 
-static int cdrom_sysctl_info(ctl_table *ctl, int write, struct file * filp,
+static int cdrom_sysctl_info(ctl_table *ctl, int write,
                            void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int pos;
@@ -3489,7 +3489,7 @@ static int cdrom_sysctl_info(ctl_table *ctl, int write, struct file * filp,
 		goto done;
 doit:
 	mutex_unlock(&cdrom_mutex);
-	return proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	return proc_dostring(ctl, write, buffer, lenp, ppos);
 done:
 	printk(KERN_INFO "cdrom: info buffer too small\n");
 	goto doit;
@@ -3525,12 +3525,12 @@ static void cdrom_update_settings(void)
 	mutex_unlock(&cdrom_mutex);
 }
 
-static int cdrom_sysctl_handler(ctl_table *ctl, int write, struct file * filp,
+static int cdrom_sysctl_handler(ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int ret;
 	
-	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write) {
 	
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1217,7 +1217,7 @@ static char sysctl_bootid[16];
  * as an ASCII string in the standard UUID format.  If accesses via the
  * sysctl system call, it is returned as 16 bytes of binary data.
  */
-static int proc_do_uuid(ctl_table *table, int write, struct file *filp,
+static int proc_do_uuid(ctl_table *table, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	ctl_table fake_table;
@@ -1240,7 +1240,7 @@ static int proc_do_uuid(ctl_table *table, int write, struct file *filp,
 	fake_table.data = buf;
 	fake_table.maxlen = sizeof(buf);
 
-	return proc_dostring(&fake_table, write, filp, buffer, lenp, ppos);
+	return proc_dostring(&fake_table, write, buffer, lenp, ppos);
 }
 
 static int uuid_strategy(ctl_table *table,
--- a/drivers/net/wireless/arlan-proc.c
+++ b/drivers/net/wireless/arlan-proc.c
@@ -402,7 +402,7 @@ static int arlan_setup_card_by_book(struct net_device *dev)
 
 static char arlan_drive_info[ARLAN_STR_SIZE] = "A655\n\0";
 
-static int arlan_sysctl_info(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_info(ctl_table * ctl, int write,
 		      void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int i;
@@ -629,7 +629,7 @@ final:
 	*lenp = pos;
 
 	if (!write)
-		retv = proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+		retv = proc_dostring(ctl, write, buffer, lenp, ppos);
 	else
 	{
 		*lenp = 0;
@@ -639,7 +639,7 @@ final:
 }
 
 
-static int arlan_sysctl_info161719(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_info161719(ctl_table * ctl, int write,
 			    void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int i;
@@ -669,11 +669,11 @@ static int arlan_sysctl_info161719(ctl_table * ctl, int write, struct file *filp
 
 final:
 	*lenp = pos;
-	retv = proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	retv = proc_dostring(ctl, write, buffer, lenp, ppos);
 	return retv;
 }
 
-static int arlan_sysctl_infotxRing(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_infotxRing(ctl_table * ctl, int write,
 			    void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int i;
@@ -698,11 +698,11 @@ static int arlan_sysctl_infotxRing(ctl_table * ctl, int write, struct file *filp
 	SARLBNpln(u_char, txBuffer, 0x800);
 final:
 	*lenp = pos;
-	retv = proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	retv = proc_dostring(ctl, write, buffer, lenp, ppos);
 	return retv;
 }
 
-static int arlan_sysctl_inforxRing(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_inforxRing(ctl_table * ctl, int write,
 			    void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int i;
@@ -726,11 +726,11 @@ static int arlan_sysctl_inforxRing(ctl_table * ctl, int write, struct file *filp
 	SARLBNpln(u_char, rxBuffer, 0x800);
 final:
 	*lenp = pos;
-	retv = proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	retv = proc_dostring(ctl, write, buffer, lenp, ppos);
 	return retv;
 }
 
-static int arlan_sysctl_info18(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_info18(ctl_table * ctl, int write,
 			void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int i;
@@ -756,7 +756,7 @@ static int arlan_sysctl_info18(ctl_table * ctl, int write, struct file *filp,
 
 final:
 	*lenp = pos;
-	retv = proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	retv = proc_dostring(ctl, write, buffer, lenp, ppos);
 	return retv;
 }
 
@@ -766,7 +766,7 @@ final:
 
 static char conf_reset_result[200];
 
-static int arlan_configure(ctl_table * ctl, int write, struct file *filp,
+static int arlan_configure(ctl_table * ctl, int write,
 		    void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int pos = 0;
@@ -788,10 +788,10 @@ static int arlan_configure(ctl_table * ctl, int write, struct file *filp,
 		return -1;
 
 	*lenp = pos;
-	return proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	return proc_dostring(ctl, write, buffer, lenp, ppos);
 }
 
-static int arlan_sysctl_reset(ctl_table * ctl, int write, struct file *filp,
+static int arlan_sysctl_reset(ctl_table * ctl, int write,
 		       void __user *buffer, size_t * lenp, loff_t *ppos)
 {
 	int pos = 0;
@@ -811,7 +811,7 @@ static int arlan_sysctl_reset(ctl_table * ctl, int write, struct file *filp,
 	} else
 		return -1;
 	*lenp = pos + 3;
-	return proc_dostring(ctl, write, filp, buffer, lenp, ppos);
+	return proc_dostring(ctl, write, buffer, lenp, ppos);
 }
 
 
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -31,7 +31,7 @@
 #define PARPORT_MIN_SPINTIME_VALUE 1
 #define PARPORT_MAX_SPINTIME_VALUE 1000
 
-static int do_active_device(ctl_table *table, int write, struct file *filp,
+static int do_active_device(ctl_table *table, int write,
 		      void __user *result, size_t *lenp, loff_t *ppos)
 {
 	struct parport *port = (struct parport *)table->extra1;
@@ -68,7 +68,7 @@ static int do_active_device(ctl_table *table, int write, struct file *filp,
 }
 
 #ifdef CONFIG_PARPORT_1284
-static int do_autoprobe(ctl_table *table, int write, struct file *filp,
+static int do_autoprobe(ctl_table *table, int write,
 			void __user *result, size_t *lenp, loff_t *ppos)
 {
 	struct parport_device_info *info = table->extra2;
@@ -111,7 +111,7 @@ static int do_autoprobe(ctl_table *table, int write, struct file *filp,
 #endif /* IEEE1284.3 support. */
 
 static int do_hardware_base_addr (ctl_table *table, int write,
-				  struct file *filp, void __user *result,
+				  void __user *result,
 				  size_t *lenp, loff_t *ppos)
 {
 	struct parport *port = (struct parport *)table->extra1;
@@ -139,7 +139,7 @@ static int do_hardware_base_addr (ctl_table *table, int write,
 }
 
 static int do_hardware_irq (ctl_table *table, int write,
-			    struct file *filp, void __user *result,
+			    void __user *result,
 			    size_t *lenp, loff_t *ppos)
 {
 	struct parport *port = (struct parport *)table->extra1;
@@ -167,7 +167,7 @@ static int do_hardware_irq (ctl_table *table, int write,
 }
 
 static int do_hardware_dma (ctl_table *table, int write,
-			    struct file *filp, void __user *result,
+			    void __user *result,
 			    size_t *lenp, loff_t *ppos)
 {
 	struct parport *port = (struct parport *)table->extra1;
@@ -195,7 +195,7 @@ static int do_hardware_dma (ctl_table *table, int write,
 }
 
 static int do_hardware_modes (ctl_table *table, int write,
-			      struct file *filp, void __user *result,
+			      void __user *result,
 			      size_t *lenp, loff_t *ppos)
 {
 	struct parport *port = (struct parport *)table->extra1;
--- a/fs/coda/coda_int.h
+++ b/fs/coda/coda_int.h
@@ -2,6 +2,7 @@
 #define _CODA_INT_
 
 struct dentry;
+struct file;
 
 extern struct file_system_type coda_fs_type;
 extern unsigned long coda_timeout;
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -63,9 +63,9 @@ static void drop_slab(void)
 }
 
 int drop_caches_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (write) {
 		if (sysctl_drop_caches & 1)
 			drop_pagecache();
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -74,14 +74,14 @@ EXPORT_SYMBOL_GPL(get_max_files);
  * Handle nr_files sysctl
  */
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
-int proc_nr_files(ctl_table *table, int write, struct file *filp,
+int proc_nr_files(ctl_table *table, int write,
                      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	files_stat.nr_files = get_nr_files();
-	return proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	return proc_dointvec(table, write, buffer, lenp, ppos);
 }
 #else
-int proc_nr_files(ctl_table *table, int write, struct file *filp,
+int proc_nr_files(ctl_table *table, int write,
                      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -153,7 +153,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 
 	/* careful: calling conventions are nasty here */
 	res = count;
-	error = table->proc_handler(table, write, filp, buf, &res, ppos);
+	error = table->proc_handler(table, write, buf, &res, ppos);
 	if (!error)
 		error = res;
 out:
--- a/fs/xfs/linux-2.6/xfs_sysctl.c
+++ b/fs/xfs/linux-2.6/xfs_sysctl.c
@@ -26,7 +26,6 @@ STATIC int
 xfs_stats_clear_proc_handler(
 	ctl_table	*ctl,
 	int		write,
-	struct file	*filp,
 	void		__user *buffer,
 	size_t		*lenp,
 	loff_t		*ppos)
@@ -34,7 +33,7 @@ xfs_stats_clear_proc_handler(
 	int		c, ret, *valp = ctl->data;
 	__uint32_t	vn_active;
 
-	ret = proc_dointvec_minmax(ctl, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
 
 	if (!ret && write && *valp) {
 		printk("XFS Clearing xfsstats\n");
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2454,7 +2454,7 @@ ssize_t simple_attr_write(struct file *file, const char __user *buf,
 			  size_t len, loff_t *ppos);
 
 struct ctl_table;
-int proc_nr_files(struct ctl_table *table, int write, struct file *filp,
+int proc_nr_files(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
 
 int __init get_filesystem_list(char *buf);
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -19,7 +19,7 @@
 extern int ftrace_enabled;
 extern int
 ftrace_enable_sysctl(struct ctl_table *table, int write,
-		     struct file *filp, void __user *buffer, size_t *lenp,
+		     void __user *buffer, size_t *lenp,
 		     loff_t *ppos);
 
 typedef void (*ftrace_func_t)(unsigned long ip, unsigned long parent_ip);
@@ -94,7 +94,7 @@ static inline void ftrace_start(void) { }
 extern int stack_tracer_enabled;
 int
 stack_trace_sysctl(struct ctl_table *table, int write,
-		   struct file *file, void __user *buffer, size_t *lenp,
+		   void __user *buffer, size_t *lenp,
 		   loff_t *ppos);
 #endif
 
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -19,9 +19,9 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 }
 
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
-int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
-int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
-int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
+int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
 void unmap_hugepage_range(struct vm_area_struct *,
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1274,7 +1274,7 @@ int in_gate_area_no_task(unsigned long addr);
 #define in_gate_area(task, addr) ({(void)task; in_gate_area_no_task(addr);})
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-int drop_caches_sysctl_handler(struct ctl_table *, int, struct file *,
+int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			unsigned long lru_pages);
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -744,21 +744,20 @@ static inline int is_dma(struct zone *zone)
 
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
-struct file;
-int min_free_kbytes_sysctl_handler(struct ctl_table *, int, struct file *, 
+int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
-int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int, struct file *,
+int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int, struct file *,
+int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
-			struct file *, void __user *, size_t *, loff_t *);
+			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
-			struct file *, void __user *, size_t *, loff_t *);
+			void __user *, size_t *, loff_t *);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
-			struct file *, void __user *, size_t *, loff_t *);
+			void __user *, size_t *, loff_t *);
 extern char numa_zonelist_order[];
 #define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
 
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -302,7 +302,7 @@ extern void softlockup_tick(void);
 extern void touch_softlockup_watchdog(void);
 extern void touch_all_softlockup_watchdogs(void);
 extern int proc_dosoftlockup_thresh(struct ctl_table *table, int write,
-				    struct file *filp, void __user *buffer,
+				    void __user *buffer,
 				    size_t *lenp, loff_t *ppos);
 extern unsigned int  softlockup_panic;
 extern int softlockup_thresh;
@@ -324,7 +324,7 @@ extern unsigned long sysctl_hung_task_check_count;
 extern unsigned long sysctl_hung_task_timeout_secs;
 extern unsigned long sysctl_hung_task_warnings;
 extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-					 struct file *filp, void __user *buffer,
+					 void __user *buffer,
 					 size_t *lenp, loff_t *ppos);
 #endif
 
@@ -1821,7 +1821,7 @@ extern unsigned int sysctl_sched_nr_migrate;
 extern unsigned int sysctl_timer_migration;
 
 int sched_nr_latency_handler(struct ctl_table *table, int write,
-		struct file *file, void __user *buffer, size_t *length,
+		void __user *buffer, size_t *length,
 		loff_t *ppos);
 #endif
 #ifdef CONFIG_SCHED_DEBUG
@@ -1839,7 +1839,7 @@ extern unsigned int sysctl_sched_rt_period;
 extern int sysctl_sched_rt_runtime;
 
 int sched_rt_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 
 extern unsigned int sysctl_sched_compat_yield;
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -133,7 +133,7 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 		return PAGE_ALIGN(mmap_min_addr);
 	return hint;
 }
-extern int mmap_min_addr_handler(struct ctl_table *table, int write, struct file *filp,
+extern int mmap_min_addr_handler(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp, loff_t *ppos);
 
 #ifdef CONFIG_SECURITY
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -240,7 +240,7 @@ extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
 
 extern unsigned long scan_unevictable_pages;
-extern int scan_unevictable_handler(struct ctl_table *, int, struct file *,
+extern int scan_unevictable_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int scan_unevictable_register_node(struct node *node);
 extern void scan_unevictable_unregister_node(struct node *node);
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -29,7 +29,6 @@
 #include <linux/types.h>
 #include <linux/compiler.h>
 
-struct file;
 struct completion;
 
 #define CTL_MAXNAME 10		/* how many path components do we allow in a
@@ -977,25 +976,25 @@ typedef int ctl_handler (struct ctl_table *table,
 			 void __user *oldval, size_t __user *oldlenp,
 			 void __user *newval, size_t newlen);
 
-typedef int proc_handler (struct ctl_table *ctl, int write, struct file * filp,
+typedef int proc_handler (struct ctl_table *ctl, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos);
 
-extern int proc_dostring(struct ctl_table *, int, struct file *,
+extern int proc_dostring(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
-extern int proc_dointvec(struct ctl_table *, int, struct file *,
+extern int proc_dointvec(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
-extern int proc_dointvec_minmax(struct ctl_table *, int, struct file *,
+extern int proc_dointvec_minmax(struct ctl_table *, int,
 				void __user *, size_t *, loff_t *);
-extern int proc_dointvec_jiffies(struct ctl_table *, int, struct file *,
+extern int proc_dointvec_jiffies(struct ctl_table *, int,
 				 void __user *, size_t *, loff_t *);
-extern int proc_dointvec_userhz_jiffies(struct ctl_table *, int, struct file *,
+extern int proc_dointvec_userhz_jiffies(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-extern int proc_dointvec_ms_jiffies(struct ctl_table *, int, struct file *,
+extern int proc_dointvec_ms_jiffies(struct ctl_table *, int,
 				    void __user *, size_t *, loff_t *);
-extern int proc_doulongvec_minmax(struct ctl_table *, int, struct file *,
+extern int proc_doulongvec_minmax(struct ctl_table *, int,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
-				      struct file *, void __user *, size_t *, loff_t *);
+				      void __user *, size_t *, loff_t *);
 
 extern int do_sysctl (int __user *name, int nlen,
 		      void __user *oldval, size_t __user *oldlenp,
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -117,21 +117,20 @@ extern int laptop_mode;
 extern unsigned long determine_dirtyable_memory(void);
 
 extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 extern int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 extern int dirty_ratio_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 extern int dirty_bytes_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
 
 struct ctl_table;
-struct file;
-int dirty_writeback_centisecs_handler(struct ctl_table *, int, struct file *,
+int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
 
 void get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -399,7 +399,7 @@ extern void	ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
  * fed into the routing cache should use these handlers.
  */
 int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 struct file* filp, void __user *buffer,
+			 void __user *buffer,
 			 size_t *lenp, loff_t *ppos);
 int ipv4_doint_and_flush_strategy(ctl_table *table,
 				  void __user *oldval, size_t __user *oldlenp,
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -55,7 +55,6 @@ enum {
 #include <net/neighbour.h>
 
 struct ctl_table;
-struct file;
 struct inet6_dev;
 struct net_device;
 struct net_proto_family;
@@ -139,7 +138,6 @@ extern int			igmp6_event_report(struct sk_buff *skb);
 #ifdef CONFIG_SYSCTL
 extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
 							   int write,
-							   struct file * filp,
 							   void __user *buffer,
 							   size_t *lenp,
 							   loff_t *ppos);
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -27,18 +27,18 @@ static void *get_ipc(ctl_table *table)
 }
 
 #ifdef CONFIG_PROC_SYSCTL
-static int proc_ipc_dointvec(ctl_table *table, int write, struct file *filp,
+static int proc_ipc_dointvec(ctl_table *table, int write,
 	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table ipc_table;
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
-	return proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
+	return proc_dointvec(&ipc_table, write, buffer, lenp, ppos);
 }
 
 static int proc_ipc_callback_dointvec(ctl_table *table, int write,
-	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table ipc_table;
 	size_t lenp_bef = *lenp;
@@ -47,7 +47,7 @@ static int proc_ipc_callback_dointvec(ctl_table *table, int write,
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
-	rc = proc_dointvec(&ipc_table, write, filp, buffer, lenp, ppos);
+	rc = proc_dointvec(&ipc_table, write, buffer, lenp, ppos);
 
 	if (write && !rc && lenp_bef == *lenp)
 		/*
@@ -61,13 +61,13 @@ static int proc_ipc_callback_dointvec(ctl_table *table, int write,
 }
 
 static int proc_ipc_doulongvec_minmax(ctl_table *table, int write,
-	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table ipc_table;
 	memcpy(&ipc_table, table, sizeof(ipc_table));
 	ipc_table.data = get_ipc(table);
 
-	return proc_doulongvec_minmax(&ipc_table, write, filp, buffer,
+	return proc_doulongvec_minmax(&ipc_table, write, buffer,
 					lenp, ppos);
 }
 
@@ -95,7 +95,7 @@ static void ipc_auto_callback(int val)
 }
 
 static int proc_ipcauto_dointvec_minmax(ctl_table *table, int write,
-	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table ipc_table;
 	size_t lenp_bef = *lenp;
@@ -106,7 +106,7 @@ static int proc_ipcauto_dointvec_minmax(ctl_table *table, int write,
 	ipc_table.data = get_ipc(table);
 	oldval = *((int *)(ipc_table.data));
 
-	rc = proc_dointvec_minmax(&ipc_table, write, filp, buffer, lenp, ppos);
+	rc = proc_dointvec_minmax(&ipc_table, write, buffer, lenp, ppos);
 
 	if (write && !rc && lenp_bef == *lenp) {
 		int newval = *((int *)(ipc_table.data));
--- a/ipc/mq_sysctl.c
+++ b/ipc/mq_sysctl.c
@@ -31,24 +31,24 @@ static void *get_mq(ctl_table *table)
 	return which;
 }
 
-static int proc_mq_dointvec(ctl_table *table, int write, struct file *filp,
+static int proc_mq_dointvec(ctl_table *table, int write,
 	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table mq_table;
 	memcpy(&mq_table, table, sizeof(mq_table));
 	mq_table.data = get_mq(table);
 
-	return proc_dointvec(&mq_table, write, filp, buffer, lenp, ppos);
+	return proc_dointvec(&mq_table, write, buffer, lenp, ppos);
 }
 
 static int proc_mq_dointvec_minmax(ctl_table *table, int write,
-	struct file *filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+	void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table mq_table;
 	memcpy(&mq_table, table, sizeof(mq_table));
 	mq_table.data = get_mq(table);
 
-	return proc_dointvec_minmax(&mq_table, write, filp, buffer,
+	return proc_dointvec_minmax(&mq_table, write, buffer,
 					lenp, ppos);
 }
 #else
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -171,12 +171,12 @@ static unsigned long timeout_jiffies(unsigned long timeout)
  * Process updating of timeout sysctl
  */
 int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-				  struct file *filp, void __user *buffer,
+				  void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
 {
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 
 	if (ret || !write)
 		goto out;
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -10157,7 +10157,7 @@ static int sched_rt_global_constraints(void)
 #endif /* CONFIG_RT_GROUP_SCHED */
 
 int sched_rt_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int ret;
@@ -10168,7 +10168,7 @@ int sched_rt_handler(struct ctl_table *table, int write,
 	old_period = sysctl_sched_rt_period;
 	old_runtime = sysctl_sched_rt_runtime;
 
-	ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
 
 	if (!ret && write) {
 		ret = sched_rt_global_constraints();
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -376,10 +376,10 @@ static struct sched_entity *__pick_last_entity(struct cfs_rq *cfs_rq)
 
 #ifdef CONFIG_SCHED_DEBUG
 int sched_nr_latency_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
-	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 
 	if (ret || !write)
 		return ret;
--- a/kernel/slow-work.c
+++ b/kernel/slow-work.c
@@ -26,10 +26,10 @@ static void slow_work_cull_timeout(unsigned long);
 static void slow_work_oom_timeout(unsigned long);
 
 #ifdef CONFIG_SYSCTL
-static int slow_work_min_threads_sysctl(struct ctl_table *, int, struct file *,
+static int slow_work_min_threads_sysctl(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 
-static int slow_work_max_threads_sysctl(struct ctl_table *, int , struct file *,
+static int slow_work_max_threads_sysctl(struct ctl_table *, int ,
 					void __user *, size_t *, loff_t *);
 #endif
 
@@ -493,10 +493,10 @@ static void slow_work_oom_timeout(unsigned long data)
  * Handle adjustment of the minimum number of threads
  */
 static int slow_work_min_threads_sysctl(struct ctl_table *table, int write,
-					struct file *filp, void __user *buffer,
+					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
-	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	int n;
 
 	if (ret == 0) {
@@ -521,10 +521,10 @@ static int slow_work_min_threads_sysctl(struct ctl_table *table, int write,
  * Handle adjustment of the maximum number of threads
  */
 static int slow_work_max_threads_sysctl(struct ctl_table *table, int write,
-					struct file *filp, void __user *buffer,
+					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
-	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	int n;
 
 	if (ret == 0) {
--- a/kernel/softlockup.c
+++ b/kernel/softlockup.c
@@ -90,11 +90,11 @@ void touch_all_softlockup_watchdogs(void)
 EXPORT_SYMBOL(touch_all_softlockup_watchdogs);
 
 int proc_dosoftlockup_thresh(struct ctl_table *table, int write,
-			     struct file *filp, void __user *buffer,
+			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
 	touch_all_softlockup_watchdogs();
-	return proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	return proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 }
 
 /*
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -158,9 +158,9 @@ extern int max_lock_depth;
 #endif
 
 #ifdef CONFIG_PROC_SYSCTL
-static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp,
+static int proc_do_cad_pid(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
-static int proc_taint(struct ctl_table *table, int write, struct file *filp,
+static int proc_taint(struct ctl_table *table, int write,
 			       void __user *buffer, size_t *lenp, loff_t *ppos);
 #endif
 
@@ -2185,7 +2185,7 @@ void sysctl_head_put(struct ctl_table_header *head)
 #ifdef CONFIG_PROC_SYSCTL
 
 static int _proc_do_string(void* data, int maxlen, int write,
-			   struct file *filp, void __user *buffer,
+			   void __user *buffer,
 			   size_t *lenp, loff_t *ppos)
 {
 	size_t len;
@@ -2246,7 +2246,6 @@ static int _proc_do_string(void* data, int maxlen, int write,
  * proc_dostring - read a string sysctl
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2260,10 +2259,10 @@ static int _proc_do_string(void* data, int maxlen, int write,
  *
  * Returns 0 on success.
  */
-int proc_dostring(struct ctl_table *table, int write, struct file *filp,
+int proc_dostring(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return _proc_do_string(table->data, table->maxlen, write, filp,
+	return _proc_do_string(table->data, table->maxlen, write,
 			       buffer, lenp, ppos);
 }
 
@@ -2288,7 +2287,7 @@ static int do_proc_dointvec_conv(int *negp, unsigned long *lvalp,
 }
 
 static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
-		  int write, struct file *filp, void __user *buffer,
+		  int write, void __user *buffer,
 		  size_t *lenp, loff_t *ppos,
 		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
@@ -2395,13 +2394,13 @@ static int __do_proc_dointvec(void *tbl_data, struct ctl_table *table,
 #undef TMPBUFLEN
 }
 
-static int do_proc_dointvec(struct ctl_table *table, int write, struct file *filp,
+static int do_proc_dointvec(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos,
 		  int (*conv)(int *negp, unsigned long *lvalp, int *valp,
 			      int write, void *data),
 		  void *data)
 {
-	return __do_proc_dointvec(table->data, table, write, filp,
+	return __do_proc_dointvec(table->data, table, write,
 			buffer, lenp, ppos, conv, data);
 }
 
@@ -2409,7 +2408,6 @@ static int do_proc_dointvec(struct ctl_table *table, int write, struct file *fil
  * proc_dointvec - read a vector of integers
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2419,10 +2417,10 @@ static int do_proc_dointvec(struct ctl_table *table, int write, struct file *fil
  *
  * Returns 0 on success.
  */
-int proc_dointvec(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-    return do_proc_dointvec(table,write,filp,buffer,lenp,ppos,
+    return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    NULL,NULL);
 }
 
@@ -2430,7 +2428,7 @@ int proc_dointvec(struct ctl_table *table, int write, struct file *filp,
  * Taint values can only be increased
  * This means we can safely use a temporary.
  */
-static int proc_taint(struct ctl_table *table, int write, struct file *filp,
+static int proc_taint(struct ctl_table *table, int write,
 			       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table t;
@@ -2442,7 +2440,7 @@ static int proc_taint(struct ctl_table *table, int write, struct file *filp,
 
 	t = *table;
 	t.data = &tmptaint;
-	err = proc_doulongvec_minmax(&t, write, filp, buffer, lenp, ppos);
+	err = proc_doulongvec_minmax(&t, write, buffer, lenp, ppos);
 	if (err < 0)
 		return err;
 
@@ -2494,7 +2492,6 @@ static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp,
  * proc_dointvec_minmax - read a vector of integers with min/max values
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2507,19 +2504,18 @@ static int do_proc_dointvec_minmax_conv(int *negp, unsigned long *lvalp,
  *
  * Returns 0 on success.
  */
-int proc_dointvec_minmax(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_minmax(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct do_proc_dointvec_minmax_conv_param param = {
 		.min = (int *) table->extra1,
 		.max = (int *) table->extra2,
 	};
-	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+	return do_proc_dointvec(table, write, buffer, lenp, ppos,
 				do_proc_dointvec_minmax_conv, &param);
 }
 
 static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int write,
-				     struct file *filp,
 				     void __user *buffer,
 				     size_t *lenp, loff_t *ppos,
 				     unsigned long convmul,
@@ -2624,21 +2620,19 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
 }
 
 static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
-				     struct file *filp,
 				     void __user *buffer,
 				     size_t *lenp, loff_t *ppos,
 				     unsigned long convmul,
 				     unsigned long convdiv)
 {
 	return __do_proc_doulongvec_minmax(table->data, table, write,
-			filp, buffer, lenp, ppos, convmul, convdiv);
+			buffer, lenp, ppos, convmul, convdiv);
 }
 
 /**
  * proc_doulongvec_minmax - read a vector of long integers with min/max values
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2651,17 +2645,16 @@ static int do_proc_doulongvec_minmax(struct ctl_table *table, int write,
  *
  * Returns 0 on success.
  */
-int proc_doulongvec_minmax(struct ctl_table *table, int write, struct file *filp,
+int proc_doulongvec_minmax(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-    return do_proc_doulongvec_minmax(table, write, filp, buffer, lenp, ppos, 1l, 1l);
+    return do_proc_doulongvec_minmax(table, write, buffer, lenp, ppos, 1l, 1l);
 }
 
 /**
  * proc_doulongvec_ms_jiffies_minmax - read a vector of millisecond values with min/max values
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2676,11 +2669,10 @@ int proc_doulongvec_minmax(struct ctl_table *table, int write, struct file *filp
  * Returns 0 on success.
  */
 int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
-				      struct file *filp,
 				      void __user *buffer,
 				      size_t *lenp, loff_t *ppos)
 {
-    return do_proc_doulongvec_minmax(table, write, filp, buffer,
+    return do_proc_doulongvec_minmax(table, write, buffer,
 				     lenp, ppos, HZ, 1000l);
 }
 
@@ -2756,7 +2748,6 @@ static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
  * proc_dointvec_jiffies - read a vector of integers as seconds
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2768,10 +2759,10 @@ static int do_proc_dointvec_ms_jiffies_conv(int *negp, unsigned long *lvalp,
  *
  * Returns 0 on success.
  */
-int proc_dointvec_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_jiffies(struct ctl_table *table, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-    return do_proc_dointvec(table,write,filp,buffer,lenp,ppos,
+    return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    do_proc_dointvec_jiffies_conv,NULL);
 }
 
@@ -2779,7 +2770,6 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write, struct file *filp,
  * proc_dointvec_userhz_jiffies - read a vector of integers as 1/USER_HZ seconds
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: pointer to the file position
@@ -2791,10 +2781,10 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write, struct file *filp,
  *
  * Returns 0 on success.
  */
-int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-    return do_proc_dointvec(table,write,filp,buffer,lenp,ppos,
+    return do_proc_dointvec(table,write,buffer,lenp,ppos,
 		    	    do_proc_dointvec_userhz_jiffies_conv,NULL);
 }
 
@@ -2802,7 +2792,6 @@ int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write, struct file
  * proc_dointvec_ms_jiffies - read a vector of integers as 1 milliseconds
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
- * @filp: the file structure
  * @buffer: the user buffer
  * @lenp: the size of the user buffer
  * @ppos: file position
@@ -2815,14 +2804,14 @@ int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write, struct file
  *
  * Returns 0 on success.
  */
-int proc_dointvec_ms_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_ms_jiffies(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+	return do_proc_dointvec(table, write, buffer, lenp, ppos,
 				do_proc_dointvec_ms_jiffies_conv, NULL);
 }
 
-static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp,
+static int proc_do_cad_pid(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct pid *new_pid;
@@ -2831,7 +2820,7 @@ static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp
 
 	tmp = pid_vnr(cad_pid);
 
-	r = __do_proc_dointvec(&tmp, table, write, filp, buffer,
+	r = __do_proc_dointvec(&tmp, table, write, buffer,
 			       lenp, ppos, NULL, NULL);
 	if (r || !write)
 		return r;
@@ -2846,50 +2835,49 @@ static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp
 
 #else /* CONFIG_PROC_FS */
 
-int proc_dostring(struct ctl_table *table, int write, struct file *filp,
+int proc_dostring(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_dointvec(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_dointvec_minmax(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_minmax(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_dointvec_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_jiffies(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_dointvec_ms_jiffies(struct ctl_table *table, int write, struct file *filp,
+int proc_dointvec_ms_jiffies(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
-int proc_doulongvec_minmax(struct ctl_table *table, int write, struct file *filp,
+int proc_doulongvec_minmax(struct ctl_table *table, int write,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	return -ENOSYS;
 }
 
 int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
-				      struct file *filp,
 				      void __user *buffer,
 				      size_t *lenp, loff_t *ppos)
 {
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -3156,7 +3156,7 @@ int unregister_ftrace_function(struct ftrace_ops *ops)
 
 int
 ftrace_enable_sysctl(struct ctl_table *table, int write,
-		     struct file *file, void __user *buffer, size_t *lenp,
+		     void __user *buffer, size_t *lenp,
 		     loff_t *ppos)
 {
 	int ret;
@@ -3166,7 +3166,7 @@ ftrace_enable_sysctl(struct ctl_table *table, int write,
 
 	mutex_lock(&ftrace_lock);
 
-	ret  = proc_dointvec(table, write, file, buffer, lenp, ppos);
+	ret  = proc_dointvec(table, write, buffer, lenp, ppos);
 
 	if (ret || !write || (last_ftrace_enabled == !!ftrace_enabled))
 		goto out;
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -313,14 +313,14 @@ static const struct file_operations stack_trace_fops = {
 
 int
 stack_trace_sysctl(struct ctl_table *table, int write,
-		   struct file *file, void __user *buffer, size_t *lenp,
+		   void __user *buffer, size_t *lenp,
 		   loff_t *ppos)
 {
 	int ret;
 
 	mutex_lock(&stack_sysctl_mutex);
 
-	ret = proc_dointvec(table, write, file, buffer, lenp, ppos);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
 
 	if (ret || !write ||
 	    (last_stack_tracer_enabled == !!stack_tracer_enabled))
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -42,14 +42,14 @@ static void put_uts(ctl_table *table, int write, void *which)
  *	Special case of dostring for the UTS structure. This has locks
  *	to observe. Should this be in kernel/sys.c ????
  */
-static int proc_do_uts_string(ctl_table *table, int write, struct file *filp,
+static int proc_do_uts_string(ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct ctl_table uts_table;
 	int r;
 	memcpy(&uts_table, table, sizeof(uts_table));
 	uts_table.data = get_uts(table, write);
-	r = proc_dostring(&uts_table,write,filp,buffer,lenp, ppos);
+	r = proc_dostring(&uts_table,write,buffer,lenp, ppos);
 	put_uts(table, write, uts_table.data);
 	return r;
 }
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1505,7 +1505,7 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 
 #ifdef CONFIG_SYSCTL
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
-			   struct file *file, void __user *buffer,
+			   void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
@@ -1516,7 +1516,7 @@ int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write)
 		h->max_huge_pages = set_max_huge_pages(h, tmp);
@@ -1525,10 +1525,10 @@ int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 }
 
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
-			struct file *file, void __user *buffer,
+			void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, file, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
 	else
@@ -1537,7 +1537,7 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 }
 
 int hugetlb_overcommit_handler(struct ctl_table *table, int write,
-			struct file *file, void __user *buffer,
+			void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
@@ -1548,7 +1548,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write) {
 		spin_lock(&hugetlb_lock);
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -166,37 +166,37 @@ static void update_completion_period(void)
 }
 
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write)
 		dirty_background_bytes = 0;
 	return ret;
 }
 
 int dirty_background_bytes_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write)
 		dirty_background_ratio = 0;
 	return ret;
 }
 
 int dirty_ratio_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	int old_ratio = vm_dirty_ratio;
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
 		update_completion_period();
 		vm_dirty_bytes = 0;
@@ -206,13 +206,13 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 
 
 int dirty_bytes_handler(struct ctl_table *table, int write,
-		struct file *filp, void __user *buffer, size_t *lenp,
+		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
 	unsigned long old_bytes = vm_dirty_bytes;
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
 		update_completion_period();
 		vm_dirty_ratio = 0;
@@ -803,9 +803,9 @@ static void wb_kupdate(unsigned long arg)
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
 int dirty_writeback_centisecs_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, file, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos);
 	if (dirty_writeback_interval)
 		mod_timer(&wb_timer, jiffies +
 			msecs_to_jiffies(dirty_writeback_interval * 10));
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2303,7 +2303,7 @@ early_param("numa_zonelist_order", setup_numa_zonelist_order);
  * sysctl handler for numa_zonelist_order
  */
 int numa_zonelist_order_handler(ctl_table *table, int write,
-		struct file *file, void __user *buffer, size_t *length,
+		void __user *buffer, size_t *length,
 		loff_t *ppos)
 {
 	char saved_string[NUMA_ZONELIST_ORDER_LEN];
@@ -2312,7 +2312,7 @@ int numa_zonelist_order_handler(ctl_table *table, int write,
 	if (write)
 		strncpy(saved_string, (char*)table->data,
 			NUMA_ZONELIST_ORDER_LEN);
-	ret = proc_dostring(table, write, file, buffer, length, ppos);
+	ret = proc_dostring(table, write, buffer, length, ppos);
 	if (ret)
 		return ret;
 	if (write) {
@@ -4598,9 +4598,9 @@ module_init(init_per_zone_wmark_min)
  *	changes.
  */
 int min_free_kbytes_sysctl_handler(ctl_table *table, int write, 
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec(table, write, file, buffer, length, ppos);
+	proc_dointvec(table, write, buffer, length, ppos);
 	if (write)
 		setup_per_zone_wmarks();
 	return 0;
@@ -4608,12 +4608,12 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 
 #ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
 	int rc;
 
-	rc = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (rc)
 		return rc;
 
@@ -4624,12 +4624,12 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 }
 
 int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
 	int rc;
 
-	rc = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (rc)
 		return rc;
 
@@ -4650,9 +4650,9 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
  * if in function of the boot time zone sizes.
  */
 int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	proc_dointvec_minmax(table, write, buffer, length, ppos);
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
@@ -4664,13 +4664,13 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
  */
 
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
 	unsigned int cpu;
 	int ret;
 
-	ret = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (!write || (ret == -EINVAL))
 		return ret;
 	for_each_populated_zone(zone) {
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2707,10 +2707,10 @@ static void scan_all_zones_unevictable_pages(void)
 unsigned long scan_unevictable_pages;
 
 int scan_unevictable_handler(struct ctl_table *table, int write,
-			   struct file *file, void __user *buffer,
+			   void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	proc_doulongvec_minmax(table, write, buffer, length, ppos);
 
 	if (write && *(unsigned long *)table->data)
 		scan_all_zones_unevictable_pages();
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -949,12 +949,12 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 
 #ifdef CONFIG_SYSCTL
 static
-int brnf_sysctl_call_tables(ctl_table * ctl, int write, struct file *filp,
+int brnf_sysctl_call_tables(ctl_table * ctl, int write,
 			    void __user * buffer, size_t * lenp, loff_t * ppos)
 {
 	int ret;
 
-	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write && *(int *)(ctl->data))
 		*(int *)(ctl->data) = 1;
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -164,7 +164,7 @@ static int max_t3[] = { 8191 }; /* Must fit in 16 bits when multiplied by BCT3MU
 static int min_priority[1];
 static int max_priority[] = { 127 }; /* From DECnet spec */
 
-static int dn_forwarding_proc(ctl_table *, int, struct file *,
+static int dn_forwarding_proc(ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 static int dn_forwarding_sysctl(ctl_table *table,
 			void __user *oldval, size_t __user *oldlenp,
@@ -274,7 +274,6 @@ static void dn_dev_sysctl_unregister(struct dn_dev_parms *parms)
 }
 
 static int dn_forwarding_proc(ctl_table *table, int write,
-				struct file *filep,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
@@ -290,7 +289,7 @@ static int dn_forwarding_proc(ctl_table *table, int write,
 	dn_db = dev->dn_ptr;
 	old = dn_db->parms.forwarding;
 
-	err = proc_dointvec(table, write, filep, buffer, lenp, ppos);
+	err = proc_dointvec(table, write, buffer, lenp, ppos);
 
 	if ((err >= 0) && write) {
 		if (dn_db->parms.forwarding < 0)
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -165,7 +165,6 @@ static int dn_node_address_strategy(ctl_table *table,
 }
 
 static int dn_node_address_handler(ctl_table *table, int write,
-				struct file *filp,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
@@ -276,7 +275,6 @@ static int dn_def_dev_strategy(ctl_table *table,
 
 
 static int dn_def_dev_handler(ctl_table *table, int write,
-				struct file * filp,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1264,10 +1264,10 @@ static void inet_forward_change(struct net *net)
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
-			     struct file *filp, void __user *buffer,
+			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
-	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write) {
 		struct ipv4_devconf *cnf = ctl->extra1;
@@ -1336,12 +1336,12 @@ static int devinet_conf_sysctl(ctl_table *table,
 }
 
 static int devinet_sysctl_forward(ctl_table *ctl, int write,
-				  struct file *filp, void __user *buffer,
+				  void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
-	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write && *valp != val) {
 		struct net *net = ctl->extra2;
@@ -1366,12 +1366,12 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 }
 
 int ipv4_doint_and_flush(ctl_table *ctl, int write,
-			 struct file *filp, void __user *buffer,
+			 void __user *buffer,
 			 size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
-	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 	struct net *net = ctl->extra2;
 
 	if (write && *valp != val)
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3034,7 +3034,7 @@ void ip_rt_multicast_event(struct in_device *in_dev)
 
 #ifdef CONFIG_SYSCTL
 static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
-					struct file *filp, void __user *buffer,
+					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
 	if (write) {
@@ -3044,7 +3044,7 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 
 		memcpy(&ctl, __ctl, sizeof(ctl));
 		ctl.data = &flush_delay;
-		proc_dointvec(&ctl, write, filp, buffer, lenp, ppos);
+		proc_dointvec(&ctl, write, buffer, lenp, ppos);
 
 		net = (struct net *)__ctl->extra1;
 		rt_cache_flush(net, flush_delay);
@@ -3104,12 +3104,11 @@ static void rt_secret_reschedule(int old)
 }
 
 static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
-					  struct file *filp,
 					  void __user *buffer, size_t *lenp,
 					  loff_t *ppos)
 {
 	int old = ip_rt_secret_interval;
-	int ret = proc_dointvec_jiffies(ctl, write, filp, buffer, lenp, ppos);
+	int ret = proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
 
 	rt_secret_reschedule(old);
 
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -36,7 +36,7 @@ static void set_local_port_range(int range[2])
 }
 
 /* Validate changes from /proc interface. */
-static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
+static int ipv4_local_port_range(ctl_table *table, int write,
 				 void __user *buffer,
 				 size_t *lenp, loff_t *ppos)
 {
@@ -51,7 +51,7 @@ static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
 	};
 
 	inet_get_local_port_range(range, range + 1);
-	ret = proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
 		if (range[1] < range[0])
@@ -91,7 +91,7 @@ static int ipv4_sysctl_local_port_range(ctl_table *table,
 }
 
 
-static int proc_tcp_congestion_control(ctl_table *ctl, int write, struct file * filp,
+static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char val[TCP_CA_NAME_MAX];
@@ -103,7 +103,7 @@ static int proc_tcp_congestion_control(ctl_table *ctl, int write, struct file *
 
 	tcp_get_default_congestion_control(val);
 
-	ret = proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
 	if (write && ret == 0)
 		ret = tcp_set_default_congestion_control(val);
 	return ret;
@@ -129,7 +129,7 @@ static int sysctl_tcp_congestion_control(ctl_table *table,
 }
 
 static int proc_tcp_available_congestion_control(ctl_table *ctl,
-						 int write, struct file * filp,
+						 int write,
 						 void __user *buffer, size_t *lenp,
 						 loff_t *ppos)
 {
@@ -140,13 +140,13 @@ static int proc_tcp_available_congestion_control(ctl_table *ctl,
 	if (!tbl.data)
 		return -ENOMEM;
 	tcp_get_available_congestion_control(tbl.data, TCP_CA_BUF_MAX);
-	ret = proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
 	kfree(tbl.data);
 	return ret;
 }
 
 static int proc_allowed_congestion_control(ctl_table *ctl,
-					   int write, struct file * filp,
+					   int write,
 					   void __user *buffer, size_t *lenp,
 					   loff_t *ppos)
 {
@@ -158,7 +158,7 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 		return -ENOMEM;
 
 	tcp_get_allowed_congestion_control(tbl.data, tbl.maxlen);
-	ret = proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
 	if (write && ret == 0)
 		ret = tcp_set_allowed_congestion_control(tbl.data);
 	kfree(tbl.data);
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3965,14 +3965,14 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 #ifdef CONFIG_SYSCTL
 
 static
-int addrconf_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
+int addrconf_sysctl_forward(ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	int ret;
 
-	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write)
 		ret = addrconf_fixup_forwarding(ctl, valp, val);
@@ -4069,14 +4069,14 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
 }
 
 static
-int addrconf_sysctl_disable(ctl_table *ctl, int write, struct file * filp,
+int addrconf_sysctl_disable(ctl_table *ctl, int write,
 			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	int ret;
 
-	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write)
 		ret = addrconf_disable_ipv6(ctl, valp, val);
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1733,7 +1733,7 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 	}
 }
 
-int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * filp, void __user *buffer, size_t *lenp, loff_t *ppos)
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
@@ -1744,16 +1744,16 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * f
 		ndisc_warn_deprecated_sysctl(ctl, "syscall", dev ? dev->name : "default");
 
 	if (strcmp(ctl->procname, "retrans_time") == 0)
-		ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+		ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	else if (strcmp(ctl->procname, "base_reachable_time") == 0)
 		ret = proc_dointvec_jiffies(ctl, write,
-					    filp, buffer, lenp, ppos);
+					    buffer, lenp, ppos);
 
 	else if ((strcmp(ctl->procname, "retrans_time_ms") == 0) ||
 		 (strcmp(ctl->procname, "base_reachable_time_ms") == 0))
 		ret = proc_dointvec_ms_jiffies(ctl, write,
-					       filp, buffer, lenp, ppos);
+					       buffer, lenp, ppos);
 	else
 		ret = -1;
 
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2524,13 +2524,13 @@ static const struct file_operations rt6_stats_seq_fops = {
 #ifdef CONFIG_SYSCTL
 
 static
-int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write, struct file * filp,
+int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 			      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
 	int delay = net->ipv6.sysctl.flush_delay;
 	if (write) {
-		proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+		proc_dointvec(ctl, write, buffer, lenp, ppos);
 		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
 		return 0;
 	} else
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -73,12 +73,12 @@ static int min_lap_keepalive_time = 100;	/* 100us */
 /* For other sysctl, I've no idea of the range. Maybe Dag could help
  * us on that - Jean II */
 
-static int do_devname(ctl_table *table, int write, struct file *filp,
+static int do_devname(ctl_table *table, int write,
 		      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int ret;
 
-	ret = proc_dostring(table, write, filp, buffer, lenp, ppos);
+	ret = proc_dostring(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write) {
 		struct ias_value *val;
 
@@ -90,12 +90,12 @@ static int do_devname(ctl_table *table, int write, struct file *filp,
 }
 
 
-static int do_discovery(ctl_table *table, int write, struct file *filp,
+static int do_discovery(ctl_table *table, int write,
                     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
        int ret;
 
-       ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+       ret = proc_dointvec(table, write, buffer, lenp, ppos);
        if (ret)
 	       return ret;
 
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1495,14 +1495,14 @@ static int ip_vs_zero_all(void)
 
 
 static int
-proc_do_defense_mode(ctl_table *table, int write, struct file * filp,
+proc_do_defense_mode(ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
 
-	rc = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	rc = proc_dointvec(table, write, buffer, lenp, ppos);
 	if (write && (*valp != val)) {
 		if ((*valp < 0) || (*valp > 3)) {
 			/* Restore the correct value */
@@ -1516,7 +1516,7 @@ proc_do_defense_mode(ctl_table *table, int write, struct file * filp,
 
 
 static int
-proc_do_sync_threshold(ctl_table *table, int write, struct file *filp,
+proc_do_sync_threshold(ctl_table *table, int write,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = table->data;
@@ -1526,7 +1526,7 @@ proc_do_sync_threshold(ctl_table *table, int write, struct file *filp,
 	/* backup the value first */
 	memcpy(val, valp, sizeof(val));
 
-	rc = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+	rc = proc_dointvec(table, write, buffer, lenp, ppos);
 	if (write && (valp[0] < 0 || valp[1] < 0 || valp[0] >= valp[1])) {
 		/* Restore the correct value */
 		memcpy(valp, val, sizeof(val));
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -226,7 +226,7 @@ static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 static struct ctl_table_header *nf_log_dir_header;
 
-static int nf_log_proc_dostring(ctl_table *table, int write, struct file *filp,
+static int nf_log_proc_dostring(ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	const struct nf_logger *logger;
@@ -260,7 +260,7 @@ static int nf_log_proc_dostring(ctl_table *table, int write, struct file *filp,
 			table->data = "NONE";
 		else
 			table->data = logger->name;
-		r = proc_dostring(table, write, filp, buffer, lenp, ppos);
+		r = proc_dostring(table, write, buffer, lenp, ppos);
 		mutex_unlock(&nf_log_mutex);
 	}
 
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -56,7 +56,7 @@ void phonet_get_local_port_range(int *min, int *max)
 	} while (read_seqretry(&local_port_range_lock, seq));
 }
 
-static int proc_local_port_range(ctl_table *table, int write, struct file *filp,
+static int proc_local_port_range(ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
@@ -70,7 +70,7 @@ static int proc_local_port_range(ctl_table *table, int write, struct file *filp,
 		.extra2 = &local_port_range_max,
 	};
 
-	ret = proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
 		if (range[1] < range[0])
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -56,7 +56,7 @@ rpc_unregister_sysctl(void)
 	}
 }
 
-static int proc_do_xprt(ctl_table *table, int write, struct file *file,
+static int proc_do_xprt(ctl_table *table, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char tmpbuf[256];
@@ -71,7 +71,7 @@ static int proc_do_xprt(ctl_table *table, int write, struct file *file,
 }
 
 static int
-proc_dodebug(ctl_table *table, int write, struct file *file,
+proc_dodebug(ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char		tmpbuf[20], c, *s;
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -80,7 +80,7 @@ struct kmem_cache *svc_rdma_ctxt_cachep;
  * current value.
  */
 static int read_reset_stat(ctl_table *table, int write,
-			   struct file *filp, void __user *buffer, size_t *lenp,
+			   void __user *buffer, size_t *lenp,
 			   loff_t *ppos)
 {
 	atomic_t *stat = (atomic_t *)table->data;
--- a/security/min_addr.c
+++ b/security/min_addr.c
@@ -28,12 +28,12 @@ static void update_mmap_min_addr(void)
  * sysctl handler which just sets dac_mmap_min_addr = the new value and then
  * calls update_mmap_min_addr() so non MAP_FIXED hints get rounded properly
  */
-int mmap_min_addr_handler(struct ctl_table *table, int write, struct file *filp,
+int mmap_min_addr_handler(struct ctl_table *table, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int ret;
 
-	ret = proc_doulongvec_minmax(table, write, filp, buffer, lenp, ppos);
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 
 	update_mmap_min_addr();
 
