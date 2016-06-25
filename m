From: kernel test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [perf core] c5dfd78eb7:  BUG: unable to handle kernel NULL
 pointer dereference at 00000c40
Date: Sat, 25 Jun 2016 08:30:24 +0800
Message-ID: <576dd0a0.ZzXQ4ceFqSSvr1VT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_576dd0a0.3zE0c8775Ufwn12T/Gq4Xk3UYB0YrfXPIvkvYibRp0tANY2S"
Cc: LKP <lkp-JC7UmRfGjtg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--=_576dd0a0.3zE0c8775Ufwn12T/Gq4Xk3UYB0YrfXPIvkvYibRp0tANY2S
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit c5dfd78eb79851e278b7973031b9ca363da87a7e
Author:     Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
AuthorDate: Thu Apr 21 12:28:50 2016 -0300
Commit:     Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CommitDate: Wed Apr 27 10:20:39 2016 -0300

    perf core: Allow setting up max frame stack depth via sysctl
    
    The default remains 127, which is good for most cases, and not even hit
    most of the time, but then for some cases, as reported by Brendan, 1024+
    deep frames are appearing on the radar for things like groovy, ruby.
    
    And in some workloads putting a _lower_ cap on this may make sense. One
    that is per event still needs to be put in place tho.
    
    The new file is:
    
      # cat /proc/sys/kernel/perf_event_max_stack
      127
    
    Chaging it:
    
      # echo 256 > /proc/sys/kernel/perf_event_max_stack
      # cat /proc/sys/kernel/perf_event_max_stack
      256
    
    But as soon as there is some event using callchains we get:
    
      # echo 512 > /proc/sys/kernel/perf_event_max_stack
      -bash: echo: write error: Device or resource busy
      #
    
    Because we only allocate the callchain percpu data structures when there
    is a user, which allows for changing the max easily, its just a matter
    of having no callchain users at that point.
    
    Reported-and-Tested-by: Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Reviewed-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Acked-by: David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
    Cc: Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
    Cc: He Kuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
    Cc: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Cc: Masami Hiramatsu <mhiramat-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Milian Wolff <milian.wolff-9CuX5V8lPks@public.gmane.org>
    Cc: Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
    Cc: Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
    Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
    Cc: Vince Weaver <vincent.weaver-e7X0jjDqjFGHXe+LvDLADg@public.gmane.org>
    Cc: Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
    Cc: Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
    Link: http://lkml.kernel.org/r/20160426002928.GB16708-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
    Signed-off-by: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

+-----------------------------------------------------------+------------+------------+-----------------+
|                                                           | c2a218c63b | c5dfd78eb7 | v4.7-rc4_062414 |
+-----------------------------------------------------------+------------+------------+-----------------+
| boot_successes                                            | 910        | 305        | 67              |
| boot_failures                                             | 0          | 5          | 53              |
| Oops                                                      | 0          | 5          | 2               |
| EIP_is_at_perf_prepare_sample                             | 0          | 5          |                 |
| Kernel_panic-not_syncing:Fatal_exception                  | 0          | 5          | 2               |
| BUG:unable_to_handle_kernel                               | 0          | 4          | 1               |
| backtrace:iterate_dir                                     | 0          | 1          |                 |
| backtrace:SyS_getdents64                                  | 0          | 1          |                 |
| EIP_is_at_get_perf_callchain                              | 0          | 0          | 2               |
| BUG:kernel_test_crashed                                   | 0          | 0          | 7               |
| IP-Config:Auto-configuration_of_network_failed            | 0          | 0          | 2               |
| WARNING:at_arch/x86/mm/extable.c:#ex_handler_rdmsr_unsafe | 0          | 0          | 42              |
| backtrace:native_calibrate_cpu                            | 0          | 0          | 42              |
| backtrace:tsc_init                                        | 0          | 0          | 42              |
| backtrace:x86_late_time_init                              | 0          | 0          | 42              |
+-----------------------------------------------------------+------------+------------+-----------------+

