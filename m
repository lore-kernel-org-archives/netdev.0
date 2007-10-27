From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] proc_fs.h redux
Date: Sat, 27 Oct 2007 23:47:58 +0400
Message-ID: <20071027194758.GD9816@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: akpm@osdl.org, torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:42063 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbXJ0TsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 15:48:07 -0400
Received: by ug-out-1314.google.com with SMTP id z38so826297ugc
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2007 12:48:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove proc_fs.h from headers that doesn't really need it. Typical overkill is
including full header when one can get away with just forward declaration of
"struct proc_dir_entry".

Number of files that are recompiled after touching proc_fs.h drops from 1100
to 513(!) on x86_64 allmodconfig.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/powerpc/kernel/process.c               |    1 +
 arch/powerpc/kernel/prom.c                  |    1 +
 arch/powerpc/mm/init_32.c                   |    1 +
 arch/powerpc/mm/init_64.c                   |    1 +
 arch/powerpc/platforms/iseries/mf.c         |    1 +
 arch/powerpc/platforms/pasemi/electra_ide.c |    2 +-
 arch/powerpc/sysdev/fsl_soc.c               |    1 +
 arch/powerpc/sysdev/mv64x60_dev.c           |    2 +-
 arch/powerpc/sysdev/qe_lib/qe.c             |    1 +
 arch/sparc/kernel/process.c                 |    3 ++-
 arch/sparc64/kernel/ldc.c                   |    1 +
 arch/sparc64/kernel/mdesc.c                 |    1 +
 arch/sparc64/kernel/viohs.c                 |    2 +-
 drivers/acpi/bay.c                          |    1 +
 drivers/acpi/dock.c                         |    2 +-
 drivers/block/cpqarray.h                    |    2 +-
 drivers/hwmon/ibmpex.c                      |    2 +-
 drivers/isdn/hardware/eicon/platform.h      |    1 -
 drivers/md/md.c                             |    1 +
 drivers/misc/fujitsu-laptop.c               |    1 +
 drivers/misc/msi-laptop.c                   |    1 +
 drivers/misc/thinkpad_acpi.c                |    2 +-
 drivers/misc/thinkpad_acpi.h                |    3 ++-
 drivers/net/bonding/bonding.h               |    3 ++-
 drivers/net/cxgb3/t3cdev.h                  |    2 +-
 drivers/parport/parport_serial.c            |    2 +-
 drivers/sbus/char/envctrl.c                 |    2 +-
 drivers/sbus/char/uctrl.c                   |    1 +
 drivers/scsi/imm.h                          |    1 -
 drivers/scsi/ppa.h                          |    1 -
 drivers/usb/gadget/lh7a40x_udc.h            |    1 -
 fs/nfs/client.c                             |    1 +
 include/acpi/acpi_bus.h                     |    2 +-
 include/asm-powerpc/prom.h                  |    3 ++-
 include/asm-sparc/prom.h                    |    4 +++-
 include/asm-sparc64/prom.h                  |    4 +++-
 include/linux/atmdev.h                      |    2 +-
 include/linux/crash_dump.h                  |    3 ++-
 include/linux/efi.h                         |    1 -
 include/linux/ipmi.h                        |    1 -
 include/linux/netfilter.h                   |    2 +-
 include/linux/parport.h                     |    1 -
 include/linux/raid/md.h                     |    1 -
 include/linux/sunrpc/cache.h                |    4 +++-
 include/linux/sunrpc/rpc_pipe_fs.h          |    2 ++
 include/linux/sunrpc/stats.h                |    3 ++-
 include/linux/wanrouter.h                   |    3 ++-
 include/net/sctp/sctp.h                     |    2 +-
 net/atm/br2684.c                            |    1 +
 net/atm/resources.h                         |    2 --
 net/irda/irnet/irnet.h                      |    1 -
 net/irda/irnet/irnet_irda.c                 |    2 +-
 net/sctp/objcnt.c                           |    1 +
 net/sctp/proc.c                             |    1 +
 net/sctp/protocol.c                         |    1 +
 net/sunrpc/auth.c                           |    2 ++
 net/sunrpc/auth_unix.c                      |    2 +-
 net/sunrpc/rpcb_clnt.c                      |    1 +
 net/sunrpc/xprt.c                           |    2 +-
 net/wanrouter/wanmain.c                     |    1 +
 net/wanrouter/wanproc.c                     |    1 +
 61 files changed, 66 insertions(+), 38 deletions(-)

