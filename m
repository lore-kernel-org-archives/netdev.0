From: Olaf Hering <olh@suse.de>
Subject: [PATCH]  allow CONFIG_NET=n on ppc64
Date: Wed, 29 Sep 2004 22:01:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929200158.GA16366@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i8TK3nJq008730


The attached minimal config does not compile on ppc64.
I was able to boot the resulting binary with this patch.


Signed-off-by: Olaf Hering <olh@suse.de>


diff -purNX /suse/olh/kernel/kernel_exclude.txt linux-2.6.9-rc2/arch/ppc6=
4/kernel/misc.S linux-2.6.9-rc2.ppc64/arch/ppc64/kernel/misc.S
--- linux-2.6.9-rc2/arch/ppc64/kernel/misc.S	2004-09-13 07:33:23.00000000=
0 +0200
+++ linux-2.6.9-rc2.ppc64/arch/ppc64/kernel/misc.S	2004-09-29 21:00:44.90=
9074755 +0200
@@ -703,7 +703,11 @@ _GLOBAL(sys_call_table32)
 	.llong .compat_sys_statfs
 	.llong .compat_sys_fstatfs		/* 100 */
 	.llong .sys_ni_syscall		/* old ioperm syscall */
+#ifdef CONFIG_NET
 	.llong .compat_sys_socketcall
+#else
+	.llong .sys_ni_syscall		/* old ioperm syscall */
+#endif
 	.llong .sys32_syslog
 	.llong .compat_sys_setitimer
 	.llong .compat_sys_getitimer		/* 105 */
diff -purNX /suse/olh/kernel/kernel_exclude.txt linux-2.6.9-rc2/include/n=
et/sock.h linux-2.6.9-rc2.ppc64/include/net/sock.h
--- linux-2.6.9-rc2/include/net/sock.h	2004-09-13 07:33:11.000000000 +020=
0
+++ linux-2.6.9-rc2.ppc64/include/net/sock.h	2004-09-29 21:06:03.54493359=
1 +0200
@@ -1327,6 +1327,13 @@ static inline void sock_valbool_flag(str
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
=20
+#ifdef CONFIG_NET
 int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned lon=
g arg);
+#else
+static inline int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd=
, unsigned long arg)
+{
+	return -ENODEV;
+}
+#endif
=20
 #endif	/* _SOCK_H */

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="minimal.config"

CONFIG_64BIT=y
CONFIG_MMU=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_HAVE_DEC_LOCK=y
CONFIG_EARLY_PRINTK=y
CONFIG_COMPAT=y
CONFIG_FRAME_POINTER=y
CONFIG_FORCE_MAX_ZONEORDER=13
CONFIG_EXPERIMENTAL=y
CONFIG_CLEAN_COMPILE=y
CONFIG_LOCALVERSION=""
CONFIG_SYSVIPC=y
CONFIG_SYSCTL=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_SHMEM=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_PPC_PSERIES=y
CONFIG_PPC=y
CONFIG_PPC64=y
CONFIG_PPC_OF=y
CONFIG_IOMMU_VMERGE=y
CONFIG_SMP=y
CONFIG_IRQ_ALL_CPUS=y
CONFIG_NR_CPUS=128
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
CONFIG_BINFMT_ELF=y
CONFIG_PROC_DEVICETREE=y
CONFIG_CMDLINE_BOOL=y
CONFIG_CMDLINE="panic=1"
CONFIG_INPUT=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_SOUND_GAMEPORT=y
CONFIG_SERIO=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_SYSFS=y
CONFIG_DEVPTS_FS_XATTR=y
CONFIG_TMPFS=y
CONFIG_RAMFS=y
CONFIG_MSDOS_PARTITION=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUGGER=y
CONFIG_XMON=y
CONFIG_XMON_DEFAULT=y
CONFIG_LIBCRC32C=y

--h31gzZEtNLTqOjlF--