[main] 375 sockets created based on info from socket cachefile.
[main] Generating file descriptors
[main] Added 889 filenames from /dev
[   56.590952] BUG: unable to handle kernel NULL pointer dereference at 00000c40
[   56.598975] IP: [<790e4f29>] perf_prepare_sample+0x229/0x330
[   56.599783] *pde = 00000000 
[   56.601158] Oops: 0000 [#1] SMP 
[   56.604020] CPU: 1 PID: 398 Comm: trinity-main Not tainted 4.6.0-rc4-00181-gc5dfd78 #1
[   56.607177] task: 83584200 ti: 83778000 task.ti: 83778000
[   56.610893] EIP: 0060:[<790e4f29>] EFLAGS: 00010002 CPU: 1
[   56.611717] EIP is at perf_prepare_sample+0x229/0x330
[   56.613429] EAX: 00000c40 EBX: 83779d14 ECX: 00000008 EDX: 0000019d
[   56.615646] ESI: 83779e00 EDI: 89d0e400 EBP: 83779cfc ESP: 83779ce4
[   56.619967]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   56.621607] CR0: 80050033 CR2: 00000c40 CR3: 12087000 CR4: 00000690
[   56.622546] DR0: 6f062000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   56.624617] DR6: ffff0ff0 DR7: 00000600
[   56.625979] Stack:
[   56.626276]  00000000 00000000 000307e6 89d0e400 83779e00 890e38c0 83779d40 790e5098
[   56.630229]  890e38c0 00000000 00000000 790e5030 00000009 00480001 835846c0 83584200
[   56.639146]  00000000 83779d70 79092d70 0002c018 00000007 89d0e400 00000000 83779d68
[   56.642142] Call Trace:
[   56.642528]  [<790e5098>] perf_event_output_forward+0x68/0x130
[   56.645403]  [<790e5030>] ? perf_prepare_sample+0x330/0x330
[   56.648553]  [<79092d70>] ? __lock_acquire+0x4d0/0xbd0
[   56.651322]  [<790dd1b9>] __perf_event_overflow+0xa9/0x220
[   56.653819]  [<790e5a5f>] perf_swevent_overflow+0x4f/0x90
[   56.654639]  [<790e5b6d>] perf_swevent_event+0xcd/0x100
[   56.658184]  [<790e60cb>] ___perf_sw_event+0x26b/0x300
[   56.660930]  [<790e5e82>] ? ___perf_sw_event+0x22/0x300
[   56.664053]  [<79076260>] ? set_next_entity+0x4b0/0xcd0
[   56.667992]  [<7907e9fd>] ? pick_next_task_fair+0x6cd/0x700
[   56.669659]  [<796150a4>] ? __schedule+0xb4/0x830
[   56.670383]  [<7906afc0>] ? update_rq_clock+0x80/0xa0
[   56.672287]  [<7961537f>] __schedule+0x38f/0x830
[   56.676127]  [<79615871>] schedule+0x21/0x40
[   56.677534]  [<79000b9d>] exit_to_usermode_loop+0x7d/0xa0
[   56.678284]  [<7900100f>] do_int80_syscall_32+0xcf/0x150
[   56.684207]  [<7961a703>] entry_INT80_32+0x2f/0x2f
[   56.686974] Code: f1 ff f6 45 f0 20 89 46 38 c7 46 3c 00 00 00 00 0f 84 4a fe ff ff 8b 55 08 89 f8 e8 32 4a 00 00 85 c0 89 46 68 0f 84 d7 00 00 00 <8b> 00 40 c1 e0 03 66 01 43 06 e9 26 fe ff ff 8b 45 08 8b 40 34
[   56.695205] EIP: [<790e4f29>] perf_prepare_sample+0x229/0x330 SS:ESP 0068:83779ce4
[   56.696421] CR2: 0000000000000c40
[   56.698982] ---[ end trace 3c0cfd42bd35a255 ]---
[   56.699680] Kernel panic - not syncing: Fatal exception