--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -17,6 +17,7 @@
 #include <linux/errno.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/smp.h>
 #include <linux/stddef.h>
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -23,6 +23,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/pci.h>
+#include <linux/proc_fs.h>
 #include <linux/stringify.h>
 #include <linux/delay.h>
 #include <linux/initrd.h>
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -30,6 +30,7 @@
 #include <linux/highmem.h>
 #include <linux/initrd.h>
 #include <linux/pagemap.h>
+#include <linux/proc_fs.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -40,6 +40,7 @@
 #include <linux/nodemask.h>
 #include <linux/module.h>
 #include <linux/poison.h>
+#include <linux/proc_fs.h>
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
--- a/arch/powerpc/platforms/iseries/mf.c
+++ b/arch/powerpc/platforms/iseries/mf.c
@@ -33,6 +33,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/bcd.h>
 #include <linux/rtc.h>
+#include <linux/proc_fs.h>
 
 #include <asm/time.h>
 #include <asm/uaccess.h>
--- a/arch/powerpc/platforms/pasemi/electra_ide.c
+++ b/arch/powerpc/platforms/pasemi/electra_ide.c
@@ -16,7 +16,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
  */
-
+#include <linux/err.h>
 #include <linux/platform_device.h>
 
 #include <asm/prom.h>
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -15,6 +15,7 @@
 #include <linux/stddef.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/major.h>
 #include <linux/delay.h>
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -8,7 +8,7 @@
  * is licensed "as is" without any warranty of any kind, whether express
  * or implied.
  */
-
+#include <linux/err.h>
 #include <linux/stddef.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -14,6 +14,7 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  */
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
--- a/arch/sparc/kernel/process.c
+++ b/arch/sparc/kernel/process.c
@@ -10,12 +10,13 @@
  */
 
 #include <stdarg.h>
-
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/kallsyms.h>
+#include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/stddef.h>
 #include <linux/ptrace.h>
--- a/arch/sparc64/kernel/ldc.c
+++ b/arch/sparc64/kernel/ldc.c
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/delay.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/scatterlist.h>
--- a/arch/sparc64/kernel/mdesc.c
+++ b/arch/sparc64/kernel/mdesc.c
@@ -8,6 +8,7 @@
 #include <linux/log2.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/miscdevice.h>
 
--- a/arch/sparc64/kernel/viohs.c
+++ b/arch/sparc64/kernel/viohs.c
@@ -2,7 +2,7 @@
  *
  * Copyright (C) 2007 David S. Miller <davem@davemloft.net>
  */
-
+#include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/string.h>
--- a/drivers/acpi/bay.c
+++ b/drivers/acpi/bay.c
@@ -24,6 +24,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/err.h>
 #include <linux/types.h>
 #include <linux/notifier.h>
 #include <acpi/acpi_bus.h>
--- a/drivers/acpi/dock.c
+++ b/drivers/acpi/dock.c
@@ -21,7 +21,7 @@
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
-
+#include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
--- a/drivers/block/cpqarray.h
+++ b/drivers/block/cpqarray.h
@@ -28,7 +28,6 @@
 #ifdef __KERNEL__
 #include <linux/blkdev.h>
 #include <linux/slab.h>
-#include <linux/proc_fs.h>
 #include <linux/timer.h>
 #endif
 
