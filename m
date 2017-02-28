From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [bpf] 9d876e79df:  BUG: unable to handle kernel paging request
 at 653a8346
Date: Tue, 28 Feb 2017 19:09:33 +0800
Message-ID: <20170228110933.snljyosmcjsxtbyf@wfg-t540p.sh.intel.com>
References: <58B44505.3020602@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="hosktcrak7d5ovix"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        LKP <lkp@01.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <58B44505.3020602@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hosktcrak7d5ovix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[remove unrelated mailing lists]

On Mon, Feb 27, 2017 at 04:25:57PM +0100, Daniel Borkmann wrote:
>On 02/27/2017 03:14 AM, kernel test robot wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>
>I'll take a look, thanks for the report!

You are welcome! btw here is another bisect result showing a different
call trace. The attached reproduce-* script may help reproduce the bug.

d2852a2240  arch: add ARCH_HAS_SET_MEMORY config
9d876e79df  bpf: fix unlocking of jited image when module ronx not set
+--------------------------------------------------------+------------+------------+
|                                                        | d2852a2240 | 9d876e79df |
+--------------------------------------------------------+------------+------------+
| boot_successes                                         | 2756       | 207        |
| boot_failures                                          | 0          | 238        |
| BUG:unable_to_handle_kernel                            | 0          | 236        |
| Oops:#[##]                                             | 0          | 236        |
| EIP:__release_sock                                     | 0          | 13         |
| Kernel_panic-not_syncing:Fatal_exception               | 0          | 218        |
| EIP:bpf_prog_free                                      | 0          | 23         |
| EIP:filp_close                                         | 0          | 44         |
| EIP:__wake_up_common                                   | 0          | 16         |
| EIP:unix_release_sock                                  | 0          | 76         |
| EIP:__netlink_lookup                                   | 0          | 3          |
| EIP:release_sock                                       | 0          | 9          |
| Kernel_panic-not_syncing:Fatal_exception_in_interrupt  | 0          | 18         |
| EIP:netlink_update_listeners                           | 0          | 7          |
| EIP:__rcu_process_callbacks                            | 0          | 4          |
| EIP:__unix_find_socket_byname                          | 0          | 14         |
| BUG:kernel_hang_in_test_stage                          | 0          | 2          |
| EIP:__fget_light                                       | 0          | 15         |
| EIP:rht_bucket_nested                                  | 0          | 4          |
| EIP:___cache_free                                      | 0          | 2          |
| WARNING:at_arch/x86/mm/pageattr.c:#__cpa_process_fault | 0          | 1          |
| EIP:mnt_want_write_file                                | 0          | 1          |
| EIP:netlink_release                                    | 0          | 2          |
+--------------------------------------------------------+------------+------------+