git bisect start 33688abb2802ff3a230bd2441f765477b94cc89e v4.6 --
git bisect  bad 48dd7cefa010b704eb2532a2883798fd6d703a0e  # 23:14      0-      1  Merge tag 'vfio-v4.7-rc1' of git://github.com/awilliam/linux-vfio
git bisect  bad 676d9735cd010fc439566e2b6e9b6adc3e1179ef  # 23:19      0-      1  Merge tag 'rpmsg-v4.7' of git://github.com/andersson/remoteproc
git bisect  bad 7f427d3a6029331304f91ef4d7cf646f054216d2  # 23:27    110-     26  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect  bad ce6a01c2d50e1d400cb6d492841f9b1932034fc2  # 23:32      9-      2  Merge tag 'metag-for-v4.7' of git://git.kernel.org/pub/scm/linux/kernel/git/jhogan/metag
git bisect  bad 36db171cc733bc7b8c628ef21831467d1919decd  # 23:46      0-      1  Merge branch 'perf-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 230e51f21101e49c8d73018d414adbd0d57459a1  # 23:57    310+      4  Merge branch 'core-signals-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 1c19b68a279c58d6da4379bf8b6d679a300a1daf  # 00:07    310+     18  Merge branch 'locking-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 3469d261eac65912927dca13ee8f77c744ad7aa2  # 00:18    310+     27  Merge branch 'locking-rwsem-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good f56ebf20d0f535f5da7cfcf0000ab3e0af133f81  # 00:40    310+      0  perf jit: memset() variable 'st' using the correct size
git bisect  bad 5101ef20f0ef1de79091a1fdb6b1a7f07565545a  # 00:44      0-      3  perf/arm: Special-case hetereogeneous CPUs
git bisect good 4bd112df3eea4db63fe90fb4e83c48d3f3bd6512  # 01:05    303+      0  tools lib api fs: Add helper to read string from procfs file
git bisect  bad 3dcc4436fa6f09ce093ff59bf8477c3059dc46df  # 01:17      7-      1  perf tools: Introduce trigger class
git bisect  bad 4cb93446c587d56e2a54f4f83113daba2c0b6dee  # 01:22      3-      1  perf tools: Set the maximum allowed stack from /proc/sys/kernel/perf_event_max_stack
git bisect good c61fb959df898b994382d586046d7704476ff503  # 04:04    310+      0  perf probe: Fix module probe issue if no dwarf support
git bisect good c2a218c63ba36946aca5943c0c8ebd3a42e3dc4b  # 06:47    310+      0  perf bench: Remove one more die() call
git bisect  bad c5dfd78eb79851e278b7973031b9ca363da87a7e  # 07:57     33-      2  perf core: Allow setting up max frame stack depth via sysctl
# first bad commit: [c5dfd78eb79851e278b7973031b9ca363da87a7e] perf core: Allow setting up max frame stack depth via sysctl
git bisect good c2a218c63ba36946aca5943c0c8ebd3a42e3dc4b  # 08:06    910+      0  perf bench: Remove one more die() call
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad c5dfd78eb79851e278b7973031b9ca363da87a7e  # 08:10      0-      3  perf core: Allow setting up max frame stack depth via sysctl
# extra tests on HEAD of linux-devel/devel-hourly-2016062414
git bisect  bad e8d665056895dafedd7882bfe250ff6cf7dfbc0d  # 08:10      0-     53  0day head guard for 'devel-hourly-2016062414'
# extra tests on tree/branch linus/master
git bisect  bad 63c04ee7d3b7c8d8e2726cb7c5f8a5f6fcc1e3b2  # 08:22      0-      3  Merge tag 'upstream-4.7-rc5' of git://git.infradead.org/linux-ubifs
# extra tests on tree/branch linus/master
git bisect  bad 63c04ee7d3b7c8d8e2726cb7c5f8a5f6fcc1e3b2  # 08:23      0-      5  Merge tag 'upstream-4.7-rc5' of git://git.infradead.org/linux-ubifs
# extra tests on tree/branch linux-next/master
git bisect  bad 2cf991dfda8b36d2878c249bcdf492366ec24c19  # 08:29     14-      1  Add linux-next specific files for 20160624