@@ -57,6 +56,7 @@ typedef struct {
 
 struct ctlr_info;
 typedef struct ctlr_info ctlr_info_t;
+struct proc_dir_entry;
 
 struct access_method {
 	void (*submit_command)(ctlr_info_t *h, cmdlist_t *c);
--- a/drivers/hwmon/ibmpex.c
+++ b/drivers/hwmon/ibmpex.c
@@ -18,7 +18,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-
+#include <linux/err.h>
 #include <linux/ipmi.h>
 #include <linux/module.h>
 #include <linux/hwmon.h>
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -24,7 +24,6 @@
 #include <linux/sched.h>
 #include <linux/skbuff.h>
 #include <linux/vmalloc.h>
-#include <linux/proc_fs.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
 #include <linux/list.h>
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -41,6 +41,7 @@
 #include <linux/sysctl.h>
 #include <linux/buffer_head.h> /* for invalidate_bdev */
 #include <linux/poll.h>
+#include <linux/proc_fs.h>
 #include <linux/mutex.h>
 #include <linux/ctype.h>
 #include <linux/freezer.h>
--- a/drivers/misc/fujitsu-laptop.c
+++ b/drivers/misc/fujitsu-laptop.c
@@ -46,6 +46,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/err.h>
 #include <linux/acpi.h>
 #include <linux/dmi.h>
 #include <linux/backlight.h>
--- a/drivers/misc/msi-laptop.c
+++ b/drivers/misc/msi-laptop.c
@@ -54,6 +54,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/err.h>
 #include <linux/acpi.h>
 #include <linux/dmi.h>
 #include <linux/backlight.h>
--- a/drivers/misc/thinkpad_acpi.c
+++ b/drivers/misc/thinkpad_acpi.c
@@ -81,7 +81,7 @@
  *			removed fan control, currently useless
  *  2004-08-09	0.1	initial release, support for X series
  */
-
+#include <linux/proc_fs.h>
 #include "thinkpad_acpi.h"
 
 MODULE_AUTHOR("Borislav Deianov, Henrique de Moraes Holschuh");
--- a/drivers/misc/thinkpad_acpi.h
+++ b/drivers/misc/thinkpad_acpi.h
@@ -33,7 +33,6 @@
 #include <linux/mutex.h>
 
 #include <linux/nvram.h>
-#include <linux/proc_fs.h>
 #include <linux/sysfs.h>
 #include <linux/backlight.h>
 #include <linux/fb.h>
@@ -52,6 +51,8 @@
 
 #include <linux/pci_ids.h>
 
+struct proc_dir_entry;
+
 /****************************************************************************
  * Main driver
  */
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -16,12 +16,13 @@
 #define _LINUX_BONDING_H
 
 #include <linux/timer.h>
-#include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
+struct proc_dir_entry;
+
 #define DRV_VERSION	"3.2.1"
 #define DRV_RELDATE	"October 15, 2007"
 #define DRV_NAME	"bonding"
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -36,13 +36,13 @@
 #include <asm/atomic.h>
 #include <asm/semaphore.h>
 #include <linux/netdevice.h>
-#include <linux/proc_fs.h>
 #include <linux/skbuff.h>
 #include <net/neighbour.h>
 
 #define T3CNAMSIZ 16
 
 struct cxgb3_client;
+struct proc_dir_entry;
 
 enum t3ctype {
 	T3A = 0,
--- a/drivers/parport/parport_serial.c
+++ b/drivers/parport/parport_serial.c
@@ -16,7 +16,7 @@
  * that.
  *
  */
-
+#include <linux/err.h>
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/init.h>
--- a/drivers/sbus/char/envctrl.c
+++ b/drivers/sbus/char/envctrl.c
@@ -18,7 +18,7 @@
  * DB - Audit every copy_to_user in envctrl_read.
  *              Daniele Bellucci <bellucda@tiscali.it>
  */
-
+#include <linux/fs.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kthread.h>
--- a/drivers/sbus/char/uctrl.c
+++ b/drivers/sbus/char/uctrl.c
@@ -12,6 +12,7 @@
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <linux/miscdevice.h>
+#include <linux/fs.h>
 #include <linux/mm.h>
 
 #include <asm/openprom.h>
--- a/drivers/scsi/imm.h
+++ b/drivers/scsi/imm.h
@@ -71,7 +71,6 @@
 #include  <linux/kernel.h>
 #include  <linux/ioport.h>
 #include  <linux/delay.h>
-#include  <linux/proc_fs.h>
 #include  <linux/stat.h>
 #include  <linux/blkdev.h>
 #include  <linux/sched.h>
--- a/drivers/scsi/ppa.h
+++ b/drivers/scsi/ppa.h
@@ -78,7 +78,6 @@
 #include  <linux/kernel.h>
 #include  <linux/ioport.h>
 #include  <linux/delay.h>
-#include  <linux/proc_fs.h>
 #include  <linux/stat.h>
 #include  <linux/blkdev.h>
 #include  <linux/sched.h>
--- a/drivers/usb/gadget/lh7a40x_udc.h
+++ b/drivers/usb/gadget/lh7a40x_udc.h
@@ -36,7 +36,6 @@
 #include <linux/timer.h>
 #include <linux/list.h>
 #include <linux/interrupt.h>
-#include <linux/proc_fs.h>
 #include <linux/mm.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -29,6 +29,7 @@
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -55,7 +55,7 @@ acpi_evaluate_reference(acpi_handle handle,
 
 #ifdef CONFIG_ACPI
 
-#include <linux/proc_fs.h>
+struct proc_dir_entry;
 
 #define ACPI_BUS_FILE_ROOT	"acpi"
 extern struct proc_dir_entry *acpi_root_dir;
--- a/include/asm-powerpc/prom.h
+++ b/include/asm-powerpc/prom.h
@@ -16,11 +16,12 @@
  * 2 of the License, or (at your option) any later version.
  */
 #include <linux/types.h>
-#include <linux/proc_fs.h>
 #include <linux/platform_device.h>
 #include <asm/irq.h>
 #include <asm/atomic.h>
 
+struct proc_dir_entry;
+
 #define OF_ROOT_NODE_ADDR_CELLS_DEFAULT	1
 #define OF_ROOT_NODE_SIZE_CELLS_DEFAULT	1
 
--- a/include/asm-sparc/prom.h
+++ b/include/asm-sparc/prom.h
@@ -17,9 +17,11 @@
  * 2 of the License, or (at your option) any later version.
  */
 #include <linux/types.h>
-#include <linux/proc_fs.h>
+#include <linux/kref.h>
 #include <asm/atomic.h>
 
+struct proc_dir_entry;
+
 #define OF_ROOT_NODE_ADDR_CELLS_DEFAULT	2
 #define OF_ROOT_NODE_SIZE_CELLS_DEFAULT	1
 
--- a/include/asm-sparc64/prom.h
+++ b/include/asm-sparc64/prom.h
@@ -17,9 +17,11 @@
  * 2 of the License, or (at your option) any later version.
  */
 #include <linux/types.h>
-#include <linux/proc_fs.h>
+#include <linux/kref.h>
 #include <asm/atomic.h>
 
+struct proc_dir_entry;
+
 #define OF_ROOT_NODE_ADDR_CELLS_DEFAULT	2
 #define OF_ROOT_NODE_SIZE_CELLS_DEFAULT	1
 
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -219,7 +219,7 @@ struct atm_cirange {
 #include <asm/atomic.h>
 
 #ifdef CONFIG_PROC_FS
-#include <linux/proc_fs.h>
+struct proc_dir_entry;
 
 extern struct proc_dir_entry *atm_proc_root;
 #endif
--- a/include/linux/crash_dump.h
+++ b/include/linux/crash_dump.h
@@ -5,7 +5,8 @@
 #include <linux/kexec.h>
 #include <linux/smp_lock.h>
 #include <linux/device.h>
-#include <linux/proc_fs.h>
+
+struct proc_dir_entry;
 
 #define ELFCORE_ADDR_MAX	(-1ULL)
 extern unsigned long long elfcorehdr_addr;
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -15,7 +15,6 @@
 #include <linux/string.h>
 #include <linux/time.h>
 #include <linux/types.h>
-#include <linux/proc_fs.h>
 #include <linux/rtc.h>
 #include <linux/ioport.h>
 
--- a/include/linux/ipmi.h
+++ b/include/linux/ipmi.h
@@ -226,7 +226,6 @@ struct kernel_ipmi_msg
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/device.h>
-#include <linux/proc_fs.h>
 
 /* Opaque type for a IPMI message user.  One of these is needed to
    send and receive messages. */
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -363,7 +363,7 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, int family)
 }
 
 #ifdef CONFIG_PROC_FS
-#include <linux/proc_fs.h>
+struct proc_dir_entry;
 extern struct proc_dir_entry *proc_net_netfilter;
 #endif
 
--- a/include/linux/parport.h
+++ b/include/linux/parport.h
@@ -97,7 +97,6 @@ typedef enum {
 #ifdef __KERNEL__
 
 #include <linux/jiffies.h>
-#include <linux/proc_fs.h>
 #include <linux/spinlock.h>
 #include <linux/wait.h>
 #include <linux/irqreturn.h>
--- a/include/linux/raid/md.h
+++ b/include/linux/raid/md.h
@@ -26,7 +26,6 @@
 #include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/hdreg.h>
-#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/smp_lock.h>
 #include <linux/delay.h>
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -13,9 +13,11 @@
 #ifndef _LINUX_SUNRPC_CACHE_H_
 #define _LINUX_SUNRPC_CACHE_H_
 
+#include <linux/kref.h>
 #include <linux/slab.h>
 #include <asm/atomic.h>
-#include <linux/proc_fs.h>
+
+struct proc_dir_entry;
 
 /*
  * Each cache requires:
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/fs.h>
+
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;
--- a/include/linux/sunrpc/stats.h
+++ b/include/linux/sunrpc/stats.h
@@ -9,7 +9,8 @@
 #ifndef _LINUX_SUNRPC_STATS_H
 #define _LINUX_SUNRPC_STATS_H
 
-#include <linux/proc_fs.h>
+struct file_operations;
+struct proc_dir_entry;
 
 struct rpc_stat {
 	struct rpc_program *	program;
--- a/include/linux/wanrouter.h
+++ b/include/linux/wanrouter.h
@@ -453,10 +453,11 @@ typedef struct wanif_conf
 /****** Kernel Interface ****************************************************/
 
 #include <linux/fs.h>		/* support for device drivers */
-#include <linux/proc_fs.h>	/* proc filesystem pragmatics */
 #include <linux/netdevice.h>	/* support for network drivers */
 #include <linux/spinlock.h>     /* Support for SMP Locking */
 
+struct proc_dir_entry;
+
 /*----------------------------------------------------------------------------
  * WAN device data space.
  */
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -74,7 +74,6 @@
 #include <linux/slab.h>
 #include <linux/in.h>
 #include <linux/tty.h>
-#include <linux/proc_fs.h>
 #include <linux/spinlock.h>
 #include <linux/jiffies.h>
 #include <linux/idr.h>
@@ -91,6 +90,7 @@
 #include <net/sctp/structs.h>
 #include <net/sctp/constants.h>
 
+struct proc_dir_entry;
 
 /* Set SCTP_DEBUG flag via config if not already set. */
 #ifndef SCTP_DEBUG
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -18,6 +18,7 @@ Author: Marcell GAL, 2000, XDSL Ltd, Hungary
 #include <linux/atm.h>
 #include <linux/atmdev.h>
 #include <linux/capability.h>
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
 #include <linux/atmbr2684.h>
--- a/net/atm/resources.h
+++ b/net/atm/resources.h
@@ -18,8 +18,6 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg);
 
 #ifdef CONFIG_PROC_FS
 
-#include <linux/proc_fs.h>
-
 void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos);
 void atm_dev_seq_stop(struct seq_file *seq, void *v);
 void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -243,7 +243,6 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/tty.h>
-#include <linux/proc_fs.h>
 #include <linux/netdevice.h>
 #include <linux/miscdevice.h>
 #include <linux/poll.h>
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -7,7 +7,7 @@
  * Basically, we sit on top of IrTTP. We set up IrTTP, IrIAS properly,
  * and exchange frames with IrTTP.
  */
-
+#include <linux/proc_fs.h>
 #include "irnet_irda.h"		/* Private header */
 
 /*
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -39,6 +39,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/proc_fs.h>
 #include <net/sctp/sctp.h>
 
 /*
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -35,6 +35,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
 #include <net/sctp/sctp.h>
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -50,6 +50,7 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/bootmem.h>
 #include <net/net_namespace.h>
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -7,9 +7,11 @@
  */
 
 #include <linux/types.h>
+#include <linux/dcache.h>
 #include <linux/sched.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/spinlock.h>
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -5,7 +5,7 @@
  *
  * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
-
+#include <linux/err.h>
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/module.h>
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -19,6 +19,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/kernel.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 
 #include <linux/sunrpc/clnt.h>
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -37,7 +37,7 @@
  */
 
 #include <linux/module.h>
-
+#include <linux/err.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
 #include <linux/workqueue.h>
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -49,6 +49,7 @@
 #include <linux/module.h>	/* support for loadable modules */
 #include <linux/slab.h>		/* kmalloc(), kfree() */
 #include <linux/mm.h>
+#include <linux/proc_fs.h>
 #include <linux/string.h>	/* inline mem*, str* functions */
 
 #include <asm/byteorder.h>	/* htons(), etc. */
--- a/net/wanrouter/wanproc.c
+++ b/net/wanrouter/wanproc.c
@@ -26,6 +26,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/wanrouter.h>	/* WAN router API definitions */
+#include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/smp_lock.h>
 
