From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [xfrm?] BUG: unable to handle kernel NULL pointer dereference at
 00000004
Date: Fri, 7 Jun 2013 17:07:14 +0800
Message-ID: <20130607090714.GA16013@localhost>
References: <20130606125549.GA17577@localhost>
 <51B19EC5.10004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51B19EC5.10004@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 07, 2013 at 04:50:13PM +0800, Fan Du wrote:
> Hi FengGuang
>=20
> On 2013=E5=B9=B406=E6=9C=8806=E6=97=A5 20:55, Fengguang Wu wrote:
> >Greetings,
> >
> >I got the below dmesg and the first bad commit is
> >
> >commit 4c4d41f200db375b2d2cc6d0a1de0606c8266398
> >Author: Fan Du<fan.du@windriver.com>
> >Date:   Thu Jun 6 10:15:54 2013 +0800
> >
> >     xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic counter
> >
> >     When host ping its peer, ICMP echo request packet triggers IPse=
c
> >     policy, then host negotiates SA secret with its peer. After IKE
> >     installed SA for OUT direction, but before SA for IN direction
> >     installed, host get ICMP echo reply from its peer. At the time
> >     being, the SA state for IN direction could be XFRM_STATE_ACQ,
> >     then the received packet will be dropped after adding
> >     LINUX_MIB_XFRMINSTATEINVALID statistic.
> >
> >     Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
> >     scenario when SA in larval state is much clearer for user than
> >     LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
> >     bad.
> >
> >     Signed-off-by: Fan Du<fan.du@windriver.com>
> >     Signed-off-by: Steffen Klassert<steffen.klassert@secunet.com>
> >
> >
> >[  157.721828] no cont in shutdown!
> >[  158.779481] floppy0: FDC access conflict!
> >[  159.555337] BUG: unable to handle kernel NULL pointer dereference=
 at 00000004