This script may reproduce the error.

----------------------------------------------------------------------------
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
	-m 300
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	systemd.log_level=err
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_576dd0a0.3zE0c8775Ufwn12T/Gq4Xk3UYB0YrfXPIvkvYibRp0tANY2S
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-kbuild-53:20160625075710:i386-randconfig-h0-06242012:4.6.0-rc4-00181-gc5dfd78:1.gz"

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
P8Vy1osthCNH/wcSgRqohesAAA==

--=_576dd0a0.3zE0c8775Ufwn12T/Gq4Xk3UYB0YrfXPIvkvYibRp0tANY2S
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.6.0-rc4-00181-gc5dfd78"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.6.0-rc4 Kernel Configuration
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
CONFIG_X86_32_SMP=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
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
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
# CONFIG_SHMEM is not set
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
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
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_FAST_FEATURE_TESTS is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_BIGSMP is not set
CONFIG_GOLDFISH=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_32_NON_STANDARD is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
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
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
CONFIG_MK8=y
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
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_LEGACY_VM86 is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=y
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_2G_OPT=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x78000000
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
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_FRAME_VECTOR=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_HOTPLUG_CPU is not set
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
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
# CONFIG_PMIC_OPREGION is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_SPEEDSTEP_ICH is not set
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=y
CONFIG_X86_LONGRUN=y
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_CPU_IDLE_GOV_MENU is not set
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

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
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
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
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
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
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
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
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_SCx200_DOCFLASH=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=y
CONFIG_MTD_PCMCIA_ANONYMOUS=y
# CONFIG_MTD_GPIO_ADDR is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_CS553X is not set
CONFIG_MTD_NAND_NANDSIM=y
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_NAND_HISI504=y
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_BMP085_SPI=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

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
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_USERIO=y
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_SERIAL_MVEBU_UART is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_SI_PROBE_DEFAULTS=y
CONFIG_IPMI_SSIF=y
# CONFIG_IPMI_WATCHDOG is not set
# CONFIG_IPMI_POWEROFF is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
CONFIG_CARDMAN_4040=y
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_TIS_ST33ZP24 is not set
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
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
# CONFIG_I2C_HELPER_AUTO is not set
# CONFIG_I2C_SMBUS is not set

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_DESIGNWARE is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
# CONFIG_HSI is not set

#
# PPS support
#
# CONFIG_PPS is not set

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
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MENZ127=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_ZX is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
# CONFIG_GPIO_104_IDI_48 is not set
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_SX150X=y
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_CRYSTAL_COVE is not set
# CONFIG_GPIO_DA9052 is not set
# CONFIG_GPIO_KEMPLD is not set
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_TPS65086 is not set
CONFIG_GPIO_TPS65218=y
CONFIG_GPIO_TPS6586X=y
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_PISOSR=y

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_CHARGER_DA9150 is not set
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_LP8788 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_MAX8998 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_CHARGER_TPS65217 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_BATTERY_RT5033 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
# CONFIG_SENSORS_LTC3815 is not set
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_UCD9000=y
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_ZL6100 is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9052_WATCHDOG=y
# CONFIG_DA9062_WATCHDOG is not set
CONFIG_WM831X_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
CONFIG_ZIIRAVE_WATCHDOG=y
CONFIG_CADENCE_WATCHDOG=y
# CONFIG_DW_WATCHDOG is not set
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_EBC_C384_WDT=y
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_KEMPLD_WDT is not set
CONFIG_SC1200_WDT=y
# CONFIG_SCx200_WDT is not set
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
# CONFIG_SBC7240_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_NI903X_WDT is not set
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_RN5T618 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AB3100=y
# CONFIG_REGULATOR_DA903X is not set
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9062=y
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
# CONFIG_REGULATOR_MT6397 is not set
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_QCOM_SPMI=y
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_RT5033 is not set
CONFIG_REGULATOR_S2MPA01=y
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS6586X=y
# CONFIG_REGULATOR_TPS65912 is not set
# CONFIG_REGULATOR_TPS80031 is not set
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=y
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=y