[    5.875292] init: Failed to create pty - disabling logging for job
[    5.876281] init: Temporary process spawn error: No such file or directory
[    5.894107] genirq: Flags mismatch irq 4. 00000000 (serial) vs. 00000080 (goldfish_pdev_bus)
[    5.904376] random: trinity: uninitialized urandom read (4 bytes read)
[   15.457341] sock: process `trinity-main' is using obsolete setsockopt SO_BSDCOMPAT
[   15.493431] BUG: unable to handle kernel paging request at 000083aa
[   15.494924] IP: netlink_update_listeners+0x65/0xb0
[   15.496147] *pde = 00000000 
[   15.496148] 
[   15.497698] Oops: 0000 [#1]
[   15.498505] CPU: 0 PID: 377 Comm: trinity-main Not tainted 4.10.0-rc8-02017-g9d876e7 #59
[   15.500409] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[   15.502721] task: d652f840 task.stack: d4b74000
[   15.503830] EIP: netlink_update_listeners+0x65/0xb0
[   15.505017] EFLAGS: 00010002 CPU: 0
[   15.505931] EAX: 000081e6 EBX: 00000023 ECX: 00000000 EDX: 00000000
[   15.507334] ESI: 00000000 EDI: d5226118 EBP: d4b75e68 ESP: d4b75e58
[   15.508746]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   15.509996] CR0: 80050033 CR2: 000083aa CR3: 16960000 CR4: 00000610
[   15.511399] Call Trace:
[   15.512126]  netlink_bind+0x136/0x240
[   15.513068]  SYSC_bind+0x98/0xb0
[   15.513924]  ? __might_sleep+0x32/0xa0
[   15.514886]  ? __might_sleep+0x32/0xa0
[   15.515843]  ? __copy_from_user_ll+0xb/0xe0
[   15.516878]  ? _copy_from_user+0x62/0xa0
[   15.517866]  SyS_socketcall+0x49c/0x6a0
[   15.518842]  ? __sb_end_write+0x8/0x40
[   15.519795]  ? __might_sleep+0x32/0xa0
[   15.520739]  ? mutex_unlock+0x9/0x30
[   15.521664]  do_fast_syscall_32+0x9a/0x160
[   15.522674]  entry_SYSENTER_32+0x4c/0x7b
[   15.523645] EIP: 0xb77bdcc5
[   15.524415] EFLAGS: 00000286 CPU: 0
[   15.525334] EAX: ffffffda EBX: 00000002 ECX: bfc54530 EDX: b7591710
[   15.526737] ESI: 00000177 EDI: 00000010 EBP: 00000003 ESP: bfc5451c
[   15.528139]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   15.529395] Code: 8d b6 00 00 00 00 8b 47 64 85 c0 74 61 83 e8 18 74 5c 8d 34 8d 00 00 00 00 31 db eb 0e 89 f6 8d bc 27 00 00 00 00 83 e8 18 74 20 <8b> 90 c4 01 00 00 83 c2 1f c1 ea 05 39 d1 73 09 8b 90 c8 01 00
[   15.533484] EIP: netlink_update_listeners+0x65/0xb0 SS:ESP: 0068:d4b75e58
[   15.534982] CR2: 00000000000083aa
[   15.535858] ---[ end trace be2247c8320aa1f6 ]---
[   15.536976] Kernel panic - not syncing: Fatal exception

git bisect start c4f3f22eddc982d247ffe2a6690c3e4a5c46dd09 v4.10 --
git bisect good 1e74a2eb1f5cc7f2f2b5aa9c9eeecbcf352220a3  # 13:51    310+      0  Merge tag 'gcc-plugins-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
git bisect  bad 5bcbe22ca47da04cda3a858cef67f55b550c1d13  # 13:58     32-     34  Merge branch 'linus' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
git bisect  bad b4642c109f9bbf62b2ee10babf5c4221c48480aa  # 14:08      1-      2  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security
git bisect  bad e30aee9e10bb5168579e047f05c3d13d09e23356  # 14:15     12-     13  Merge tag 'char-misc-4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
git bisect  bad 38705613b74ab090eee55c327cd0cb77fb10eb26  # 14:24     94-     81  Merge tag 'powerpc-4.11-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect  bad 3051bf36c25d5153051704291782f8d44e744d36  # 14:35     63-     29  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good 889711a03e0fba427fb85317900e93c74e3be02a  # 14:50    310+      0  Merge tag 'wireless-drivers-next-for-davem-2017-02-01' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
git bisect good e3f29c4809a5f562adc345c48ed9785f2597df78  # 15:02    310+      0  Merge tag 'wireless-drivers-next-for-davem-2017-02-09' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
git bisect good 5237b9dde379f9eadd60a9b6310567ce5d307fe8  # 15:18    310+      0  Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
git bisect good 93a66e93c7d8775f33c0d65e3fdeb209c1d4a8c9  # 15:34    310+      0  GTP: Add some basic documentation about drivers/net/gtp.c
git bisect good 14861e9de2c2ffe404fb41cc34150f09a39acb44  # 15:51    310+      0  net: ethernet: aquantia: Using module_pci_driver.
git bisect good 8bcdc4f3a20be949df54b67e5ae2734daabb5792  # 16:09    300+      0  vxlan: add changelink support
git bisect good a8c249a71dca2992001ad582797c03fca0488d00  # 16:47    310+      0  net: mvpp2: remove unused register definitions
git bisect good 29869d66870a715177bfb505f66a7e0e8bcc89c3  # 17:04    306+      0  tcp: Revert "tcp: tcp_probe: use spin_lock_bh()"
git bisect  bad d54fef315399e0b16f8ae2b41167f34f8df12e88  # 17:04      0-    213  Merge branch 'bpf-unlocking-fix'
git bisect good d2852a2240509e512712e25de2d0796cda435ecb  # 17:22    306+      0  arch: add ARCH_HAS_SET_MEMORY config
git bisect  bad 9d876e79df6a2f364b9f2737eacd72ceb27da53a  # 15:28     16-     55  bpf: fix unlocking of jited image when module ronx not set
# first bad commit: [9d876e79df6a2f364b9f2737eacd72ceb27da53a] bpf: fix unlocking of jited image when module ronx not set
git bisect good d2852a2240509e512712e25de2d0796cda435ecb  # 17:39    901+      0  arch: add ARCH_HAS_SET_MEMORY config
# extra tests on HEAD of linux-review/Matthew-Wilcox/ERR_USER_PTR/20170226-195525
git bisect  bad 327d9d62aac2d74f41564e22f3ce52eb241e1dae  # 17:40      0-     51  ERR_USER_PTR
# extra tests on tree/branch linus/master
git bisect  bad 5782fd14aaecc72f27473f380ba2044c7598b14a  # 17:57     47-     30  Merge tag 'rtc-4.11' of git://git.kernel.org/pub/scm/linux/kernel/git/abelloni/linux
# extra tests on tree/branch linux-next/master
git bisect  bad 8d01c069486aca75b8f6018a759215b0ed0c91f0  # 18:18     42-     30  Add linux-next specific files for 20170228

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--hosktcrak7d5ovix
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-50:20170228051301:i386-randconfig-r0-201709:4.10.0-rc8-02017-g9d876e7:59.gz"
Content-Transfer-Encoding: base64

H4sICHZOtVgAA2RtZXNnLXF1YW50YWwtaXZiNDEtNTA6MjAxNzAyMjgwNTEzMDE6aTM4Ni1y
YW5kY29uZmlnLXIwLTIwMTcwOTo0LjEwLjAtcmM4LTAyMDE3LWc5ZDg3NmU3OjU5AOxdaXPb
yNH+7l/RSb7QiUjO4AZTTL06vSybEleUd7del4sFAgMKEQhwcejwr0/3AOAFQqQU5xtZtkEA
3c/0XH1NsyycJHwBN47SOBQQRJCKLF/gA098ENvvxHOWOG42eRBJJMIPQbTIs4nnZE4P2DNT
mCOYxcrHoYjkU6YriuFYH+I8w8fyEWfyUz5aUXqOayN/gT7J4swJJ2nwQxRMutCJ6cOFcOP5
IhFpGkQz+BJE+XOn04GRk8gHl1+u6PY6hkSEsetkQRxBJIQnPHruxZHofDiL44yIs3sBRXOd
D98AP6xTyPa9AIZHgagIoHU4vmonrtXGfnKzPbM9yzSECa2HaR6E3v8lsTP/CK2Z6y6Z9A6y
AZIbzGYatC7ENHDKx23lI3yEv+k2jPMIrsQUFAMUpacYPXx2Pr4jPnNbqGfL6PqLvAdfxMxx
X/DehKvRV/BEJtwMe7jNICyF9eBscDNuL5L4McBRgMX9Sxq4Tgi3p0OYO4veNpMkLzi/zcVc
zs3mp73xyPanvv8d8tSZhuJNYLbv1sF8AsP5Fcmj8N4E59dl898Px7e7yk3mcf89XSVOpQb2
btl84dPArcPRo3fDFWgbcP4+OE9M81kPglkUJ7SVwngWikcRkgKhvVVbilPcc5Uu+SZVCwLT
Eo1oLGv417hDXdz6139A6/JZuHkm4CKQ4/4RcC3TgqdN5jpRFGcwFRVQD6I4ao9OL8ud/Zdt
5PGQhgKUjgWkRkSU1WS9GA568Ovl8CuMMyfynMSD0Tm0Ak1jV3/AP2A0GPxxAty2jY8ncmCB
d+yO2qa9zpmiT7jJVaa0Z8Qc+sC0LuNdfKttt/TLywKHN0jjZLmJe/D5t+HujZwvUNuK7fmr
5m1taUK//6/GqSuwEjGPH9exnBVWOfe7l3nBHjppNln4EfSRW65v1CXPEydx71ePJcc2//Du
9hY76zt5mEGG/e/BUxJkoj113IedxH7wjHorcaKZSJfTvE2J32UH7Cv8vIIIcCrpziRdHrmO
e7+rmwDnku5qDa9cdzuFfHSSQA79fjlh6qQCxbXKCcSRSx/g6mp5/5pUHLxiG9TmFUB55Z36
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
dwztAAA=

--hosktcrak7d5ovix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-quantal-ivb41-50:20170228051301:i386-randconfig-r0-201709:4.10.0-rc8-02017-g9d876e7:59"

#!/bin/bash

kernel=$1
initrd=quantal-core-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 369
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" -append "${append[*]}"

--hosktcrak7d5ovix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.10.0-rc8-02017-g9d876e7"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.10.0-rc8 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_KTHREAD_PRIO=0
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
# CONFIG_MEMCG_SWAP_ENABLED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CPUSETS is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_BPF=y
CONFIG_CGROUP_DEBUG=y
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_INITRAMFS_COMPRESSION=".gz"
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_POSIX_TIMERS=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set
CONFIG_BLK_WBT=y
# CONFIG_BLK_WBT_SQ is not set
# CONFIG_BLK_WBT_MQ is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLK_MQ_PCI=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_MPPARSE=y
CONFIG_GOLDFISH=y
CONFIG_INTEL_RDT_A=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
CONFIG_M686=y
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_UP_APIC=y
# CONFIG_X86_UP_IOAPIC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_LEGACY_VM86 is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_GENERIC_DOMAINS=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_PM_GENERIC_DOMAINS_SLEEP=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
# CONFIG_SFI is not set
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_PERFORMANCE=y
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
CONFIG_PCIE_PTM=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
# CONFIG_PCI_STUB is not set
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_COMPAQ=y
# CONFIG_HOTPLUG_PCI_COMPAQ_NVRAM is not set
CONFIG_HOTPLUG_PCI_IBM=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
CONFIG_NET5501=y
CONFIG_GEOS=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_GRO_CELLS is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
CONFIG_MTD_OOPS=y
CONFIG_MTD_SWAP=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
# CONFIG_MTD_SCx200_DOCFLASH is not set
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
# CONFIG_MTD_SST25L is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_CS553X=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
# CONFIG_MTD_NAND_OXNAS is not set
# CONFIG_MTD_NAND_HISI504 is not set
CONFIG_MTD_NAND_MTK=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
# CONFIG_MTD_ONENAND_GENERIC is not set
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_MT81xx_NOR is not set
# CONFIG_MTD_SPI_NOR_USE_4K_SECTORS is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
# CONFIG_BLK_DEV_NVME_SCSI is not set
CONFIG_NVME_FABRICS=y
# CONFIG_NVME_FC is not set
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
# CONFIG_NVME_TARGET_FC is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
# CONFIG_AD525X_DPOT_SPI is not set
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
# CONFIG_CS5535_CLOCK_EVENT_SRC is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
# CONFIG_TI_DAC7512 is not set
CONFIG_VMWARE_BALLOON=y
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_MQ_DEFAULT=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_ENCLOSURE is not set
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
# CONFIG_SATA_QSTOR is not set
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
CONFIG_SATA_DWC=y
# CONFIG_SATA_DWC_OLD_DMA is not set
# CONFIG_SATA_DWC_DEBUG is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
CONFIG_SATA_SVW=y
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=y
# CONFIG_PATA_ARTOP is not set
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CS5536 is not set
CONFIG_PATA_CYPRESS=y
CONFIG_PATA_EFAR=y
CONFIG_PATA_HPT366=y
CONFIG_PATA_HPT37X=y
CONFIG_PATA_HPT3X2N=y
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
# CONFIG_PATA_NETCELL is not set
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
CONFIG_PATA_OPTIDMA=y
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
CONFIG_PATA_RADISYS=y
CONFIG_PATA_RDC=y
# CONFIG_PATA_SC1200 is not set
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
CONFIG_PATA_WINBOND=y

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
CONFIG_PATA_LEGACY=y
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
# CONFIG_TCM_USER2 is not set
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=y
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_SBP2=y
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=y
# CONFIG_JOYSTICK_ADI is not set
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_232=y
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
CONFIG_JOYSTICK_AS5011=y
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
# CONFIG_RMI4_F30 is not set
# CONFIG_RMI4_F34 is not set
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
CONFIG_ISI=y
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_GOLDFISH_TTY=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_IFX6X60=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_MEN_Z135=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_SONYPI=y

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_SCR24X=y
CONFIG_MWAVE=y
# CONFIG_SCx200_GPIO is not set
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PCI=y
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_KEMPLD is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_SCx200_ACB=y
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_DESIGNWARE is not set
CONFIG_SPI_GPIO=y
# CONFIG_SPI_LM70_LLP is not set
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_AXP209 is not set
# CONFIG_GPIO_DWAPB is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MENZ127=y
# CONFIG_GPIO_MOCKUP is not set
CONFIG_GPIO_VX855=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_CRYSTAL_COVE=y
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_JANZ_TTL=y
# CONFIG_GPIO_KEMPLD is not set
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_TIMBERDALE=y
CONFIG_GPIO_TPS65218=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_TWL6040 is not set
# CONFIG_GPIO_WHISKEY_COVE is not set
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set

#
# SPI or I2C GPIO expanders
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8998=y
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
CONFIG_AXP20X_POWER=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7310 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ARM_SCPI=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_DA9052_ADC is not set
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_MC13783_ADC=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_FTSTEUTATES=y
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_I5500 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_TC654 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_ADS7871 is not set
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=y
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
# CONFIG_SENSORS_WM8350 is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_BXT_PMIC_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
# CONFIG_MENF21BMC_WATCHDOG is not set
# CONFIG_WDAT_WDT is not set
CONFIG_WM831X_WATCHDOG=y
CONFIG_WM8350_WATCHDOG=y
# CONFIG_XILINX_WATCHDOG is not set
CONFIG_ZIIRAVE_WATCHDOG=y
# CONFIG_CADENCE_WATCHDOG is not set
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
CONFIG_GEODE_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
CONFIG_SC1200_WDT=y
# CONFIG_SCx200_WDT is not set
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_INTEL_MEI_WDT is not set
# CONFIG_NI903X_WDT is not set
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RT5033=y
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TI_LP873X is not set
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AB3100=y
# CONFIG_REGULATOR_AS3711 is not set
# CONFIG_REGULATOR_AXP20X is not set
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_LTC3676=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
# CONFIG_REGULATOR_PV88080 is not set
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# Frame buffer Devices
#
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
# CONFIG_VGASTATE is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
CONFIG_HID_ASUS=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=y
# CONFIG_HID_CMEDIA is not set
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
CONFIG_HID_GFRM=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MAYFLASH=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_UDRAW_PS3 is not set
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set
CONFIG_HID_ALPS=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_WM8350=y
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_MENF21BMC=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=y
CONFIG_PCH_DMA=y
CONFIG_TIMB_DMA=y
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
CONFIG_AUXDISPLAY=y
CONFIG_KS0108=y
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_IMG_ASCII_LCD=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_PRUSS=y
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_DELL_SMBIOS is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
CONFIG_IBM_RTL=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_SURFACE_3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_CPLD_PLATFORM=y
CONFIG_GOLDFISH_BUS=y
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
# CONFIG_CHROMEOS_PSTORE is not set
CONFIG_CROS_EC_CHARDEV=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_INTEL_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX77843=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_QCOM_SPMI_MISC=y
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=y
CONFIG_NTB_PINGPONG=y
# CONFIG_NTB_TOOL is not set
CONFIG_NTB_PERF=y
CONFIG_NTB_TRANSPORT=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CRC=y
CONFIG_PWM_CROS_EC=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_ATH79 is not set
# CONFIG_RESET_BERLIN is not set
# CONFIG_RESET_LPC18XX is not set
# CONFIG_RESET_MESON is not set
# CONFIG_RESET_PISTACHIO is not set
# CONFIG_RESET_SOCFPGA is not set
# CONFIG_RESET_STM32 is not set
# CONFIG_RESET_SUNXI is not set
CONFIG_TI_SYSCON_RESET=y
# CONFIG_RESET_ZYNQ is not set
# CONFIG_RESET_TEGRA_BPMP is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_IPC_32BIT=y
CONFIG_DEV_DAX=y
CONFIG_NR_DEV_DAX=32768
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
CONFIG_STM_SOURCE_HEARTBEAT=y
CONFIG_STM_SOURCE_FTRACE=y
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
CONFIG_ARM_SCPI_PROTOCOL=y
CONFIG_ARM_SCPI_POWER_DOMAIN=y
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=y
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT2 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_F2FS_FS_SECURITY=y
# CONFIG_F2FS_CHECK_FS is not set
CONFIG_F2FS_FS_ENCRYPTION=y
CONFIG_F2FS_IO_TRACE=y
CONFIG_F2FS_FAULT_INJECTION=y
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QFMT_V1=y
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
CONFIG_PAGE_POISONING_ZERO=y
# CONFIG_DEBUG_PAGE_REF is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_PERF_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
# CONFIG_SCHED_TRACER is not set
# CONFIG_HWLAT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
# CONFIG_FUNCTION_PROFILER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_ENUM_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
# CONFIG_TEST_UUID is not set
CONFIG_TEST_RHASHTABLE=y
# CONFIG_TEST_HASH is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
# CONFIG_UBSAN_NULL is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP_CORE is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_PATH is not set
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
CONFIG_SECURITY_LOADPIN_ENABLED=y
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
# CONFIG_INTEGRITY_SIGNATURE is not set
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_TEMPLATE=y
# CONFIG_IMA_NG_TEMPLATE is not set
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
CONFIG_IMA_READ_POLICY=y
# CONFIG_IMA_APPRAISE is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_MCRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_842=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_GEODE is not set
CONFIG_CRYPTO_DEV_HIFN_795X=y
CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
CONFIG_CRYPTO_DEV_CCP=y
# CONFIG_CRYPTO_DEV_CCP_DD is not set
CONFIG_CRYPTO_DEV_QAT=y
CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
CONFIG_CRYPTO_DEV_QAT_C62X=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
CONFIG_CRYPTO_DEV_QAT_C62XVF=y
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
CONFIG_LGUEST=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y
# CONFIG_PARMAN is not set

--hosktcrak7d5ovix--