> >[  160.102544] IP: [<c1609ed5>] reset_interrupt+0x85/0x90
> >[  160.102544] *pde =3D 00000000
> >[  160.102544] Oops: 0000 [#1] PREEMPT SMP
> >[  160.102544] CPU: 1 PID: 89 Comm: kworker/u4:1 Not tainted 3.10.0-=
rc2-00597-g4c4d41f #3
> >[  160.102544] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> >[  160.102544] Workqueue: floppy reset_interrupt
> >[  160.102544] task: c5a5ad00 ti: c5b5c000 task.ti: c5b5c000
> >[  160.102544] EIP: 0060:[<c1609ed5>] EFLAGS: 00010246 CPU: 1
> >[  160.102544] EIP is at reset_interrupt+0x85/0x90
> >[  160.102544] EAX: 00000000 EBX: cbd56600 ECX: c5a5ad00 EDX: 000003=
f4
> >[  160.102544] ESI: c1ed0e40 EDI: c5a23200 EBP: c5b5debc ESP: c5b5de=
ac
> >[  160.102544]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> >[  160.102544] CR0: 8005003b CR2: 00000004 CR3: 02037000 CR4: 000006=
90
> >[  160.102544] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 000000=
00
> >[  160.102544] DR6: ffff0ff0 DR7: 00000400
> >[  160.102544] Stack:
> >[  178.765341] pcd0: Autoprobe failed
> >[  178.765373] pcd: No CD-ROM drive found
> >
> >Bisect log shows that
> >- reverting the commit fixes the problem
> >- linux-next is also impacted
>=20
> I tested with newest net-next tree(at 93a306aef5eef70e524500884ccca52=
c5dd19e17) with my patch applied,
> no misbehavior happened in boot up and cat /proc/net/xfrm_stat.
>=20
> Now I will test against ipsec-next tree soon, please wait for just a =
while.

=46u Dan, let me redo the bisect -- the bug is obviously not related to
your patch.

Sorry I ran bisect with too small repeat count. It's actually a hard
to reproducible bug which need lots of repeated boots to confirm
whether any commit is good. So my 2nd bisect run will take some time
to finish.

Thanks,
=46engguang

> >git bisect start 4c4d41f200db375b2d2cc6d0a1de0606c8266398 5865fc1b6a=
99bc7dcf245770c2735577b8596b6e --
> >git bisect good 5865fc1b6a99bc7dcf245770c2735577b8596b6e  #    30  2=
013-06-06 17:34:58  tg3: remove redundant pm init code
> >git bisect  bad 4c4d41f200db375b2d2cc6d0a1de0606c8266398  #     0  2=
013-06-06 17:34:59  xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic coun=
ter
> >git bisect good ce10982b1a07f6a25bb756b7509188ae8a5060d6  #    30  2=
013-06-06 20:42:08  Revert "xfrm: add LINUX_MIB_XFRMACQUIREERROR statis=
tic counter"
> >git bisect  bad 4e1e7059d375482daeeda395bba2939679b1ee14  #     0  2=
013-06-06 20:42:13  Add linux-next specific files for 20130606
> >
> >Thanks,
> >Fengguang
>=20
> --=20
> =E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=
=9D=E7=AC=91
>=20
> --fan

> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/arm 3.10.0-rc4 Kernel Configuration
> #
> CONFIG_ARM=3Dy
> CONFIG_SYS_SUPPORTS_APM_EMULATION=3Dy
> CONFIG_HAVE_PROC_CPU=3Dy
> CONFIG_NO_IOPORT=3Dy
> CONFIG_STACKTRACE_SUPPORT=3Dy
> CONFIG_LOCKDEP_SUPPORT=3Dy
> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
> CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
> CONFIG_GENERIC_HWEIGHT=3Dy
> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
> CONFIG_NEED_DMA_MAP_STATE=3Dy
> CONFIG_VECTORS_BASE=3D0xffff0000
> CONFIG_ARM_PATCH_PHYS_VIRT=3Dy
> CONFIG_GENERIC_BUG=3Dy
> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_IRQ_WORK=3Dy
> CONFIG_BUILDTIME_EXTABLE_SORT=3Dy
>=20
> #
> # General setup
> #
> CONFIG_INIT_ENV_ARG_LIMIT=3D32
> CONFIG_CROSS_COMPILE=3D"arm-none-linux-gnueabi-"
> CONFIG_LOCALVERSION=3D""
> # CONFIG_LOCALVERSION_AUTO is not set
> CONFIG_HAVE_KERNEL_GZIP=3Dy
> CONFIG_HAVE_KERNEL_LZMA=3Dy
> CONFIG_HAVE_KERNEL_XZ=3Dy
> CONFIG_HAVE_KERNEL_LZO=3Dy
> CONFIG_KERNEL_GZIP=3Dy
> # CONFIG_KERNEL_LZMA is not set
> # CONFIG_KERNEL_XZ is not set
> # CONFIG_KERNEL_LZO is not set
> CONFIG_DEFAULT_HOSTNAME=3D"(none)"
> CONFIG_SWAP=3Dy
> CONFIG_SYSVIPC=3Dy
> CONFIG_SYSVIPC_SYSCTL=3Dy
> # CONFIG_POSIX_MQUEUE is not set
> # CONFIG_FHANDLE is not set
> # CONFIG_AUDIT is not set
> CONFIG_HAVE_GENERIC_HARDIRQS=3Dy
>=20
> #
> # IRQ subsystem
> #
> CONFIG_GENERIC_HARDIRQS=3Dy
> CONFIG_GENERIC_IRQ_PROBE=3Dy
> CONFIG_GENERIC_IRQ_SHOW=3Dy
> CONFIG_HARDIRQS_SW_RESEND=3Dy
> CONFIG_IRQ_DOMAIN=3Dy
> # CONFIG_IRQ_DOMAIN_DEBUG is not set
> CONFIG_SPARSE_IRQ=3Dy
> CONFIG_KTIME_SCALAR=3Dy
> CONFIG_GENERIC_CLOCKEVENTS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
> CONFIG_ARCH_HAS_TICK_BROADCAST=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
>=20
> #
> # Timers subsystem
> #
> CONFIG_HZ_PERIODIC=3Dy
> # CONFIG_NO_HZ_IDLE is not set
> # CONFIG_NO_HZ is not set
> # CONFIG_HIGH_RES_TIMERS is not set
>=20
> #
> # CPU/Task time and stats accounting
> #
> CONFIG_TICK_CPU_ACCOUNTING=3Dy
> # CONFIG_IRQ_TIME_ACCOUNTING is not set
> # CONFIG_BSD_PROCESS_ACCT is not set
> # CONFIG_TASKSTATS is not set
>=20
> #
> # RCU Subsystem
> #
> CONFIG_TREE_RCU=3Dy
> # CONFIG_PREEMPT_RCU is not set
> CONFIG_RCU_STALL_COMMON=3Dy
> # CONFIG_RCU_USER_QS is not set
> CONFIG_RCU_FANOUT=3D32
> CONFIG_RCU_FANOUT_LEAF=3D16
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_RCU_NOCB_CPU is not set
> CONFIG_IKCONFIG=3Dy
> CONFIG_IKCONFIG_PROC=3Dy
> CONFIG_LOG_BUF_SHIFT=3D14
> CONFIG_CGROUPS=3Dy
> # CONFIG_CGROUP_DEBUG is not set
> # CONFIG_CGROUP_FREEZER is not set
> # CONFIG_CGROUP_DEVICE is not set
> CONFIG_CPUSETS=3Dy
> CONFIG_PROC_PID_CPUSET=3Dy
> # CONFIG_CGROUP_CPUACCT is not set
> # CONFIG_RESOURCE_COUNTERS is not set
> # CONFIG_CGROUP_PERF is not set
> # CONFIG_CGROUP_SCHED is not set
> # CONFIG_BLK_CGROUP is not set
> # CONFIG_CHECKPOINT_RESTORE is not set
> CONFIG_NAMESPACES=3Dy
> # CONFIG_UTS_NS is not set
> # CONFIG_IPC_NS is not set
> # CONFIG_USER_NS is not set
> # CONFIG_PID_NS is not set
> # CONFIG_NET_NS is not set
> CONFIG_UIDGID_CONVERTED=3Dy
> # CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
> # CONFIG_SCHED_AUTOGROUP is not set
> # CONFIG_SYSFS_DEPRECATED is not set
> # CONFIG_RELAY is not set
> CONFIG_BLK_DEV_INITRD=3Dy
> CONFIG_INITRAMFS_SOURCE=3D"/home/iamroot/workbench/vm_zone/arm/buildr=
ootfs/rootfs/"
> CONFIG_INITRAMFS_ROOT_UID=3D0
> CONFIG_INITRAMFS_ROOT_GID=3D0
> CONFIG_RD_GZIP=3Dy
> CONFIG_RD_BZIP2=3Dy
> CONFIG_RD_LZMA=3Dy
> CONFIG_RD_XZ=3Dy
> CONFIG_RD_LZO=3Dy
> CONFIG_INITRAMFS_COMPRESSION_NONE=3Dy
> # CONFIG_INITRAMFS_COMPRESSION_GZIP is not set
> # CONFIG_INITRAMFS_COMPRESSION_BZIP2 is not set
> # CONFIG_INITRAMFS_COMPRESSION_LZMA is not set
> # CONFIG_INITRAMFS_COMPRESSION_XZ is not set
> # CONFIG_INITRAMFS_COMPRESSION_LZO is not set
> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> CONFIG_SYSCTL=3Dy
> CONFIG_ANON_INODES=3Dy
> CONFIG_HAVE_UID16=3Dy
> CONFIG_HOTPLUG=3Dy
> # CONFIG_EXPERT is not set
> CONFIG_UID16=3Dy
> # CONFIG_SYSCTL_SYSCALL is not set
> CONFIG_KALLSYMS=3Dy
> # CONFIG_KALLSYMS_ALL is not set
> CONFIG_PRINTK=3Dy
> CONFIG_BUG=3Dy
> CONFIG_ELF_CORE=3Dy
> CONFIG_BASE_FULL=3Dy
> CONFIG_FUTEX=3Dy
> CONFIG_EPOLL=3Dy
> CONFIG_SIGNALFD=3Dy
> CONFIG_TIMERFD=3Dy
> CONFIG_EVENTFD=3Dy
> CONFIG_SHMEM=3Dy
> CONFIG_AIO=3Dy
> # CONFIG_EMBEDDED is not set
> CONFIG_HAVE_PERF_EVENTS=3Dy
> CONFIG_PERF_USE_VMALLOC=3Dy
>=20
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=3Dy
> # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
> CONFIG_VM_EVENT_COUNTERS=3Dy
> CONFIG_SLUB_DEBUG=3Dy
> CONFIG_COMPAT_BRK=3Dy
> # CONFIG_SLAB is not set
> CONFIG_SLUB=3Dy
> CONFIG_PROFILING=3Dy
> CONFIG_OPROFILE=3Dy
> CONFIG_HAVE_OPROFILE=3Dy
> # CONFIG_KPROBES is not set
> # CONFIG_JUMP_LABEL is not set
> # CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
> CONFIG_HAVE_KPROBES=3Dy
> CONFIG_HAVE_KRETPROBES=3Dy
> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
> CONFIG_HAVE_DMA_ATTRS=3Dy
> CONFIG_HAVE_DMA_CONTIGUOUS=3Dy
> CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
> CONFIG_GENERIC_SMP_IDLE_THREAD=3Dy
> CONFIG_GENERIC_IDLE_POLL_SETUP=3Dy
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
> CONFIG_HAVE_CLK=3Dy
> CONFIG_HAVE_DMA_API_DEBUG=3Dy
> CONFIG_HAVE_HW_BREAKPOINT=3Dy
> CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy
> CONFIG_ARCH_WANT_IPC_PARSE_VERSION=3Dy
> CONFIG_HAVE_ARCH_SECCOMP_FILTER=3Dy
> CONFIG_HAVE_CONTEXT_TRACKING=3Dy
> CONFIG_HAVE_IRQ_TIME_ACCOUNTING=3Dy
> CONFIG_HAVE_MOD_ARCH_SPECIFIC=3Dy
> CONFIG_MODULES_USE_ELF_REL=3Dy
> CONFIG_CLONE_BACKWARDS=3Dy
> CONFIG_OLD_SIGSUSPEND3=3Dy
> CONFIG_OLD_SIGACTION=3Dy
>=20
> #
> # GCOV-based kernel profiling
> #
> # CONFIG_GCOV_KERNEL is not set
> CONFIG_HAVE_GENERIC_DMA_COHERENT=3Dy
> CONFIG_SLABINFO=3Dy
> CONFIG_RT_MUTEXES=3Dy
> CONFIG_BASE_SMALL=3D0
> CONFIG_MODULES=3Dy
> # CONFIG_MODULE_FORCE_LOAD is not set
> CONFIG_MODULE_UNLOAD=3Dy
> # CONFIG_MODULE_FORCE_UNLOAD is not set
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> # CONFIG_MODULE_SIG is not set
> CONFIG_STOP_MACHINE=3Dy
> CONFIG_BLOCK=3Dy
> # CONFIG_LBDAF is not set
> # CONFIG_BLK_DEV_BSG is not set
> # CONFIG_BLK_DEV_BSGLIB is not set
> # CONFIG_BLK_DEV_INTEGRITY is not set
>=20
> #
> # Partition Types
> #
> # CONFIG_PARTITION_ADVANCED is not set
> CONFIG_MSDOS_PARTITION=3Dy
> CONFIG_EFI_PARTITION=3Dy
>=20
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=3Dy
> # CONFIG_IOSCHED_DEADLINE is not set
> # CONFIG_IOSCHED_CFQ is not set
> CONFIG_DEFAULT_NOOP=3Dy
> CONFIG_DEFAULT_IOSCHED=3D"noop"
> CONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy
> CONFIG_INLINE_READ_UNLOCK=3Dy
> CONFIG_INLINE_READ_UNLOCK_IRQ=3Dy
> CONFIG_INLINE_WRITE_UNLOCK=3Dy
> CONFIG_INLINE_WRITE_UNLOCK_IRQ=3Dy
> CONFIG_MUTEX_SPIN_ON_OWNER=3Dy
> CONFIG_FREEZER=3Dy
>=20
> #
> # System Type
> #
> CONFIG_MMU=3Dy
> CONFIG_ARCH_MULTIPLATFORM=3Dy
> # CONFIG_ARCH_INTEGRATOR is not set
> # CONFIG_ARCH_REALVIEW is not set
> # CONFIG_ARCH_VERSATILE is not set
> # CONFIG_ARCH_AT91 is not set
> # CONFIG_ARCH_CLPS711X is not set
> # CONFIG_ARCH_GEMINI is not set
> # CONFIG_ARCH_EBSA110 is not set
> # CONFIG_ARCH_EP93XX is not set
> # CONFIG_ARCH_FOOTBRIDGE is not set
> # CONFIG_ARCH_NETX is not set
> # CONFIG_ARCH_IOP13XX is not set
> # CONFIG_ARCH_IOP32X is not set
> # CONFIG_ARCH_IOP33X is not set
> # CONFIG_ARCH_IXP4XX is not set
> # CONFIG_ARCH_DOVE is not set
> # CONFIG_ARCH_KIRKWOOD is not set
> # CONFIG_ARCH_MV78XX0 is not set
> # CONFIG_ARCH_ORION5X is not set
> # CONFIG_ARCH_MMP is not set
> # CONFIG_ARCH_KS8695 is not set
> # CONFIG_ARCH_W90X900 is not set
> # CONFIG_ARCH_LPC32XX is not set
> # CONFIG_ARCH_PXA is not set
> # CONFIG_ARCH_MSM is not set
> # CONFIG_ARCH_SHMOBILE is not set
> # CONFIG_ARCH_RPC is not set
> # CONFIG_ARCH_SA1100 is not set
> # CONFIG_ARCH_S3C24XX is not set
> # CONFIG_ARCH_S3C64XX is not set
> # CONFIG_ARCH_S5P64X0 is not set
> # CONFIG_ARCH_S5PC100 is not set
> # CONFIG_ARCH_S5PV210 is not set
> # CONFIG_ARCH_EXYNOS is not set
> # CONFIG_ARCH_SHARK is not set
> # CONFIG_ARCH_U300 is not set
> # CONFIG_ARCH_DAVINCI is not set
> # CONFIG_ARCH_OMAP1 is not set
>=20
> #
> # Multiple platform selection
> #
>=20
> #
> # CPU Core family selection
> #
> # CONFIG_ARCH_MULTI_V6 is not set
> CONFIG_ARCH_MULTI_V7=3Dy
> CONFIG_ARCH_MULTI_V6_V7=3Dy
> # CONFIG_ARCH_MULTI_CPU_AUTO is not set
> # CONFIG_ARCH_MVEBU is not set
> # CONFIG_ARCH_BCM is not set
> # CONFIG_KEYBOARD_GPIO_POLLED is not set
> # CONFIG_ARCH_HIGHBANK is not set
> # CONFIG_ARCH_MXC is not set
> # CONFIG_ARCH_OMAP2PLUS is not set
> # CONFIG_ARCH_SOCFPGA is not set
> # CONFIG_PLAT_SPEAR is not set
> # CONFIG_ARCH_SUNXI is not set
> # CONFIG_ARCH_SIRF is not set
> # CONFIG_ARCH_TEGRA is not set
> # CONFIG_ARCH_U8500 is not set
> CONFIG_ARCH_VEXPRESS=3Dy
>=20
> #
> # Versatile Express platform type
> #
> CONFIG_ARCH_VEXPRESS_CORTEX_A5_A9_ERRATA=3Dy
> CONFIG_ARCH_VEXPRESS_CA9X4=3Dy
> CONFIG_PLAT_VERSATILE_CLCD=3Dy
> CONFIG_PLAT_VERSATILE_SCHED_CLOCK=3Dy
> # CONFIG_ARCH_VIRT is not set
> # CONFIG_ARCH_WM8850 is not set
> # CONFIG_ARCH_ZYNQ is not set
> CONFIG_PLAT_VERSATILE=3Dy
> CONFIG_ARM_TIMER_SP804=3Dy
>=20
> #
> # Processor Type
> #
> CONFIG_CPU_V7=3Dy
> CONFIG_CPU_32v6K=3Dy
> CONFIG_CPU_32v7=3Dy
> CONFIG_CPU_ABRT_EV7=3Dy
> CONFIG_CPU_PABRT_V7=3Dy
> CONFIG_CPU_CACHE_V7=3Dy
> CONFIG_CPU_CACHE_VIPT=3Dy
> CONFIG_CPU_COPY_V6=3Dy
> CONFIG_CPU_TLB_V7=3Dy
> CONFIG_CPU_HAS_ASID=3Dy
> CONFIG_CPU_CP15=3Dy
> CONFIG_CPU_CP15_MMU=3Dy
>=20
> #
> # Processor Features
> #
> # CONFIG_ARM_LPAE is not set
> # CONFIG_ARCH_PHYS_ADDR_T_64BIT is not set
> CONFIG_ARM_THUMB=3Dy
> # CONFIG_ARM_THUMBEE is not set
> CONFIG_ARM_VIRT_EXT=3Dy
> # CONFIG_SWP_EMULATE is not set
> # CONFIG_CPU_ICACHE_DISABLE is not set
> # CONFIG_CPU_DCACHE_DISABLE is not set
> # CONFIG_CPU_BPREDICT_DISABLE is not set
> CONFIG_OUTER_CACHE=3Dy
> CONFIG_OUTER_CACHE_SYNC=3Dy
> CONFIG_MIGHT_HAVE_CACHE_L2X0=3Dy
> CONFIG_CACHE_L2X0=3Dy
> CONFIG_CACHE_PL310=3Dy
> CONFIG_ARM_L1_CACHE_SHIFT_6=3Dy
> CONFIG_ARM_L1_CACHE_SHIFT=3D6
> CONFIG_ARM_DMA_MEM_BUFFERABLE=3Dy
> CONFIG_ARM_NR_BANKS=3D8
> CONFIG_MULTI_IRQ_HANDLER=3Dy
> # CONFIG_ARM_ERRATA_430973 is not set
> # CONFIG_PL310_ERRATA_588369 is not set
> CONFIG_ARM_ERRATA_720789=3Dy
> # CONFIG_PL310_ERRATA_727915 is not set
> CONFIG_PL310_ERRATA_753970=3Dy
> # CONFIG_ARM_ERRATA_754322 is not set
> # CONFIG_ARM_ERRATA_754327 is not set
> # CONFIG_ARM_ERRATA_764369 is not set
> # CONFIG_PL310_ERRATA_769419 is not set
> # CONFIG_ARM_ERRATA_775420 is not set
> # CONFIG_ARM_ERRATA_798181 is not set
> CONFIG_ICST=3Dy
>=20
> #
> # Bus support
> #
> CONFIG_ARM_AMBA=3Dy
> # CONFIG_PCI_SYSCALL is not set
> # CONFIG_PCCARD is not set
>=20
> #
> # Kernel Features
> #
> CONFIG_HAVE_SMP=3Dy
> CONFIG_SMP=3Dy
> CONFIG_SMP_ON_UP=3Dy
> CONFIG_ARM_CPU_TOPOLOGY=3Dy
> # CONFIG_SCHED_MC is not set
> # CONFIG_SCHED_SMT is not set
> CONFIG_HAVE_ARM_SCU=3Dy
> # CONFIG_HAVE_ARM_ARCH_TIMER is not set
> CONFIG_HAVE_ARM_TWD=3Dy
> # CONFIG_MCPM is not set
> # CONFIG_VMSPLIT_3G is not set
> CONFIG_VMSPLIT_2G=3Dy
> # CONFIG_VMSPLIT_1G is not set
> CONFIG_PAGE_OFFSET=3D0x80000000
> CONFIG_NR_CPUS=3D4
> CONFIG_HOTPLUG_CPU=3Dy
> # CONFIG_ARM_PSCI is not set
> CONFIG_LOCAL_TIMERS=3Dy
> CONFIG_ARCH_NR_GPIO=3D0
> CONFIG_PREEMPT_NONE=3Dy
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_HZ=3D100
> # CONFIG_SCHED_HRTICK is not set
> # CONFIG_THUMB2_KERNEL is not set
> CONFIG_AEABI=3Dy
> CONFIG_OABI_COMPAT=3Dy
> # CONFIG_ARCH_SPARSEMEM_DEFAULT is not set
> # CONFIG_ARCH_SELECT_MEMORY_MODEL is not set
> CONFIG_HAVE_ARCH_PFN_VALID=3Dy
> # CONFIG_HIGHMEM is not set
> CONFIG_HW_PERF_EVENTS=3Dy
> CONFIG_FLATMEM=3Dy
> CONFIG_FLAT_NODE_MEM_MAP=3Dy
> CONFIG_HAVE_MEMBLOCK=3Dy
> # CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
> CONFIG_PAGEFLAGS_EXTENDED=3Dy
> CONFIG_SPLIT_PTLOCK_CPUS=3D4
> CONFIG_COMPACTION=3Dy
> CONFIG_MIGRATION=3Dy
> # CONFIG_PHYS_ADDR_T_64BIT is not set
> CONFIG_ZONE_DMA_FLAG=3D0
> # CONFIG_KSM is not set
> CONFIG_DEFAULT_MMAP_MIN_ADDR=3D4096
> CONFIG_CROSS_MEMORY_ATTACH=3Dy
> # CONFIG_CLEANCACHE is not set
> # CONFIG_FRONTSWAP is not set
> CONFIG_FORCE_MAX_ZONEORDER=3D11
> CONFIG_ALIGNMENT_TRAP=3Dy
> # CONFIG_UACCESS_WITH_MEMCPY is not set
> # CONFIG_SECCOMP is not set
> # CONFIG_CC_STACKPROTECTOR is not set
> # CONFIG_XEN is not set
>=20
> #
> # Boot options
> #
> CONFIG_USE_OF=3Dy
> CONFIG_ATAGS=3Dy
> # CONFIG_DEPRECATED_PARAM_STRUCT is not set
> CONFIG_ZBOOT_ROM_TEXT=3D0x0
> CONFIG_ZBOOT_ROM_BSS=3D0x0
> # CONFIG_ARM_APPENDED_DTB is not set
> CONFIG_CMDLINE=3D"root=3D/dev/nfs nfsroot=3D10.1.69.3:/work/nfsroot i=
p=3Ddhcp console=3DttyAMA0 mem=3D128M"
> CONFIG_CMDLINE_FROM_BOOTLOADER=3Dy
> # CONFIG_CMDLINE_EXTEND is not set
> # CONFIG_CMDLINE_FORCE is not set
> # CONFIG_KEXEC is not set
> # CONFIG_CRASH_DUMP is not set
> CONFIG_AUTO_ZRELADDR=3Dy
>=20
> #
> # CPU Power Management
> #
> # CONFIG_CPU_IDLE is not set
> # CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
>=20
> #
> # Floating point emulation
> #
>=20
> #
> # At least one emulation must be selected
> #
> # CONFIG_FPE_NWFPE is not set
> # CONFIG_FPE_FASTFPE is not set
> CONFIG_VFP=3Dy
> CONFIG_VFPv3=3Dy
> CONFIG_NEON=3Dy
>=20
> #
> # Userspace binary formats
> #
> CONFIG_BINFMT_ELF=3Dy
> CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=3Dy
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> CONFIG_BINFMT_SCRIPT=3Dy
> CONFIG_HAVE_AOUT=3Dy
> # CONFIG_BINFMT_AOUT is not set
> # CONFIG_BINFMT_MISC is not set
> CONFIG_COREDUMP=3Dy
>=20
> #
> # Power management options
> #
> CONFIG_SUSPEND=3Dy
> CONFIG_SUSPEND_FREEZER=3Dy
> CONFIG_PM_SLEEP=3Dy
> CONFIG_PM_SLEEP_SMP=3Dy
> # CONFIG_PM_AUTOSLEEP is not set
> # CONFIG_PM_WAKELOCKS is not set
> # CONFIG_PM_RUNTIME is not set
> CONFIG_PM=3Dy
> # CONFIG_PM_DEBUG is not set
> # CONFIG_APM_EMULATION is not set
> CONFIG_PM_CLK=3Dy
> CONFIG_CPU_PM=3Dy
> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
> CONFIG_ARM_CPU_SUSPEND=3Dy
> CONFIG_NET=3Dy
>=20
> #
> # Networking options
> #
> CONFIG_PACKET=3Dy
> # CONFIG_PACKET_DIAG is not set
> CONFIG_UNIX=3Dy
> # CONFIG_UNIX_DIAG is not set
> CONFIG_XFRM=3Dy
> CONFIG_XFRM_ALGO=3Dy
> # CONFIG_XFRM_USER is not set
> # CONFIG_XFRM_SUB_POLICY is not set
> # CONFIG_XFRM_MIGRATE is not set
> CONFIG_XFRM_STATISTICS=3Dy
> CONFIG_NET_KEY=3Dy
> # CONFIG_NET_KEY_MIGRATE is not set
> CONFIG_INET=3Dy
> # CONFIG_IP_MULTICAST is not set
> # CONFIG_IP_ADVANCED_ROUTER is not set
> CONFIG_IP_PNP=3Dy
> CONFIG_IP_PNP_DHCP=3Dy
> CONFIG_IP_PNP_BOOTP=3Dy
> # CONFIG_IP_PNP_RARP is not set
> # CONFIG_NET_IPIP is not set
> # CONFIG_NET_IPGRE_DEMUX is not set
> # CONFIG_NET_IP_TUNNEL is not set
> # CONFIG_ARPD is not set
> # CONFIG_SYN_COOKIES is not set
> # CONFIG_NET_IPVTI is not set
> # CONFIG_INET_AH is not set
> # CONFIG_INET_ESP is not set
> # CONFIG_INET_IPCOMP is not set
> # CONFIG_INET_XFRM_TUNNEL is not set
> # CONFIG_INET_TUNNEL is not set
> CONFIG_INET_XFRM_MODE_TRANSPORT=3Dy
> CONFIG_INET_XFRM_MODE_TUNNEL=3Dy
> CONFIG_INET_XFRM_MODE_BEET=3Dy
> # CONFIG_INET_LRO is not set
> CONFIG_INET_DIAG=3Dy
> CONFIG_INET_TCP_DIAG=3Dy
> # CONFIG_INET_UDP_DIAG is not set
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_TCP_CONG_CUBIC=3Dy
> CONFIG_DEFAULT_TCP_CONG=3D"cubic"
> # CONFIG_TCP_MD5SIG is not set
> # CONFIG_IPV6 is not set
> # CONFIG_NETWORK_SECMARK is not set
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> # CONFIG_NETFILTER is not set
> # CONFIG_IP_DCCP is not set
> # CONFIG_IP_SCTP is not set
> # CONFIG_RDS is not set
> # CONFIG_TIPC is not set
> # CONFIG_ATM is not set
> # CONFIG_L2TP is not set
> # CONFIG_BRIDGE is not set
> CONFIG_HAVE_NET_DSA=3Dy
> # CONFIG_VLAN_8021Q is not set
> # CONFIG_DECNET is not set
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_PHONET is not set
> # CONFIG_IEEE802154 is not set
> # CONFIG_NET_SCHED is not set
> # CONFIG_DCB is not set
> # CONFIG_BATMAN_ADV is not set
> # CONFIG_OPENVSWITCH is not set
> # CONFIG_VSOCKETS is not set
> # CONFIG_NETLINK_MMAP is not set
> # CONFIG_NETLINK_DIAG is not set
> # CONFIG_NET_MPLS_GSO is not set
> CONFIG_RPS=3Dy
> CONFIG_RFS_ACCEL=3Dy
> CONFIG_XPS=3Dy
> # CONFIG_NETPRIO_CGROUP is not set
> CONFIG_BQL=3Dy
> # CONFIG_BPF_JIT is not set
> CONFIG_NET_FLOW_LIMIT=3Dy
>=20
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> # CONFIG_AF_RXRPC is not set
> # CONFIG_WIRELESS is not set
> # CONFIG_WIMAX is not set
> # CONFIG_RFKILL is not set
> # CONFIG_NET_9P is not set
> # CONFIG_CAIF is not set
> # CONFIG_CEPH_LIB is not set
> # CONFIG_NFC is not set
> CONFIG_HAVE_BPF_JIT=3Dy
>=20
> #
> # Device Drivers
> #
>=20
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
> CONFIG_DEVTMPFS=3Dy
> CONFIG_DEVTMPFS_MOUNT=3Dy
> CONFIG_STANDALONE=3Dy
> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
> CONFIG_FW_LOADER=3Dy
> CONFIG_FIRMWARE_IN_KERNEL=3Dy
> CONFIG_EXTRA_FIRMWARE=3D""
> CONFIG_FW_LOADER_USER_HELPER=3Dy
> # CONFIG_DEBUG_DRIVER is not set
> # CONFIG_DEBUG_DEVRES is not set
> # CONFIG_SYS_HYPERVISOR is not set
> # CONFIG_GENERIC_CPU_DEVICES is not set
> # CONFIG_DMA_SHARED_BUFFER is not set
> # CONFIG_CMA is not set
>=20
> #
> # Bus devices
> #
> # CONFIG_CONNECTOR is not set
> CONFIG_MTD=3Dy
> # CONFIG_MTD_TESTS is not set
> # CONFIG_MTD_REDBOOT_PARTS is not set
> CONFIG_MTD_CMDLINE_PARTS=3Dy
> # CONFIG_MTD_AFS_PARTS is not set
> CONFIG_MTD_OF_PARTS=3Dy
> # CONFIG_MTD_AR7_PARTS is not set
>=20
> #
> # User Modules And Translation Layers
> #
> CONFIG_MTD_BLKDEVS=3Dy
> CONFIG_MTD_BLOCK=3Dy
> # CONFIG_FTL is not set
> # CONFIG_NFTL is not set
> # CONFIG_INFTL is not set
> # CONFIG_RFD_FTL is not set
> # CONFIG_SSFDC is not set
> # CONFIG_SM_FTL is not set
> # CONFIG_MTD_OOPS is not set
> # CONFIG_MTD_SWAP is not set
>=20
> #
> # RAM/ROM/Flash chip drivers
> #
> CONFIG_MTD_CFI=3Dy
> # CONFIG_MTD_JEDECPROBE is not set
> CONFIG_MTD_GEN_PROBE=3Dy
> # CONFIG_MTD_CFI_ADV_OPTIONS is not set
> CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_2=3Dy
> CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy
> # CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
> # CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
> CONFIG_MTD_CFI_I1=3Dy
> CONFIG_MTD_CFI_I2=3Dy
> # CONFIG_MTD_CFI_I4 is not set
> # CONFIG_MTD_CFI_I8 is not set
> CONFIG_MTD_CFI_INTELEXT=3Dy
> CONFIG_MTD_CFI_AMDSTD=3Dy
> # CONFIG_MTD_CFI_STAA is not set
> CONFIG_MTD_CFI_UTIL=3Dy
> # CONFIG_MTD_RAM is not set
> # CONFIG_MTD_ROM is not set
> # CONFIG_MTD_ABSENT is not set
>=20
> #
> # Mapping drivers for chip access
> #
> # CONFIG_MTD_COMPLEX_MAPPINGS is not set
> # CONFIG_MTD_PHYSMAP is not set
> # CONFIG_MTD_PHYSMAP_OF is not set
> # CONFIG_MTD_PLATRAM is not set
>=20
> #
> # Self-contained MTD device drivers
> #
> # CONFIG_MTD_SLRAM is not set
> # CONFIG_MTD_PHRAM is not set
> # CONFIG_MTD_MTDRAM is not set
> # CONFIG_MTD_BLOCK2MTD is not set
>=20
> #
> # Disk-On-Chip Device Drivers
> #
> # CONFIG_MTD_DOCG3 is not set
> # CONFIG_MTD_NAND is not set
> # CONFIG_MTD_ONENAND is not set
>=20
> #
> # LPDDR flash memory drivers
> #
> # CONFIG_MTD_LPDDR is not set
> # CONFIG_MTD_UBI is not set
> CONFIG_DTC=3Dy
> CONFIG_OF=3Dy
>=20
> #
> # Device Tree and Open Firmware support
> #
> # CONFIG_PROC_DEVICETREE is not set
> # CONFIG_OF_SELFTEST is not set
> CONFIG_OF_FLATTREE=3Dy
> CONFIG_OF_EARLY_FLATTREE=3Dy
> CONFIG_OF_ADDRESS=3Dy
> CONFIG_OF_IRQ=3Dy
> CONFIG_OF_DEVICE=3Dy
> CONFIG_OF_NET=3Dy
> CONFIG_OF_MDIO=3Dy
> CONFIG_OF_MTD=3Dy
> # CONFIG_PARPORT is not set
> CONFIG_BLK_DEV=3Dy
> # CONFIG_BLK_DEV_COW_COMMON is not set
> # CONFIG_BLK_DEV_LOOP is not set
> # CONFIG_BLK_DEV_DRBD is not set
> # CONFIG_BLK_DEV_NBD is not set
> CONFIG_BLK_DEV_RAM=3Dy
> CONFIG_BLK_DEV_RAM_COUNT=3D16
> CONFIG_BLK_DEV_RAM_SIZE=3D4096
> # CONFIG_BLK_DEV_XIP is not set
> # CONFIG_CDROM_PKTCDVD is not set
> # CONFIG_ATA_OVER_ETH is not set
> # CONFIG_MG_DISK is not set
> # CONFIG_BLK_DEV_RBD is not set
>=20
> #
> # Misc devices
> #
> # CONFIG_SENSORS_LIS3LV02D is not set
> # CONFIG_ATMEL_PWM is not set
> # CONFIG_DUMMY_IRQ is not set
> # CONFIG_ATMEL_SSC is not set
> # CONFIG_ENCLOSURE_SERVICES is not set
> # CONFIG_ARM_CHARLCD is not set
> # CONFIG_SRAM is not set
> # CONFIG_C2PORT is not set
>=20
> #
> # EEPROM support
> #
> # CONFIG_EEPROM_93CX6 is not set
>=20
> #
> # Texas Instruments shared transport line discipline
> #
> # CONFIG_TI_ST is not set
>=20
> #
> # Altera FPGA firmware download module
> #
>=20
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=3Dy
> # CONFIG_RAID_ATTRS is not set
> CONFIG_SCSI=3Dy
> CONFIG_SCSI_DMA=3Dy
> # CONFIG_SCSI_TGT is not set
> # CONFIG_SCSI_NETLINK is not set
> # CONFIG_SCSI_PROC_FS is not set
>=20
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=3Dy
> # CONFIG_CHR_DEV_ST is not set
> # CONFIG_CHR_DEV_OSST is not set
> # CONFIG_BLK_DEV_SR is not set
> # CONFIG_CHR_DEV_SG is not set
> # CONFIG_CHR_DEV_SCH is not set
> # CONFIG_SCSI_MULTI_LUN is not set
> # CONFIG_SCSI_CONSTANTS is not set
> # CONFIG_SCSI_LOGGING is not set
> # CONFIG_SCSI_SCAN_ASYNC is not set
>=20
> #
> # SCSI Transports
> #
> # CONFIG_SCSI_SPI_ATTRS is not set
> # CONFIG_SCSI_FC_ATTRS is not set
> # CONFIG_SCSI_ISCSI_ATTRS is not set
> # CONFIG_SCSI_SAS_ATTRS is not set
> # CONFIG_SCSI_SAS_LIBSAS is not set
> # CONFIG_SCSI_SRP_ATTRS is not set
> # CONFIG_SCSI_LOWLEVEL is not set
> # CONFIG_SCSI_DH is not set
> # CONFIG_SCSI_OSD_INITIATOR is not set
> CONFIG_HAVE_PATA_PLATFORM=3Dy
> CONFIG_ATA=3Dy
> # CONFIG_ATA_NONSTANDARD is not set
> CONFIG_ATA_VERBOSE_ERROR=3Dy
> # CONFIG_SATA_PMP is not set
>=20
> #
> # Controllers with non-SFF native interface
> #
> # CONFIG_SATA_AHCI_PLATFORM is not set
> CONFIG_ATA_SFF=3Dy
>=20
> #
> # SFF controllers with custom DMA interface
> #
> CONFIG_ATA_BMDMA=3Dy
>=20
> #
> # SATA SFF controllers with BMDMA
> #
> # CONFIG_SATA_HIGHBANK is not set
> # CONFIG_SATA_MV is not set
>=20
> #
> # PATA SFF controllers with BMDMA
> #
>=20
> #
> # PIO-only SFF controllers
> #
> # CONFIG_PATA_PLATFORM is not set
>=20
> #
> # Generic fallback / legacy drivers
> #
> # CONFIG_MD is not set
> # CONFIG_TARGET_CORE is not set
> CONFIG_NETDEVICES=3Dy
> CONFIG_NET_CORE=3Dy
> # CONFIG_BONDING is not set
> # CONFIG_DUMMY is not set
> # CONFIG_EQUALIZER is not set
> CONFIG_MII=3Dy
> # CONFIG_NET_TEAM is not set
> # CONFIG_MACVLAN is not set
> # CONFIG_VXLAN is not set
> # CONFIG_NETCONSOLE is not set
> # CONFIG_NETPOLL is not set
> # CONFIG_NET_POLL_CONTROLLER is not set
> # CONFIG_TUN is not set
> # CONFIG_VETH is not set
>=20
> #
> # CAIF transport drivers
> #
>=20
> #
> # Distributed Switch Architecture drivers
> #
> # CONFIG_NET_DSA_MV88E6XXX is not set
> # CONFIG_NET_DSA_MV88E6060 is not set
> # CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
> # CONFIG_NET_DSA_MV88E6131 is not set
> # CONFIG_NET_DSA_MV88E6123_61_65 is not set
> CONFIG_ETHERNET=3Dy
> CONFIG_NET_CADENCE=3Dy
> # CONFIG_ARM_AT91_ETHER is not set
> # CONFIG_MACB is not set
> CONFIG_NET_VENDOR_BROADCOM=3Dy
> # CONFIG_B44 is not set
> # CONFIG_NET_CALXEDA_XGMAC is not set
> CONFIG_NET_VENDOR_CIRRUS=3Dy
> # CONFIG_CS89x0 is not set
> # CONFIG_DM9000 is not set
> # CONFIG_DNET is not set
> CONFIG_NET_VENDOR_FARADAY=3Dy
> # CONFIG_FTMAC100 is not set
> # CONFIG_FTGMAC100 is not set
> CONFIG_NET_VENDOR_INTEL=3Dy
> CONFIG_NET_VENDOR_I825XX=3Dy
> CONFIG_NET_VENDOR_MARVELL=3Dy
> # CONFIG_MVMDIO is not set
> CONFIG_NET_VENDOR_MICREL=3Dy
> # CONFIG_KS8851_MLL is not set
> CONFIG_NET_VENDOR_NATSEMI=3Dy
> CONFIG_NET_VENDOR_8390=3Dy
> # CONFIG_AX88796 is not set
> # CONFIG_ETHOC is not set
> CONFIG_NET_VENDOR_SEEQ=3Dy
> CONFIG_NET_VENDOR_SMSC=3Dy
> # CONFIG_SMC91X is not set
> # CONFIG_SMC911X is not set
> CONFIG_SMSC911X=3Dy
> # CONFIG_SMSC911X_ARCH_HOOKS is not set
> CONFIG_NET_VENDOR_STMICRO=3Dy
> # CONFIG_STMMAC_ETH is not set
> CONFIG_NET_VENDOR_VIA=3Dy
> # CONFIG_VIA_VELOCITY is not set
> CONFIG_NET_VENDOR_WIZNET=3Dy
> # CONFIG_WIZNET_W5100 is not set
> # CONFIG_WIZNET_W5300 is not set
> CONFIG_PHYLIB=3Dy
>=20
> #
> # MII PHY device drivers
> #
> # CONFIG_AT803X_PHY is not set
> # CONFIG_AMD_PHY is not set
> # CONFIG_MARVELL_PHY is not set
> # CONFIG_DAVICOM_PHY is not set
> # CONFIG_QSEMI_PHY is not set
> # CONFIG_LXT_PHY is not set
> # CONFIG_CICADA_PHY is not set
> # CONFIG_VITESSE_PHY is not set
> # CONFIG_SMSC_PHY is not set
> # CONFIG_BROADCOM_PHY is not set
> # CONFIG_BCM87XX_PHY is not set
> # CONFIG_ICPLUS_PHY is not set
> # CONFIG_REALTEK_PHY is not set
> # CONFIG_NATIONAL_PHY is not set
> # CONFIG_STE10XP is not set
> # CONFIG_LSI_ET1011C_PHY is not set
> # CONFIG_MICREL_PHY is not set
> # CONFIG_FIXED_PHY is not set
> # CONFIG_MDIO_BITBANG is not set
> # CONFIG_MDIO_BUS_MUX_GPIO is not set
> # CONFIG_MDIO_BUS_MUX_MMIOREG is not set
> # CONFIG_PPP is not set
> # CONFIG_SLIP is not set
> # CONFIG_WLAN is not set
>=20
> #
> # Enable WiMAX (Networking options) to see the WiMAX drivers
> #
> # CONFIG_WAN is not set
> # CONFIG_ISDN is not set
>=20
> #
> # Input device support
> #
> CONFIG_INPUT=3Dy
> # CONFIG_INPUT_FF_MEMLESS is not set
> # CONFIG_INPUT_POLLDEV is not set
> # CONFIG_INPUT_SPARSEKMAP is not set
> # CONFIG_INPUT_MATRIXKMAP is not set
>=20
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=3Dy
> CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
> # CONFIG_INPUT_JOYDEV is not set
> CONFIG_INPUT_EVDEV=3Dy
> # CONFIG_INPUT_EVBUG is not set
>=20
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=3Dy
> CONFIG_KEYBOARD_ATKBD=3Dy
> # CONFIG_KEYBOARD_LKKBD is not set
> # CONFIG_KEYBOARD_GPIO is not set
> # CONFIG_KEYBOARD_MATRIX is not set
> # CONFIG_KEYBOARD_NEWTON is not set
> # CONFIG_KEYBOARD_OPENCORES is not set
> # CONFIG_KEYBOARD_SAMSUNG is not set
> # CONFIG_KEYBOARD_STOWAWAY is not set
> # CONFIG_KEYBOARD_SUNKBD is not set
> # CONFIG_KEYBOARD_XTKBD is not set
> CONFIG_INPUT_MOUSE=3Dy
> CONFIG_MOUSE_PS2=3Dy
> CONFIG_MOUSE_PS2_ALPS=3Dy
> CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy
> CONFIG_MOUSE_PS2_SYNAPTICS=3Dy
> CONFIG_MOUSE_PS2_CYPRESS=3Dy
> CONFIG_MOUSE_PS2_TRACKPOINT=3Dy
> # CONFIG_MOUSE_PS2_ELANTECH is not set
> # CONFIG_MOUSE_PS2_SENTELIC is not set
> # CONFIG_MOUSE_PS2_TOUCHKIT is not set
> # CONFIG_MOUSE_SERIAL is not set
> # CONFIG_MOUSE_VSXXXAA is not set
> # CONFIG_MOUSE_GPIO is not set
> # CONFIG_INPUT_JOYSTICK is not set
> # CONFIG_INPUT_TABLET is not set
> # CONFIG_INPUT_TOUCHSCREEN is not set
> # CONFIG_INPUT_MISC is not set
>=20
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=3Dy
> # CONFIG_SERIO_SERPORT is not set
> CONFIG_SERIO_AMBAKMI=3Dy
> CONFIG_SERIO_LIBPS2=3Dy
> # CONFIG_SERIO_RAW is not set
> # CONFIG_SERIO_ALTERA_PS2 is not set
> # CONFIG_SERIO_PS2MULT is not set
> # CONFIG_SERIO_ARC_PS2 is not set
> # CONFIG_SERIO_APBPS2 is not set
> # CONFIG_GAMEPORT is not set
>=20
> #
> # Character devices
> #
> CONFIG_TTY=3Dy
> CONFIG_VT=3Dy
> CONFIG_CONSOLE_TRANSLATIONS=3Dy
> CONFIG_VT_CONSOLE=3Dy
> CONFIG_VT_CONSOLE_SLEEP=3Dy
> CONFIG_HW_CONSOLE=3Dy
> # CONFIG_VT_HW_CONSOLE_BINDING is not set
> CONFIG_UNIX98_PTYS=3Dy
> # CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
> CONFIG_LEGACY_PTYS=3Dy
> CONFIG_LEGACY_PTY_COUNT=3D16
> # CONFIG_SERIAL_NONSTANDARD is not set
> # CONFIG_N_GSM is not set
> # CONFIG_TRACE_SINK is not set
> CONFIG_DEVKMEM=3Dy
>=20
> #
> # Serial drivers
> #
> # CONFIG_SERIAL_8250 is not set
>=20
> #
> # Non-8250 serial port support
> #
> # CONFIG_SERIAL_AMBA_PL010 is not set
> CONFIG_SERIAL_AMBA_PL011=3Dy
> CONFIG_SERIAL_AMBA_PL011_CONSOLE=3Dy
> CONFIG_SERIAL_CORE=3Dy
> CONFIG_SERIAL_CORE_CONSOLE=3Dy
> # CONFIG_SERIAL_SCCNXP is not set
> # CONFIG_SERIAL_TIMBERDALE is not set
> # CONFIG_SERIAL_ALTERA_JTAGUART is not set
> # CONFIG_SERIAL_ALTERA_UART is not set
> # CONFIG_SERIAL_XILINX_PS_UART is not set
> # CONFIG_SERIAL_ARC is not set
> # CONFIG_HVC_DCC is not set
> # CONFIG_IPMI_HANDLER is not set
> # CONFIG_HW_RANDOM is not set
> # CONFIG_R3964 is not set
> # CONFIG_RAW_DRIVER is not set
> # CONFIG_TCG_TPM is not set
> # CONFIG_I2C is not set
> # CONFIG_SPI is not set
>=20
> #
> # Qualcomm MSM SSBI bus support
> #
> # CONFIG_SSBI is not set
> # CONFIG_HSI is not set
>=20
> #
> # PPS support
> #
> # CONFIG_PPS is not set
>=20
> #
> # PPS generators support
> #
>=20
> #
> # PTP clock support
> #
> # CONFIG_PTP_1588_CLOCK is not set
>=20
> #
> # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional cl=
ocks.
> #
> # CONFIG_PTP_1588_CLOCK_PCH is not set
> CONFIG_ARCH_HAVE_CUSTOM_GPIO_H=3Dy
> CONFIG_ARCH_REQUIRE_GPIOLIB=3Dy
> CONFIG_GPIO_DEVRES=3Dy
> CONFIG_GPIOLIB=3Dy
> CONFIG_OF_GPIO=3Dy
> # CONFIG_DEBUG_GPIO is not set
> # CONFIG_GPIO_SYSFS is not set
>=20
> #
> # Memory mapped GPIO drivers:
> #
> # CONFIG_GPIO_GENERIC_PLATFORM is not set
> # CONFIG_GPIO_EM is not set
> # CONFIG_GPIO_PL061 is not set
> # CONFIG_GPIO_RCAR is not set
> # CONFIG_GPIO_TS5500 is not set
> # CONFIG_GPIO_GRGPIO is not set
>=20
> #
> # I2C GPIO expanders:
> #
>=20
> #
> # PCI GPIO expanders:
> #
>=20
> #
> # SPI GPIO expanders:
> #
>=20
> #
> # AC97 GPIO expanders:
> #
>=20
> #
> # MODULbus GPIO expanders:
> #
>=20
> #
> # USB GPIO expanders:
> #
> # CONFIG_W1 is not set
> CONFIG_POWER_SUPPLY=3Dy
> # CONFIG_POWER_SUPPLY_DEBUG is not set
> # CONFIG_PDA_POWER is not set
> # CONFIG_TEST_POWER is not set
> # CONFIG_BATTERY_DS2780 is not set
> # CONFIG_BATTERY_DS2781 is not set
> # CONFIG_BATTERY_BQ27x00 is not set
> # CONFIG_CHARGER_MAX8903 is not set
> # CONFIG_CHARGER_GPIO is not set
> # CONFIG_BATTERY_GOLDFISH is not set
> CONFIG_POWER_RESET=3Dy
> # CONFIG_POWER_RESET_GPIO is not set
> # CONFIG_POWER_RESET_RESTART is not set
> CONFIG_POWER_RESET_VEXPRESS=3Dy
> # CONFIG_POWER_AVS is not set
> # CONFIG_HWMON is not set
> # CONFIG_THERMAL is not set
> # CONFIG_WATCHDOG is not set
> CONFIG_SSB_POSSIBLE=3Dy
>=20
> #
> # Sonics Silicon Backplane
> #
> # CONFIG_SSB is not set
> CONFIG_BCMA_POSSIBLE=3Dy
>=20
> #
> # Broadcom specific AMBA
> #
> # CONFIG_BCMA is not set
>=20
> #
> # Multifunction device drivers
> #
> # CONFIG_MFD_CORE is not set
> # CONFIG_MFD_CROS_EC is not set
> # CONFIG_MFD_ASIC3 is not set
> # CONFIG_HTC_EGPIO is not set
> # CONFIG_HTC_PASIC3 is not set
> # CONFIG_MFD_SM501 is not set
> # CONFIG_ABX500_CORE is not set
> # CONFIG_MFD_SYSCON is not set
> # CONFIG_MFD_TI_AM335X_TSCADC is not set
> # CONFIG_MFD_TPS65912 is not set
> # CONFIG_MFD_TMIO is not set
> # CONFIG_MFD_T7L66XB is not set
> # CONFIG_MFD_TC6387XB is not set
> # CONFIG_MFD_TC6393XB is not set
> CONFIG_VEXPRESS_CONFIG=3Dy
> # CONFIG_REGULATOR is not set
> # CONFIG_MEDIA_SUPPORT is not set
>=20
> #
> # Graphics support
> #
> # CONFIG_DRM is not set
> # CONFIG_TEGRA_HOST1X is not set
> # CONFIG_VGASTATE is not set
> # CONFIG_VIDEO_OUTPUT_CONTROL is not set
> # CONFIG_FB is not set
> # CONFIG_EXYNOS_VIDEO is not set
> # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
>=20
> #
> # Console display driver support
> #
> CONFIG_DUMMY_CONSOLE=3Dy
> # CONFIG_SOUND is not set
>=20
> #
> # HID support
> #
> CONFIG_HID=3Dy
> # CONFIG_HID_BATTERY_STRENGTH is not set
> # CONFIG_HIDRAW is not set
> # CONFIG_UHID is not set
> CONFIG_HID_GENERIC=3Dy
>=20
> #
> # Special HID drivers
> #
> CONFIG_HID_A4TECH=3Dy
> # CONFIG_HID_ACRUX is not set
> CONFIG_HID_APPLE=3Dy
> # CONFIG_HID_AUREAL is not set
> CONFIG_HID_BELKIN=3Dy
> CONFIG_HID_CHERRY=3Dy
> CONFIG_HID_CHICONY=3Dy
> CONFIG_HID_CYPRESS=3Dy
> CONFIG_HID_DRAGONRISE=3Dy
> # CONFIG_DRAGONRISE_FF is not set
> # CONFIG_HID_EMS_FF is not set
> # CONFIG_HID_ELECOM is not set
> CONFIG_HID_EZKEY=3Dy
> # CONFIG_HID_KEYTOUCH is not set
> # CONFIG_HID_KYE is not set
> # CONFIG_HID_UCLOGIC is not set
> # CONFIG_HID_WALTOP is not set
> CONFIG_HID_GYRATION=3Dy
> # CONFIG_HID_ICADE is not set
> CONFIG_HID_TWINHAN=3Dy
> CONFIG_HID_KENSINGTON=3Dy
> # CONFIG_HID_LCPOWER is not set
> CONFIG_HID_LOGITECH=3Dy
> # CONFIG_HID_LOGITECH_DJ is not set
> # CONFIG_LOGITECH_FF is not set
> # CONFIG_LOGIRUMBLEPAD2_FF is not set
> # CONFIG_LOGIG940_FF is not set
> # CONFIG_LOGIWHEELS_FF is not set
> # CONFIG_HID_MAGICMOUSE is not set
> CONFIG_HID_MICROSOFT=3Dy
> CONFIG_HID_MONTEREY=3Dy
> # CONFIG_HID_MULTITOUCH is not set
> # CONFIG_HID_ORTEK is not set
> CONFIG_HID_PANTHERLORD=3Dy
> # CONFIG_PANTHERLORD_FF is not set
> CONFIG_HID_PETALYNX=3Dy
> # CONFIG_HID_PICOLCD is not set
> # CONFIG_HID_PRIMAX is not set
> # CONFIG_HID_PS3REMOTE is not set
> # CONFIG_HID_SAITEK is not set
> CONFIG_HID_SAMSUNG=3Dy
> # CONFIG_HID_SPEEDLINK is not set
> # CONFIG_HID_STEELSERIES is not set
> CONFIG_HID_SUNPLUS=3Dy
> CONFIG_HID_GREENASIA=3Dy
> # CONFIG_GREENASIA_FF is not set
> CONFIG_HID_SMARTJOYPLUS=3Dy
> # CONFIG_SMARTJOYPLUS_FF is not set
> # CONFIG_HID_TIVO is not set
> CONFIG_HID_TOPSEED=3Dy
> CONFIG_HID_THRUSTMASTER=3Dy
> # CONFIG_THRUSTMASTER_FF is not set
> CONFIG_HID_ZEROPLUS=3Dy
> # CONFIG_ZEROPLUS_FF is not set
> # CONFIG_HID_ZYDACRON is not set
> # CONFIG_HID_SENSOR_HUB is not set
> # CONFIG_USB_ARCH_HAS_OHCI is not set
> # CONFIG_USB_ARCH_HAS_EHCI is not set
> # CONFIG_USB_ARCH_HAS_XHCI is not set
> # CONFIG_USB_SUPPORT is not set
> # CONFIG_MMC is not set
> # CONFIG_MEMSTICK is not set
> # CONFIG_NEW_LEDS is not set
> # CONFIG_ACCESSIBILITY is not set
> # CONFIG_EDAC is not set
> CONFIG_RTC_LIB=3Dy
> CONFIG_RTC_CLASS=3Dy
> CONFIG_RTC_HCTOSYS=3Dy
> CONFIG_RTC_SYSTOHC=3Dy
> CONFIG_RTC_HCTOSYS_DEVICE=3D"rtc0"
> # CONFIG_RTC_DEBUG is not set
>=20
> #
> # RTC interfaces
> #
> CONFIG_RTC_INTF_SYSFS=3Dy
> CONFIG_RTC_INTF_PROC=3Dy
> CONFIG_RTC_INTF_DEV=3Dy
> # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
> # CONFIG_RTC_DRV_TEST is not set
>=20
> #
> # SPI RTC drivers
> #
>=20
> #
> # Platform RTC drivers
> #
> # CONFIG_RTC_DRV_CMOS is not set
> # CONFIG_RTC_DRV_DS1286 is not set
> # CONFIG_RTC_DRV_DS1511 is not set
> # CONFIG_RTC_DRV_DS1553 is not set
> # CONFIG_RTC_DRV_DS1742 is not set
> # CONFIG_RTC_DRV_STK17TA8 is not set
> # CONFIG_RTC_DRV_M48T86 is not set
> # CONFIG_RTC_DRV_M48T35 is not set
> # CONFIG_RTC_DRV_M48T59 is not set
> # CONFIG_RTC_DRV_MSM6242 is not set
> # CONFIG_RTC_DRV_BQ4802 is not set
> # CONFIG_RTC_DRV_RP5C01 is not set
> # CONFIG_RTC_DRV_V3020 is not set
> # CONFIG_RTC_DRV_DS2404 is not set
>=20
> #
> # on-CPU RTC drivers
> #
> # CONFIG_RTC_DRV_PL030 is not set
> CONFIG_RTC_DRV_PL031=3Dy
> # CONFIG_RTC_DRV_SNVS is not set
>=20
> #
> # HID Sensor RTC drivers
> #
> # CONFIG_DMADEVICES is not set
> # CONFIG_AUXDISPLAY is not set
> # CONFIG_UIO is not set
> # CONFIG_VIRT_DRIVERS is not set
>=20
> #
> # Virtio drivers
> #
> # CONFIG_VIRTIO_MMIO is not set
>=20
> #
> # Microsoft Hyper-V guest support
> #
> # CONFIG_STAGING is not set
> CONFIG_CLKDEV_LOOKUP=3Dy
> CONFIG_HAVE_CLK_PREPARE=3Dy
> CONFIG_COMMON_CLK=3Dy
>=20
> #
> # Common Clock Framework
> #
> # CONFIG_COMMON_CLK_DEBUG is not set
> CONFIG_COMMON_CLK_VERSATILE=3Dy
>=20
> #
> # Hardware Spinlock drivers
> #
> CONFIG_CLKSRC_OF=3Dy
> CONFIG_CLKSRC_MMIO=3Dy
> # CONFIG_MAILBOX is not set
> CONFIG_IOMMU_SUPPORT=3Dy
> CONFIG_OF_IOMMU=3Dy
>=20
> #
> # Remoteproc drivers
> #
> # CONFIG_STE_MODEM_RPROC is not set
>=20
> #
> # Rpmsg drivers
> #
> # CONFIG_PM_DEVFREQ is not set
> # CONFIG_EXTCON is not set
> # CONFIG_MEMORY is not set
> # CONFIG_IIO is not set
> # CONFIG_PWM is not set
> CONFIG_IRQCHIP=3Dy
> CONFIG_ARM_GIC=3Dy
> # CONFIG_IPACK_BUS is not set
> # CONFIG_RESET_CONTROLLER is not set
>=20
> #
> # File systems
> #
> CONFIG_DCACHE_WORD_ACCESS=3Dy
> CONFIG_EXT2_FS=3Dy
> # CONFIG_EXT2_FS_XATTR is not set
> # CONFIG_EXT2_FS_XIP is not set
> CONFIG_EXT3_FS=3Dy
> # CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
> # CONFIG_EXT3_FS_XATTR is not set
> # CONFIG_EXT4_FS is not set
> CONFIG_JBD=3Dy
> # CONFIG_JBD_DEBUG is not set
> # CONFIG_REISERFS_FS is not set
> # CONFIG_JFS_FS is not set
> # CONFIG_XFS_FS is not set
> # CONFIG_BTRFS_FS is not set
> # CONFIG_NILFS2_FS is not set
> # CONFIG_FS_POSIX_ACL is not set
> CONFIG_FILE_LOCKING=3Dy
> CONFIG_FSNOTIFY=3Dy
> CONFIG_DNOTIFY=3Dy
> CONFIG_INOTIFY_USER=3Dy
> # CONFIG_FANOTIFY is not set
> # CONFIG_QUOTA is not set
> # CONFIG_QUOTACTL is not set
> # CONFIG_AUTOFS4_FS is not set
> # CONFIG_FUSE_FS is not set
>=20
> #
> # Caches
> #
> # CONFIG_FSCACHE is not set
>=20
> #
> # CD-ROM/DVD Filesystems
> #
> # CONFIG_ISO9660_FS is not set
> # CONFIG_UDF_FS is not set
>=20
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=3Dy
> # CONFIG_MSDOS_FS is not set
> CONFIG_VFAT_FS=3Dy
> CONFIG_FAT_DEFAULT_CODEPAGE=3D437
> CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
> # CONFIG_NTFS_FS is not set
>=20
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=3Dy
> CONFIG_PROC_SYSCTL=3Dy
> CONFIG_PROC_PAGE_MONITOR=3Dy
> CONFIG_SYSFS=3Dy
> CONFIG_TMPFS=3Dy
> # CONFIG_TMPFS_POSIX_ACL is not set
> # CONFIG_TMPFS_XATTR is not set
> # CONFIG_HUGETLB_PAGE is not set
> # CONFIG_CONFIGFS_FS is not set
> CONFIG_MISC_FILESYSTEMS=3Dy
> # CONFIG_ADFS_FS is not set
> # CONFIG_AFFS_FS is not set
> # CONFIG_HFS_FS is not set
> # CONFIG_HFSPLUS_FS is not set
> # CONFIG_BEFS_FS is not set
> # CONFIG_BFS_FS is not set
> # CONFIG_EFS_FS is not set
> CONFIG_JFFS2_FS=3Dy
> CONFIG_JFFS2_FS_DEBUG=3D0
> CONFIG_JFFS2_FS_WRITEBUFFER=3Dy
> # CONFIG_JFFS2_FS_WBUF_VERIFY is not set
> # CONFIG_JFFS2_SUMMARY is not set
> # CONFIG_JFFS2_FS_XATTR is not set
> # CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
> CONFIG_JFFS2_ZLIB=3Dy
> # CONFIG_JFFS2_LZO is not set
> CONFIG_JFFS2_RTIME=3Dy
> # CONFIG_JFFS2_RUBIN is not set
> # CONFIG_LOGFS is not set
> CONFIG_CRAMFS=3Dy
> # CONFIG_SQUASHFS is not set
> # CONFIG_VXFS_FS is not set
> # CONFIG_MINIX_FS is not set
> # CONFIG_OMFS_FS is not set
> # CONFIG_HPFS_FS is not set
> # CONFIG_QNX4FS_FS is not set
> # CONFIG_QNX6FS_FS is not set
> # CONFIG_ROMFS_FS is not set
> # CONFIG_PSTORE is not set
> # CONFIG_SYSV_FS is not set
> # CONFIG_UFS_FS is not set
> # CONFIG_F2FS_FS is not set
> CONFIG_NETWORK_FILESYSTEMS=3Dy
> CONFIG_NFS_FS=3Dy
> CONFIG_NFS_V2=3Dy
> CONFIG_NFS_V3=3Dy
> # CONFIG_NFS_V3_ACL is not set
> # CONFIG_NFS_V4 is not set
> # CONFIG_NFS_SWAP is not set
> CONFIG_ROOT_NFS=3Dy
> # CONFIG_NFSD is not set
> CONFIG_LOCKD=3Dy
> CONFIG_LOCKD_V4=3Dy
> CONFIG_NFS_COMMON=3Dy
> CONFIG_SUNRPC=3Dy
> # CONFIG_SUNRPC_DEBUG is not set
> # CONFIG_CEPH_FS is not set
> # CONFIG_CIFS is not set
> # CONFIG_NCP_FS is not set
> # CONFIG_CODA_FS is not set
> # CONFIG_AFS_FS is not set
> CONFIG_NLS=3Dy
> CONFIG_NLS_DEFAULT=3D"iso8859-1"
> CONFIG_NLS_CODEPAGE_437=3Dy
> # CONFIG_NLS_CODEPAGE_737 is not set
> # CONFIG_NLS_CODEPAGE_775 is not set
> # CONFIG_NLS_CODEPAGE_850 is not set
> # CONFIG_NLS_CODEPAGE_852 is not set
> # CONFIG_NLS_CODEPAGE_855 is not set
> # CONFIG_NLS_CODEPAGE_857 is not set
> # CONFIG_NLS_CODEPAGE_860 is not set
> # CONFIG_NLS_CODEPAGE_861 is not set
> # CONFIG_NLS_CODEPAGE_862 is not set
> # CONFIG_NLS_CODEPAGE_863 is not set
> # CONFIG_NLS_CODEPAGE_864 is not set
> # CONFIG_NLS_CODEPAGE_865 is not set
> # CONFIG_NLS_CODEPAGE_866 is not set
> # CONFIG_NLS_CODEPAGE_869 is not set
> # CONFIG_NLS_CODEPAGE_936 is not set
> # CONFIG_NLS_CODEPAGE_950 is not set
> # CONFIG_NLS_CODEPAGE_932 is not set
> # CONFIG_NLS_CODEPAGE_949 is not set
> # CONFIG_NLS_CODEPAGE_874 is not set
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> # CONFIG_NLS_CODEPAGE_1251 is not set
> # CONFIG_NLS_ASCII is not set
> CONFIG_NLS_ISO8859_1=3Dy
> # CONFIG_NLS_ISO8859_2 is not set
> # CONFIG_NLS_ISO8859_3 is not set
> # CONFIG_NLS_ISO8859_4 is not set
> # CONFIG_NLS_ISO8859_5 is not set
> # CONFIG_NLS_ISO8859_6 is not set
> # CONFIG_NLS_ISO8859_7 is not set
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> # CONFIG_NLS_ISO8859_14 is not set
> # CONFIG_NLS_ISO8859_15 is not set
> # CONFIG_NLS_KOI8_R is not set
> # CONFIG_NLS_KOI8_U is not set
> # CONFIG_NLS_MAC_ROMAN is not set
> # CONFIG_NLS_MAC_CELTIC is not set
> # CONFIG_NLS_MAC_CENTEURO is not set
> # CONFIG_NLS_MAC_CROATIAN is not set
> # CONFIG_NLS_MAC_CYRILLIC is not set
> # CONFIG_NLS_MAC_GAELIC is not set
> # CONFIG_NLS_MAC_GREEK is not set
> # CONFIG_NLS_MAC_ICELAND is not set
> # CONFIG_NLS_MAC_INUIT is not set
> # CONFIG_NLS_MAC_ROMANIAN is not set
> # CONFIG_NLS_MAC_TURKISH is not set
> # CONFIG_NLS_UTF8 is not set
>=20
> #
> # Kernel hacking
> #
> # CONFIG_PRINTK_TIME is not set
> CONFIG_DEFAULT_MESSAGE_LOGLEVEL=3D4
> CONFIG_ENABLE_WARN_DEPRECATED=3Dy
> CONFIG_ENABLE_MUST_CHECK=3Dy
> CONFIG_FRAME_WARN=3D1024
> CONFIG_MAGIC_SYSRQ=3Dy
> # CONFIG_STRIP_ASM_SYMS is not set
> # CONFIG_READABLE_ASM is not set
> # CONFIG_UNUSED_SYMBOLS is not set
> CONFIG_DEBUG_FS=3Dy
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_SECTION_MISMATCH is not set
> CONFIG_DEBUG_KERNEL=3Dy
> # CONFIG_DEBUG_SHIRQ is not set
> # CONFIG_LOCKUP_DETECTOR is not set
> # CONFIG_PANIC_ON_OOPS is not set
> CONFIG_PANIC_ON_OOPS_VALUE=3D0
> CONFIG_DETECT_HUNG_TASK=3Dy
> CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=3D120
> # CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
> CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=3D0
> # CONFIG_SCHED_DEBUG is not set
> # CONFIG_SCHEDSTATS is not set
> # CONFIG_TIMER_STATS is not set
> # CONFIG_DEBUG_OBJECTS is not set
> # CONFIG_SLUB_DEBUG_ON is not set
> # CONFIG_SLUB_STATS is not set
> CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy
> # CONFIG_DEBUG_KMEMLEAK is not set
> # CONFIG_DEBUG_RT_MUTEXES is not set
> # CONFIG_RT_MUTEX_TESTER is not set
> # CONFIG_DEBUG_SPINLOCK is not set
> # CONFIG_DEBUG_MUTEXES is not set
> # CONFIG_DEBUG_LOCK_ALLOC is not set
> # CONFIG_PROVE_LOCKING is not set
> # CONFIG_LOCK_STAT is not set
> # CONFIG_DEBUG_ATOMIC_SLEEP is not set
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> # CONFIG_DEBUG_STACK_USAGE is not set
> # CONFIG_DEBUG_KOBJECT is not set
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> CONFIG_DEBUG_INFO=3Dy
> # CONFIG_DEBUG_INFO_REDUCED is not set
> # CONFIG_DEBUG_VM is not set
> # CONFIG_DEBUG_WRITECOUNT is not set
> CONFIG_DEBUG_MEMORY_INIT=3Dy
> # CONFIG_DEBUG_LIST is not set
> # CONFIG_TEST_LIST_SORT is not set
> # CONFIG_DEBUG_SG is not set
> # CONFIG_DEBUG_NOTIFIERS is not set
> # CONFIG_DEBUG_CREDENTIALS is not set
> # CONFIG_BOOT_PRINTK_DELAY is not set
>=20
> #
> # RCU Debugging
> #
> # CONFIG_SPARSE_RCU_POINTER is not set
> # CONFIG_RCU_TORTURE_TEST is not set
> CONFIG_RCU_CPU_STALL_TIMEOUT=3D21
> # CONFIG_RCU_CPU_STALL_INFO is not set
> # CONFIG_RCU_TRACE is not set
> # CONFIG_BACKTRACE_SELF_TEST is not set
> # CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
> # CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
> # CONFIG_DEBUG_PER_CPU_MAPS is not set
> # CONFIG_LKDTM is not set
> # CONFIG_NOTIFIER_ERROR_INJECTION is not set
> # CONFIG_FAULT_INJECTION is not set
> # CONFIG_DEBUG_PAGEALLOC is not set
> CONFIG_HAVE_FUNCTION_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
> CONFIG_HAVE_C_RECORDMCOUNT=3Dy
> CONFIG_TRACE_CLOCK=3Dy
> CONFIG_RING_BUFFER=3Dy
> CONFIG_RING_BUFFER_ALLOW_SWAP=3Dy
> CONFIG_TRACING_SUPPORT=3Dy
> CONFIG_FTRACE=3Dy
> # CONFIG_FUNCTION_TRACER is not set
> # CONFIG_IRQSOFF_TRACER is not set
> # CONFIG_SCHED_TRACER is not set
> # CONFIG_ENABLE_DEFAULT_TRACERS is not set
> # CONFIG_FTRACE_SYSCALLS is not set
> # CONFIG_TRACER_SNAPSHOT is not set
> CONFIG_BRANCH_PROFILE_NONE=3Dy
> # CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
> # CONFIG_PROFILE_ALL_BRANCHES is not set
> # CONFIG_STACK_TRACER is not set
> # CONFIG_BLK_DEV_IO_TRACE is not set
> # CONFIG_PROBE_EVENTS is not set
> # CONFIG_RING_BUFFER_BENCHMARK is not set
> # CONFIG_RING_BUFFER_STARTUP_TEST is not set
> # CONFIG_RBTREE_TEST is not set
> # CONFIG_INTERVAL_TREE_TEST is not set
> # CONFIG_DYNAMIC_DEBUG is not set
> # CONFIG_DMA_API_DEBUG is not set
> # CONFIG_ATOMIC64_SELFTEST is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=3Dy
> # CONFIG_KGDB is not set
> # CONFIG_TEST_STRING_HELPERS is not set
> # CONFIG_TEST_KSTRTOX is not set
> # CONFIG_STRICT_DEVMEM is not set
> CONFIG_ARM_UNWIND=3Dy
> CONFIG_DEBUG_USER=3Dy
> CONFIG_DEBUG_LL=3Dy
> CONFIG_DEBUG_VEXPRESS_UART0_DETECT=3Dy
> # CONFIG_DEBUG_VEXPRESS_UART0_CA9 is not set
> # CONFIG_DEBUG_VEXPRESS_UART0_RS1 is not set
> # CONFIG_DEBUG_ICEDCC is not set
> # CONFIG_DEBUG_SEMIHOSTING is not set
> CONFIG_DEBUG_LL_INCLUDE=3D"debug/vexpress.S"
> CONFIG_DEBUG_UNCOMPRESS=3Dy
> CONFIG_UNCOMPRESS_INCLUDE=3D"debug/uncompress.h"
> CONFIG_EARLY_PRINTK=3Dy
> # CONFIG_OC_ETM is not set
> # CONFIG_PID_IN_CONTEXTIDR is not set
>=20
> #
> # Security options
> #
> # CONFIG_KEYS is not set
> # CONFIG_SECURITY_DMESG_RESTRICT is not set
> # CONFIG_SECURITY is not set
> # CONFIG_SECURITYFS is not set
> CONFIG_DEFAULT_SECURITY_DAC=3Dy
> CONFIG_DEFAULT_SECURITY=3D""
> CONFIG_CRYPTO=3Dy
>=20
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_ALGAPI=3Dy
> CONFIG_CRYPTO_ALGAPI2=3Dy
> # CONFIG_CRYPTO_MANAGER is not set
> # CONFIG_CRYPTO_MANAGER2 is not set
> # CONFIG_CRYPTO_USER is not set
> # CONFIG_CRYPTO_GF128MUL is not set
> # CONFIG_CRYPTO_NULL is not set
> # CONFIG_CRYPTO_PCRYPT is not set
> # CONFIG_CRYPTO_CRYPTD is not set
> # CONFIG_CRYPTO_AUTHENC is not set
> # CONFIG_CRYPTO_TEST is not set
>=20
> #
> # Authenticated Encryption with Associated Data
> #
> # CONFIG_CRYPTO_CCM is not set
> # CONFIG_CRYPTO_GCM is not set
> # CONFIG_CRYPTO_SEQIV is not set
>=20
> #
> # Block modes
> #
> # CONFIG_CRYPTO_CBC is not set
> # CONFIG_CRYPTO_CTR is not set
> # CONFIG_CRYPTO_CTS is not set
> # CONFIG_CRYPTO_ECB is not set
> # CONFIG_CRYPTO_LRW is not set
> # CONFIG_CRYPTO_PCBC is not set
> # CONFIG_CRYPTO_XTS is not set
>=20
> #
> # Hash modes
> #
> # CONFIG_CRYPTO_CMAC is not set
> # CONFIG_CRYPTO_HMAC is not set
> # CONFIG_CRYPTO_XCBC is not set
> # CONFIG_CRYPTO_VMAC is not set
>=20
> #
> # Digest
> #
> # CONFIG_CRYPTO_CRC32C is not set
> # CONFIG_CRYPTO_CRC32 is not set
> # CONFIG_CRYPTO_GHASH is not set
> # CONFIG_CRYPTO_MD4 is not set
> # CONFIG_CRYPTO_MD5 is not set
> # CONFIG_CRYPTO_MICHAEL_MIC is not set
> # CONFIG_CRYPTO_RMD128 is not set
> # CONFIG_CRYPTO_RMD160 is not set
> # CONFIG_CRYPTO_RMD256 is not set
> # CONFIG_CRYPTO_RMD320 is not set
> # CONFIG_CRYPTO_SHA1 is not set
> # CONFIG_CRYPTO_SHA1_ARM is not set
> # CONFIG_CRYPTO_SHA256 is not set
> # CONFIG_CRYPTO_SHA512 is not set
> # CONFIG_CRYPTO_TGR192 is not set
> # CONFIG_CRYPTO_WP512 is not set
>=20
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=3Dy
> # CONFIG_CRYPTO_AES_ARM is not set
> # CONFIG_CRYPTO_ANUBIS is not set
> # CONFIG_CRYPTO_ARC4 is not set
> # CONFIG_CRYPTO_BLOWFISH is not set
> # CONFIG_CRYPTO_CAMELLIA is not set
> # CONFIG_CRYPTO_CAST5 is not set
> # CONFIG_CRYPTO_CAST6 is not set
> # CONFIG_CRYPTO_DES is not set
> # CONFIG_CRYPTO_FCRYPT is not set
> # CONFIG_CRYPTO_KHAZAD is not set
> # CONFIG_CRYPTO_SALSA20 is not set
> # CONFIG_CRYPTO_SEED is not set
> # CONFIG_CRYPTO_SERPENT is not set
> # CONFIG_CRYPTO_TEA is not set
> # CONFIG_CRYPTO_TWOFISH is not set
>=20
> #
> # Compression
> #
> # CONFIG_CRYPTO_DEFLATE is not set
> # CONFIG_CRYPTO_ZLIB is not set
> # CONFIG_CRYPTO_LZO is not set
>=20
> #
> # Random Number Generation
> #
> # CONFIG_CRYPTO_ANSI_CPRNG is not set
> # CONFIG_CRYPTO_USER_API_HASH is not set
> # CONFIG_CRYPTO_USER_API_SKCIPHER is not set
> # CONFIG_CRYPTO_HW is not set
> # CONFIG_BINARY_PRINTF is not set
>=20
> #
> # Library routines
> #
> CONFIG_BITREVERSE=3Dy
> CONFIG_GENERIC_STRNCPY_FROM_USER=3Dy
> CONFIG_GENERIC_STRNLEN_USER=3Dy
> CONFIG_GENERIC_PCI_IOMAP=3Dy
> CONFIG_GENERIC_IO=3Dy
> # CONFIG_CRC_CCITT is not set
> # CONFIG_CRC16 is not set
> # CONFIG_CRC_T10DIF is not set
> # CONFIG_CRC_ITU_T is not set
> CONFIG_CRC32=3Dy
> # CONFIG_CRC32_SELFTEST is not set
> CONFIG_CRC32_SLICEBY8=3Dy
> # CONFIG_CRC32_SLICEBY4 is not set
> # CONFIG_CRC32_SARWATE is not set
> # CONFIG_CRC32_BIT is not set
> # CONFIG_CRC7 is not set
> # CONFIG_LIBCRC32C is not set
> # CONFIG_CRC8 is not set
> CONFIG_ZLIB_INFLATE=3Dy
> CONFIG_ZLIB_DEFLATE=3Dy
> CONFIG_LZO_DECOMPRESS=3Dy
> CONFIG_XZ_DEC=3Dy
> # CONFIG_XZ_DEC_X86 is not set
> # CONFIG_XZ_DEC_POWERPC is not set
> # CONFIG_XZ_DEC_IA64 is not set
> CONFIG_XZ_DEC_ARM=3Dy
> CONFIG_XZ_DEC_ARMTHUMB=3Dy
> # CONFIG_XZ_DEC_SPARC is not set
> CONFIG_XZ_DEC_BCJ=3Dy
> # CONFIG_XZ_DEC_TEST is not set
> CONFIG_DECOMPRESS_GZIP=3Dy
> CONFIG_DECOMPRESS_BZIP2=3Dy
> CONFIG_DECOMPRESS_LZMA=3Dy
> CONFIG_DECOMPRESS_XZ=3Dy
> CONFIG_DECOMPRESS_LZO=3Dy
> CONFIG_HAS_IOMEM=3Dy
> CONFIG_HAS_DMA=3Dy
> CONFIG_CPU_RMAP=3Dy
> CONFIG_DQL=3Dy
> CONFIG_NLATTR=3Dy
> CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=3Dy
> # CONFIG_AVERAGE is not set
> # CONFIG_CORDIC is not set
> # CONFIG_DDR is not set
> # CONFIG_VIRTUALIZATION is not set

> Booting Linux on physical CPU 0x0
> Initializing cgroup subsys cpuset
> Linux version 3.10.0-rc4+ (iamroot@iamroot-OptiPlex-780) (gcc version=
 4.5.1 (Sourcery G++ Lite 2010.09-50) ) #7 SMP Fri Jun 7 16:27:51 CST 2=
013
> CPU: ARMv7 Processor [410fc090] revision 0 (ARMv7), cr=3D10c53c7d
> CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction ca=
che
> Machine: ARM-Versatile Express
> Memory policy: ECC disabled, Data cache writealloc
> On node 0 totalpages: 32768
> free_area_init_node: node 0, pgdat 8085be80, node_mem_map 8087c000
>   Normal zone: 256 pages used for memmap
>   Normal zone: 0 pages reserved
>   Normal zone: 32768 pages, LIFO batch:7
> sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every 178956ms
> PERCPU: Embedded 7 pages/cpu @8097f000 s7040 r8192 d13440 u32768
> pcpu-alloc: s7040 r8192 d13440 u32768 alloc=3D8*4096
> pcpu-alloc: [0] 0=20
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: =
32512
> Kernel command line: console=3DttyAMA0 rootwait devtmpfs.mount=3D0 ra=
id=3Dnotautodetect ip=3D192.168.1.::192.168.1.1:255.255.255.0 root=3D/d=
ev/md0 rdinit=3D/linuxrc mem=3D128M rw
> PID hash table entries: 512 (order: -1, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 128MB =3D 128MB total
> Memory: 121212k/121212k available, 9860k reserved, 0K highmem
> Virtual kernel memory layout:
>     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
>     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
>     vmalloc : 0x88800000 - 0xff000000   (1896 MB)
>     lowmem  : 0x80000000 - 0x88000000   ( 128 MB)
>     modules : 0x7f000000 - 0x80000000   (  16 MB)
>       .text : 0x80008000 - 0x80431348   (4261 kB)
>       .init : 0x80432000 - 0x80837b80   (4119 kB)
>       .data : 0x80838000 - 0x8085c7e0   ( 146 kB)
>        .bss : 0x8085c7e0 - 0x8087be5c   ( 126 kB)
> SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, Nodes=3D1
> Hierarchical RCU implementation.
> 	RCU restricting CPUs from NR_CPUS=3D4 to nr_cpu_ids=3D1.
> NR_IRQS:16 nr_irqs:16 16
> smp_twd: clock not found -2
> Console: colour dummy device 80x30
> Calibrating delay loop... 293.27 BogoMIPS (lpj=3D1466368)
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 512
> CPU: Testing write buffer coherency: ok
> CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> Setting up static identity map for 0x8033b2e8 - 0x8033b340
> Brought up 1 CPUs
> SMP: Total of 1 processors activated (293.27 BogoMIPS).
> CPU: All CPU(s) started in SVC mode.
> devtmpfs: initialized
> NET: Registered protocol family 16
> DMA: preallocated 256 KiB pool for atomic coherent allocations
> L310 cache controller enabled
> l2x0: 8 ways, CACHE_ID 0x410000c8, AUX_CTRL 0x02420000, Cache size: 1=
31072 B
> vexpress-sysreg vexpress-sysreg: error -22
> hw-breakpoint: debug architecture 0x0 unsupported.
> Serial: AMBA PL011 UART driver
> mb:uart0: ttyAMA0 at MMIO 0x10009000 (irq =3D 37) is a PL011 rev1
> console [ttyAMA0] enabled
> mb:uart1: ttyAMA1 at MMIO 0x1000a000 (irq =3D 38) is a PL011 rev1
> mb:uart2: ttyAMA2 at MMIO 0x1000b000 (irq =3D 39) is a PL011 rev1
> mb:uart3: ttyAMA3 at MMIO 0x1000c000 (irq =3D 40) is a PL011 rev1
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> libata version 3.00 loaded.
> Switching to clocksource v2m-timer1
> NET: Registered protocol family 2
> TCP established hash table entries: 1024 (order: 1, 8192 bytes)
> TCP bind hash table entries: 1024 (order: 1, 8192 bytes)
> TCP: Hash tables configured (established 1024 bind 1024)
> TCP: reno registered
> UDP hash table entries: 256 (order: 1, 8192 bytes)
> UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
> NET: Registered protocol family 1
> RPC: Registered named UNIX socket transport module.
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> CPU PMU: probing PMU on CPU 0
> hw perfevents: enabled with ARMv7 Cortex-A9 PMU driver, 1 counters av=
ailable
> jffs2: version 2.2. (NAND) =E6=BC=8F 2001-2006 Red Hat, Inc.
> msgmni has been set to 236
> io scheduler noop registered (default)
> brd: module loaded
> smsc911x: Driver version 2008-10-21
> smsc911x smsc911x (unregistered net_device): couldn't get clock -2
> libphy: smsc911x-mdio: probed
> smsc911x smsc911x eth0: attached PHY driver [Generic PHY] (mii_bus:ph=
y_addr=3Dsmsc911x-fffffff:01, irq=3D-1)
> smsc911x smsc911x eth0: MAC Address: 52:54:00:12:34:56
> mousedev: PS/2 mouse device common for all mice
> rtc-pl031 mb:rtc: rtc core: registered pl031 as rtc0
> oprofile: using arm/armv7-ca9
> TCP: cubic registered
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev=
 0
> input: AT Raw Set 2 keyboard as /devices/mb:kmi0/serio0/input/input0
> rtc-pl031 mb:rtc: setting system clock to 2013-06-07 08:28:12 UTC (13=
70593692)
> smsc911x smsc911x eth0: SMSC911x/921x identified at 0x888c0000, IRQ: =
47
> IP-Config: Complete:
>      device=3Deth0, hwaddr=3D52:54:00:12:34:56, ipaddr=3D192.168.1.0,=
 mask=3D255.255.255.0, gw=3D192.168.1.1
>      host=3D192.168.1.0, domain=3D, nis-domain=3D(none)
>      bootserver=3D255.255.255.255, rootserver=3D255.255.255.255, root=
path=3D
> Freeing unused kernel memory: 4116K (80432000 - 80837000)
> input: ImExPS/2 Generic Explorer Mouse as /devices/mb:kmi1/serio1/inp=
ut/input1
>=20
>=20
> / # cat /proc/net/xfrm_stat=20
> XfrmInError             	0
> XfrmInBufferError       	0
> XfrmInHdrError          	0
> XfrmInNoStates          	0
> XfrmInStateProtoError   	0
> XfrmInStateModeError    	0
> XfrmInStateSeqError     	0
> XfrmInStateExpired      	0
> XfrmInStateMismatch     	0
> XfrmInStateInvalid      	0
> XfrmInTmplMismatch      	0
> XfrmInNoPols            	0
> XfrmInPolBlock          	0
> XfrmInPolError          	0
> XfrmOutError            	0
> XfrmOutBundleGenError   	0
> XfrmOutBundleCheckError 	0
> XfrmOutNoStates         	0
> XfrmOutStateProtoError  	0
> XfrmOutStateModeError   	0
> XfrmOutStateSeqError    	0
> XfrmOutStateExpired     	0
> XfrmOutPolBlock         	0
> XfrmOutPolDead          	0
> XfrmOutPolError         	0
> XfrmFwdHdrError         	0
> XfrmOutStateInvalid     	0
> XfrmAcquireError        	0
>=20
>=20
>=20
>=20