#
# Supported MMC/SDIO adapters
#

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_ADV7511 is not set
CONFIG_DRM_I2C_CH7006=y
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_AMD_ACP is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_SM501=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
CONFIG_FB_AUO_K1901=y
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
# CONFIG_LCD_TDO24M is not set
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP5520 is not set
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_HDMI=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
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
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_USDHI6ROL0=y
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_LP8860=y
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_ADP5520 is not set
# CONFIG_LEDS_MC13783 is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD76X is not set
# CONFIG_EDAC_E7XXX is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82875P is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_IE31200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
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
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_PCH_DMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
# CONFIG_ADIS16204 is not set
CONFIG_ADIS16209=y
# CONFIG_ADIS16220 is not set
CONFIG_ADIS16240=y
CONFIG_LIS3L02DQ=y
CONFIG_SCA3000=y

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
CONFIG_AD7780=y
# CONFIG_AD7816 is not set
CONFIG_AD7192=y
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_SPI=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
CONFIG_AD9834=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=y

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
CONFIG_ADE7753=y
CONFIG_ADE7754=y
CONFIG_ADE7758=y
CONFIG_ADE7759=y
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
CONFIG_ADE7854_SPI=y

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
CONFIG_AD2S1200=y
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_GOLDFISH_AUDIO is not set
# CONFIG_MTD_GOLDFISH_NAND is not set
CONFIG_MTD_SPINAND_MT29F=y
# CONFIG_MTD_SPINAND_ONDIEECC is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_FB_TFT=y
CONFIG_FB_TFT_AGM1264K_FL=y
CONFIG_FB_TFT_BD663474=y
# CONFIG_FB_TFT_HX8340BN is not set
# CONFIG_FB_TFT_HX8347D is not set
CONFIG_FB_TFT_HX8353D=y
CONFIG_FB_TFT_HX8357D=y
# CONFIG_FB_TFT_ILI9163 is not set
CONFIG_FB_TFT_ILI9320=y
CONFIG_FB_TFT_ILI9325=y
CONFIG_FB_TFT_ILI9340=y
CONFIG_FB_TFT_ILI9341=y
# CONFIG_FB_TFT_ILI9481 is not set
CONFIG_FB_TFT_ILI9486=y
CONFIG_FB_TFT_PCD8544=y
# CONFIG_FB_TFT_RA8875 is not set
CONFIG_FB_TFT_S6D02A1=y
CONFIG_FB_TFT_S6D1121=y
# CONFIG_FB_TFT_SSD1289 is not set
# CONFIG_FB_TFT_SSD1305 is not set
CONFIG_FB_TFT_SSD1306=y
CONFIG_FB_TFT_SSD1325=y
CONFIG_FB_TFT_SSD1331=y
# CONFIG_FB_TFT_SSD1351 is not set
# CONFIG_FB_TFT_ST7735R is not set
CONFIG_FB_TFT_ST7789V=y
CONFIG_FB_TFT_TINYLCD=y
# CONFIG_FB_TFT_TLS8204 is not set
CONFIG_FB_TFT_UC1611=y
CONFIG_FB_TFT_UC1701=y
# CONFIG_FB_TFT_UPD161704 is not set
CONFIG_FB_TFT_WATTEROTT=y
CONFIG_FB_FLEX=y
# CONFIG_FB_TFT_FBTFT_DEVICE is not set
# CONFIG_MOST is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
# CONFIG_GOLDFISH_BUS is not set
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y

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
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX3355=y
# CONFIG_EXTCON_MAX77693 is not set
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
# CONFIG_BMA180 is not set
# CONFIG_BMC150_ACCEL is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y
CONFIG_KXSD9=y
# CONFIG_KXCJK1013 is not set
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
# CONFIG_MMA7455_SPI is not set
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=y
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
# CONFIG_STK8312 is not set
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
CONFIG_AD7298=y
# CONFIG_AD7476 is not set
# CONFIG_AD7791 is not set
# CONFIG_AD7793 is not set
CONFIG_AD7887=y
CONFIG_AD7923=y
CONFIG_AD799X=y
CONFIG_DA9150_GPADC=y
# CONFIG_HI8435 is not set
CONFIG_LP8788_ADC=y
CONFIG_MAX1027=y
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=y
# CONFIG_MCP3422 is not set
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_QCOM_SPMI_IADC=y
# CONFIG_QCOM_SPMI_VADC is not set
# CONFIG_TI_ADC081C is not set
# CONFIG_TI_ADC0832 is not set
# CONFIG_TI_ADC128S052 is not set

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=y
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
CONFIG_AD5449=y
CONFIG_AD5504=y
CONFIG_AD5624R_SPI=y
# CONFIG_AD5686 is not set
CONFIG_AD5755=y
# CONFIG_AD5761 is not set
# CONFIG_AD5764 is not set
CONFIG_AD5791=y
# CONFIG_AD7303 is not set
CONFIG_M62332=y
CONFIG_MAX517=y
CONFIG_MCP4725=y
# CONFIG_MCP4922 is not set

