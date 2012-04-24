From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] isdn/eicon: use standard __init,__exit function markup
Date: Tue, 24 Apr 2012 15:56:03 -0700
Message-ID: <201204241556.03516.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mac@melware.de>, <isdn@linux-pingi.de>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail209.messagelabs.com ([216.82.255.3]:59169 "EHLO
	mail209.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758397Ab2DXW4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 18:56:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the custom DIVA_{INIT,EXIT}_FUNCTION defines and use
the standard __init,__exit markup.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>

---

diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hardware/eicon/capifunc.c
index a576f32..7a0bdbd 100644
--- a/drivers/isdn/hardware/eicon/capifunc.c
+++ b/drivers/isdn/hardware/eicon/capifunc.c
@@ -1120,7 +1120,7 @@ int fax_head_line_time(char *buffer)
 /*
  * init (alloc) main structures
  */
-static int DIVA_INIT_FUNCTION init_main_structs(void)
+static int __init init_main_structs(void)
 {
 	if (!(mapped_msg = (CAPI_MSG *) diva_os_malloc(0, MAX_MSG_SIZE))) {
 		DBG_ERR(("init: failed alloc mapped_msg."))
@@ -1181,7 +1181,7 @@ static void do_api_remove_start(void)
 /*
  * init
  */
-int DIVA_INIT_FUNCTION init_capifunc(void)
+int __init init_capifunc(void)
 {
 	diva_os_initialize_spin_lock(&api_lock, "capifunc");
 	memset(ControllerMap, 0, MAX_DESCRIPTORS + 1);
@@ -1209,7 +1209,7 @@ int DIVA_INIT_FUNCTION init_capifunc(void)
 /*
  * finit
  */
-void DIVA_EXIT_FUNCTION finit_capifunc(void)
+void __exit finit_capifunc(void)
 {
 	do_api_remove_start();
 	divacapi_disconnect_didd();
diff --git a/drivers/isdn/hardware/eicon/capimain.c b/drivers/isdn/hardware/eicon/capimain.c
index eabe0fa..997d46a 100644
--- a/drivers/isdn/hardware/eicon/capimain.c
+++ b/drivers/isdn/hardware/eicon/capimain.c
@@ -118,7 +118,7 @@ void diva_os_set_controller_struct(struct capi_ctr *ctrl)
 /*
  * module init
  */
-static int DIVA_INIT_FUNCTION divacapi_init(void)
+static int __init divacapi_init(void)
 {
 	char tmprev[32];
 	int ret = 0;
@@ -144,7 +144,7 @@ static int DIVA_INIT_FUNCTION divacapi_init(void)
 /*
  * module exit
  */
-static void DIVA_EXIT_FUNCTION divacapi_exit(void)
+static void __exit divacapi_exit(void)
 {
 	finit_capifunc();
 	printk(KERN_INFO "%s: module unloaded.\n", DRIVERLNAME);
diff --git a/drivers/isdn/hardware/eicon/diddfunc.c b/drivers/isdn/hardware/eicon/diddfunc.c
index c4c8220..b0b23ed 100644
--- a/drivers/isdn/hardware/eicon/diddfunc.c
+++ b/drivers/isdn/hardware/eicon/diddfunc.c
@@ -47,7 +47,7 @@ static void *didd_callback(void *context, DESCRIPTOR *adapter,
 /*
  * connect to didd
  */
-static int DIVA_INIT_FUNCTION connect_didd(void)
+static int __init connect_didd(void)
 {
 	int x = 0;
 	int dadapter = 0;
@@ -79,7 +79,7 @@ static int DIVA_INIT_FUNCTION connect_didd(void)
 /*
  * disconnect from didd
  */
-static void DIVA_EXIT_FUNCTION disconnect_didd(void)
+static void __exit disconnect_didd(void)
 {
 	IDI_SYNC_REQ req;
 
@@ -92,7 +92,7 @@ static void DIVA_EXIT_FUNCTION disconnect_didd(void)
 /*
  * init
  */
-int DIVA_INIT_FUNCTION diddfunc_init(void)
+int __init diddfunc_init(void)
 {
 	diva_didd_load_time_init();
 
@@ -107,7 +107,7 @@ int DIVA_INIT_FUNCTION diddfunc_init(void)
 /*
  * finit
  */
-void DIVA_EXIT_FUNCTION diddfunc_finit(void)
+void __exit diddfunc_finit(void)
 {
 	DbgDeregister();
 	disconnect_didd();
diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
index d1d3de0..fab6ccf 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -91,7 +91,7 @@ static const struct file_operations divadidd_proc_fops = {
 	.release	= single_release,
 };
 
-static int DIVA_INIT_FUNCTION create_proc(void)
+static int __init create_proc(void)
 {
 	proc_net_eicon = proc_mkdir("eicon", init_net.proc_net);
 
@@ -109,7 +109,7 @@ static void remove_proc(void)
 	remove_proc_entry("eicon", init_net.proc_net);
 }
 
-static int DIVA_INIT_FUNCTION divadidd_init(void)
+static int __init divadidd_init(void)
 {
 	char tmprev[32];
 	int ret = 0;
@@ -141,7 +141,7 @@ out:
 	return (ret);
 }
 
-static void DIVA_EXIT_FUNCTION divadidd_exit(void)
+static void __exit divadidd_exit(void)
 {
 	diddfunc_finit();
 	remove_proc();
diff --git a/drivers/isdn/hardware/eicon/divamnt.c b/drivers/isdn/hardware/eicon/divamnt.c
index ffa0c31..48db08d 100644
--- a/drivers/isdn/hardware/eicon/divamnt.c
+++ b/drivers/isdn/hardware/eicon/divamnt.c
@@ -184,7 +184,7 @@ static void divas_maint_unregister_chrdev(void)
 	unregister_chrdev(major, DEVNAME);
 }
 
-static int DIVA_INIT_FUNCTION divas_maint_register_chrdev(void)
+static int __init divas_maint_register_chrdev(void)
 {
 	if ((major = register_chrdev(0, DEVNAME, &divas_maint_fops)) < 0)
 	{
@@ -207,7 +207,7 @@ void diva_maint_wakeup_read(void)
 /*
  *  Driver Load
  */
-static int DIVA_INIT_FUNCTION maint_init(void)
+static int __init maint_init(void)
 {
 	char tmprev[50];
 	int ret = 0;
@@ -245,7 +245,7 @@ out:
 /*
 **  Driver Unload
 */
-static void DIVA_EXIT_FUNCTION maint_exit(void)
+static void __exit maint_exit(void)
 {
 	divas_maint_unregister_chrdev();
 	mntfunc_finit();
diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/hardware/eicon/divasfunc.c
index 60aaf95..4be5f88 100644
--- a/drivers/isdn/hardware/eicon/divasfunc.c
+++ b/drivers/isdn/hardware/eicon/divasfunc.c
@@ -153,7 +153,7 @@ static void *didd_callback(void *context, DESCRIPTOR *adapter,
 /*
  * connect to didd
  */
-static int DIVA_INIT_FUNCTION connect_didd(void)
+static int __init connect_didd(void)
 {
 	int x = 0;
 	int dadapter = 0;
@@ -209,7 +209,7 @@ static void disconnect_didd(void)
 /*
  * init
  */
-int DIVA_INIT_FUNCTION divasfunc_init(int dbgmask)
+int __init divasfunc_init(int dbgmask)
 {
 	char *version;
 
diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardware/eicon/divasi.c
index a5c8f90..4103a8c 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -114,7 +114,7 @@ static const struct file_operations um_idi_proc_fops = {
 	.release	= single_release,
 };
 
-static int DIVA_INIT_FUNCTION create_um_idi_proc(void)
+static int __init create_um_idi_proc(void)
 {
 	um_idi_proc_entry = proc_create(DRIVERLNAME, S_IRUGO, proc_net_eicon,
 					&um_idi_proc_fops);
@@ -146,7 +146,7 @@ static void divas_idi_unregister_chrdev(void)
 	unregister_chrdev(major, DEVNAME);
 }
 
-static int DIVA_INIT_FUNCTION divas_idi_register_chrdev(void)
+static int __init divas_idi_register_chrdev(void)
 {
 	if ((major = register_chrdev(0, DEVNAME, &divas_idi_fops)) < 0)
 	{
@@ -161,7 +161,7 @@ static int DIVA_INIT_FUNCTION divas_idi_register_chrdev(void)
 /*
 ** Driver Load
 */
-static int DIVA_INIT_FUNCTION divasi_init(void)
+static int __init divasi_init(void)
 {
 	char tmprev[50];
 	int ret = 0;
@@ -202,7 +202,7 @@ out:
 /*
 ** Driver Unload
 */
-static void DIVA_EXIT_FUNCTION divasi_exit(void)
+static void __exit divasi_exit(void)
 {
 	idifunc_finit();
 	remove_um_idi_proc();
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 7eaab06..ca6d276 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -673,7 +673,7 @@ static void divas_unregister_chrdev(void)
 	unregister_chrdev(major, DEVNAME);
 }
 
-static int DIVA_INIT_FUNCTION divas_register_chrdev(void)
+static int __init divas_register_chrdev(void)
 {
 	if ((major = register_chrdev(0, DEVNAME, &divas_fops)) < 0)
 	{
@@ -767,7 +767,7 @@ static void __devexit divas_remove_one(struct pci_dev *pdev)
 /* --------------------------------------------------------------------------
    Driver Load / Startup
    -------------------------------------------------------------------------- */
-static int DIVA_INIT_FUNCTION divas_init(void)
+static int __init divas_init(void)
 {
 	char tmprev[50];
 	int ret = 0;
@@ -831,7 +831,7 @@ out:
 /* --------------------------------------------------------------------------
    Driver Unload
    -------------------------------------------------------------------------- */
-static void DIVA_EXIT_FUNCTION divas_exit(void)
+static void __exit divas_exit(void)
 {
 	pci_unregister_driver(&diva_pci_driver);
 	remove_divas_proc();
diff --git a/drivers/isdn/hardware/eicon/idifunc.c b/drivers/isdn/hardware/eicon/idifunc.c
index d153e3c..fef6586 100644
--- a/drivers/isdn/hardware/eicon/idifunc.c
+++ b/drivers/isdn/hardware/eicon/idifunc.c
@@ -133,7 +133,7 @@ static void um_remove_card(DESCRIPTOR *d)
 /*
  * remove all adapter
  */
-static void DIVA_EXIT_FUNCTION remove_all_idi_proc(void)
+static void __exit remove_all_idi_proc(void)
 {
 	udiva_card *card;
 	diva_os_spin_lock_magic_t old_irql;
@@ -181,7 +181,7 @@ static void *didd_callback(void *context, DESCRIPTOR *adapter,
 /*
  * connect DIDD
  */
-static int DIVA_INIT_FUNCTION connect_didd(void)
+static int __init connect_didd(void)
 {
 	int x = 0;
 	int dadapter = 0;
@@ -225,7 +225,7 @@ static int DIVA_INIT_FUNCTION connect_didd(void)
 /*
  *  Disconnect from DIDD
  */
-static void DIVA_EXIT_FUNCTION disconnect_didd(void)
+static void __exit disconnect_didd(void)
 {
 	IDI_SYNC_REQ req;
 
@@ -240,7 +240,7 @@ static void DIVA_EXIT_FUNCTION disconnect_didd(void)
 /*
  * init
  */
-int DIVA_INIT_FUNCTION idifunc_init(void)
+int __init idifunc_init(void)
 {
 	diva_os_initialize_spin_lock(&ll_lock, "idifunc");
 
@@ -260,7 +260,7 @@ int DIVA_INIT_FUNCTION idifunc_init(void)
 /*
  * finit
  */
-void DIVA_EXIT_FUNCTION idifunc_finit(void)
+void __exit idifunc_finit(void)
 {
 	diva_user_mode_idi_finit();
 	disconnect_didd();
diff --git a/drivers/isdn/hardware/eicon/mntfunc.c b/drivers/isdn/hardware/eicon/mntfunc.c
index d607260..1cd9aff 100644
--- a/drivers/isdn/hardware/eicon/mntfunc.c
+++ b/drivers/isdn/hardware/eicon/mntfunc.c
@@ -72,7 +72,7 @@ static void *didd_callback(void *context, DESCRIPTOR *adapter,
 /*
  * connect to didd
  */
-static int DIVA_INIT_FUNCTION connect_didd(void)
+static int __init connect_didd(void)
 {
 	int x = 0;
 	int dadapter = 0;
@@ -114,7 +114,7 @@ static int DIVA_INIT_FUNCTION connect_didd(void)
 /*
  * disconnect from didd
  */
-static void DIVA_EXIT_FUNCTION disconnect_didd(void)
+static void __exit disconnect_didd(void)
 {
 	IDI_SYNC_REQ req;
 
@@ -300,7 +300,7 @@ int maint_read_write(void __user *buf, int count)
 /*
  *  init
  */
-int DIVA_INIT_FUNCTION mntfunc_init(int *buffer_length, void **buffer,
+int __init mntfunc_init(int *buffer_length, void **buffer,
 				    unsigned long diva_dbg_mem)
 {
 	if (*buffer_length < 64) {
@@ -348,7 +348,7 @@ int DIVA_INIT_FUNCTION mntfunc_init(int *buffer_length, void **buffer,
 /*
  *  exit
  */
-void DIVA_EXIT_FUNCTION mntfunc_finit(void)
+void __exit mntfunc_finit(void)
 {
 	void *buffer;
 	int i = 100;
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hardware/eicon/platform.h
index 7331c3b..b2edb75 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -38,9 +38,6 @@
 #define DIVA_NO_DEBUGLIB
 #endif
 
-#define DIVA_INIT_FUNCTION  __init
-#define DIVA_EXIT_FUNCTION  __exit
-
 #define DIVA_USER_MODE_CARD_CONFIG 1
 #define	USE_EXTENDED_DEBUGS 1
 