#
# IIO dummy driver
#
CONFIG_IIO_DUMMY_EVGEN=y
CONFIG_IIO_SIMPLE_DUMMY=y
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
# CONFIG_ADF4350 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16130=y
CONFIG_ADIS16136=y
CONFIG_ADIS16260=y
# CONFIG_ADXRS450 is not set
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_BMG160_SPI=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4403 is not set
# CONFIG_AFE4404 is not set
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
CONFIG_DHT11=y
CONFIG_HDC100X=y
CONFIG_HTU21=y
CONFIG_SI7005=y
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
# CONFIG_ADIS16480 is not set
CONFIG_KMX61=y
# CONFIG_INV_MPU6050_I2C is not set
# CONFIG_INV_MPU6050_SPI is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
CONFIG_APDS9960=y
CONFIG_BH1750=y
CONFIG_CM32181=y
CONFIG_CM3232=y
CONFIG_CM3323=y
# CONFIG_CM36651 is not set
# CONFIG_GP2AP020A00F is not set
# CONFIG_ISL29125 is not set
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_LTR501=y
# CONFIG_OPT3001 is not set
CONFIG_PA12203001=y
# CONFIG_STK3310 is not set
CONFIG_TCS3414=y
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
CONFIG_US5182D=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
CONFIG_MAG3110=y
CONFIG_MMC35240=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set
# CONFIG_SENSORS_HMC5843_I2C is not set
# CONFIG_SENSORS_HMC5843_SPI is not set

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
CONFIG_MPL115=y
# CONFIG_MPL115_I2C is not set
CONFIG_MPL115_SPI=y
CONFIG_MPL3115=y
CONFIG_MS5611=y
CONFIG_MS5611_I2C=y
CONFIG_MS5611_SPI=y
# CONFIG_MS5637 is not set
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y

#
# Lightning sensors
#
# CONFIG_AS3935 is not set

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_SX9500=y

#
# Temperature sensors
#
CONFIG_MLX90614=y
# CONFIG_TMP006 is not set
CONFIG_TSYS01=y
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_NVMEM=y
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_MSU=y
# CONFIG_INTEL_TH_PTI is not set
CONFIG_INTEL_TH_DEBUG=y

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
# CONFIG_FPGA_MGR_ZYNQ_FPGA is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

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
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ECRYPT_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_ATIME_SUPPORT is not set
# CONFIG_LOGFS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
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
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VM_PGFLAGS=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
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
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_RHASHTABLE=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_UDELAY is not set
CONFIG_MEMTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_WX is not set
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
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
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
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
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
# CONFIG_CRYPTO_CBC is not set
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
# CONFIG_CRYPTO_CRC32C is not set
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_DES is not set
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_LGUEST is not set
# CONFIG_BINARY_PRINTF is not set

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
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
# CONFIG_SG_SPLIT is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y

--=_576dd0a0.3zE0c8775Ufwn12T/Gq4Xk3UYB0YrfXPIvkvYibRp0tANY2S--
