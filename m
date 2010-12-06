From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (adding ipv6 address to interface)
Date: Mon, 06 Dec 2010 13:22:00 -0800
Message-ID: <m11v5uk35z.fsf@fess.ebiederm.org>
References: <20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
	<20101021171532.54af5e97@xenia.leun.net>
	<20101022124858.GA719746@jupiter.n2.diac24.net>
	<20101022190532.00e9e5d8@xenia.leun.net>
	<20101024151541.161bf46c@xenia.leun.net>
	<4CFD0A8F.8010906@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Michael Leun <lkml20100708@newton.leun.net>,
	David Lamparter <equinox@diac24.net>, Greg KH <greg@kroah.com>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: jean-philippe.menil@univ-nantes.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CFD0A8F.8010906@univ-nantes.fr> (Menil Jean-Philippe's message
	of "Mon, 06 Dec 2010 17:08:47 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Menil Jean-Philippe <jean-philippe.menil@univ-nantes.fr> writes:

> Le 24/10/2010 15:15, Michael Leun a =C3=A9crit :
>> On Fri, 22 Oct 2010 19:05:32 +0200
>> Michael Leun<lkml20100708@newton.leun.net>  wrote:
>>
>>> On Fri, 22 Oct 2010 14:48:58 +0200
>>> David Lamparter<equinox@diac24.net>  wrote:
>>>
>>>> On Thu, Oct 21, 2010 at 05:15:32PM +0200, Michael Leun wrote:
>>>>> unfortunately the bug described below originally reported in
>>>>> 2.6.35-rcX is still there in 2.6.36.
>>>>
>>>> can you post your full kernel .config?
>>>
>>> Please find below.
>>>
>>>> I'm using network namespaces quite extensively - OpenVPN and IPv6
>>>> included - and i haven't hit this bug. That makes it rather likely
>>>> it depends on some option difference.
>>>
>>> I take candidates for options to change for test... ;-)
>>>
>>> Maybe I will try to strip it down for test towards a minimal config=
=2E
>>
>> Now I have tried a kernel config with almost everything disabled -
>> please find below.
>>
>> If I have overlooked anything I should disable (or if you suggest I
>> should not disable, but enable any option) - please tell me.
>>
>> I've created an ~2.5MB bootable ISO image based on buildroot/busybox
>> with this kernel, which also shows this bug (e.g. when run in
>> VirtualBox).
>>
>> If anybody is interested I could send this image as mail attachment =
or
>> provide a download link.
>>
>> ml@xenia:~>  grep -v "^#" .config |grep -v "^ *$"
>> CONFIG_X86_32=3Dy
>> CONFIG_X86=3Dy
>> CONFIG_INSTRUCTION_DECODER=3Dy
>> CONFIG_OUTPUT_FORMAT=3D"elf32-i386"
>> CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/i386_defconfig"
>> CONFIG_GENERIC_CMOS_UPDATE=3Dy
>> CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS=3Dy
>> CONFIG_LOCKDEP_SUPPORT=3Dy
>> CONFIG_STACKTRACE_SUPPORT=3Dy
>> CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
>> CONFIG_MMU=3Dy
>> CONFIG_ZONE_DMA=3Dy
>> CONFIG_NEED_SG_DMA_LENGTH=3Dy
>> CONFIG_GENERIC_ISA_DMA=3Dy
>> CONFIG_GENERIC_IOMAP=3Dy
>> CONFIG_GENERIC_BUG=3Dy
>> CONFIG_GENERIC_HWEIGHT=3Dy
>> CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
>> CONFIG_RWSEM_XCHGADD_ALGORITHM=3Dy
>> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
>> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
>> CONFIG_ARCH_HAS_CPU_RELAX=3Dy
>> CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
>> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
>> CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
>> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=3Dy
>> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=3Dy
>> CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
>> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
>> CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
>> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
>> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
>> CONFIG_HAVE_EARLY_RES=3Dy
>> CONFIG_GENERIC_HARDIRQS=3Dy
>> CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=3Dy
>> CONFIG_GENERIC_IRQ_PROBE=3Dy
>> CONFIG_X86_32_LAZY_GS=3Dy
>> CONFIG_ARCH_HWEIGHT_CFLAGS=3D"-fcall-saved-ecx -fcall-saved-edx"
>> CONFIG_KTIME_SCALAR=3Dy
>> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
>> CONFIG_CONSTRUCTORS=3Dy
>> CONFIG_EXPERIMENTAL=3Dy
>> CONFIG_BROKEN_ON_SMP=3Dy
>> CONFIG_INIT_ENV_ARG_LIMIT=3D32
>> CONFIG_CROSS_COMPILE=3D""
>> CONFIG_LOCALVERSION=3D""
>> CONFIG_HAVE_KERNEL_GZIP=3Dy
>> CONFIG_HAVE_KERNEL_BZIP2=3Dy
>> CONFIG_HAVE_KERNEL_LZMA=3Dy
>> CONFIG_HAVE_KERNEL_LZO=3Dy
>> CONFIG_KERNEL_LZMA=3Dy
>> CONFIG_TREE_RCU=3Dy
>> CONFIG_RCU_FANOUT=3D32
>> CONFIG_IKCONFIG=3Dy
>> CONFIG_IKCONFIG_PROC=3Dy
>> CONFIG_LOG_BUF_SHIFT=3D18
>> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
>> CONFIG_NAMESPACES=3Dy
>> CONFIG_NET_NS=3Dy
>> CONFIG_BLK_DEV_INITRD=3Dy
>> CONFIG_INITRAMFS_SOURCE=3D""
>> CONFIG_RD_GZIP=3Dy
>> CONFIG_RD_BZIP2=3Dy
>> CONFIG_RD_LZMA=3Dy
>> CONFIG_RD_LZO=3Dy
>> CONFIG_SYSCTL=3Dy
>> CONFIG_ANON_INODES=3Dy
>> CONFIG_UID16=3Dy
>> CONFIG_SYSCTL_SYSCALL=3Dy
>> CONFIG_KALLSYMS=3Dy
>> CONFIG_HOTPLUG=3Dy
>> CONFIG_PRINTK=3Dy
>> CONFIG_BUG=3Dy
>> CONFIG_ELF_CORE=3Dy
>> CONFIG_PCSPKR_PLATFORM=3Dy
>> CONFIG_BASE_FULL=3Dy
>> CONFIG_FUTEX=3Dy
>> CONFIG_EPOLL=3Dy
>> CONFIG_SIGNALFD=3Dy
>> CONFIG_TIMERFD=3Dy
>> CONFIG_EVENTFD=3Dy
>> CONFIG_SHMEM=3Dy
>> CONFIG_AIO=3Dy
>> CONFIG_HAVE_PERF_EVENTS=3Dy
>> CONFIG_PERF_EVENTS=3Dy
>> CONFIG_VM_EVENT_COUNTERS=3Dy
>> CONFIG_PCI_QUIRKS=3Dy
>> CONFIG_SLUB_DEBUG=3Dy
>> CONFIG_SLUB=3Dy
>> CONFIG_HAVE_OPROFILE=3Dy
>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
>> CONFIG_HAVE_IOREMAP_PROT=3Dy
>> CONFIG_HAVE_KPROBES=3Dy
>> CONFIG_HAVE_KRETPROBES=3Dy
>> CONFIG_HAVE_OPTPROBES=3Dy
>> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
>> CONFIG_HAVE_DMA_ATTRS=3Dy
>> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=3Dy
>> CONFIG_HAVE_DMA_API_DEBUG=3Dy
>> CONFIG_HAVE_HW_BREAKPOINT=3Dy
>> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=3Dy
>> CONFIG_HAVE_USER_RETURN_NOTIFIER=3Dy
>> CONFIG_HAVE_PERF_EVENTS_NMI=3Dy
>> CONFIG_HAVE_GENERIC_DMA_COHERENT=3Dy
>> CONFIG_SLABINFO=3Dy
>> CONFIG_RT_MUTEXES=3Dy
>> CONFIG_BASE_SMALL=3D0
>> CONFIG_BLOCK=3Dy
>> CONFIG_LBDAF=3Dy
>> CONFIG_IOSCHED_NOOP=3Dy
>> CONFIG_DEFAULT_NOOP=3Dy
>> CONFIG_DEFAULT_IOSCHED=3D"noop"
>> CONFIG_INLINE_SPIN_UNLOCK=3Dy
>> CONFIG_INLINE_SPIN_UNLOCK_IRQ=3Dy
>> CONFIG_INLINE_READ_UNLOCK=3Dy
>> CONFIG_INLINE_READ_UNLOCK_IRQ=3Dy
>> CONFIG_INLINE_WRITE_UNLOCK=3Dy
>> CONFIG_INLINE_WRITE_UNLOCK_IRQ=3Dy
>> CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
>> CONFIG_M586=3Dy
>> CONFIG_X86_CPU=3Dy
>> CONFIG_X86_INTERNODE_CACHE_SHIFT=3D5
>> CONFIG_X86_CMPXCHG=3Dy
>> CONFIG_X86_L1_CACHE_SHIFT=3D5
>> CONFIG_X86_XADD=3Dy
>> CONFIG_X86_F00F_BUG=3Dy
>> CONFIG_X86_WP_WORKS_OK=3Dy
>> CONFIG_X86_INVLPG=3Dy
>> CONFIG_X86_BSWAP=3Dy
>> CONFIG_X86_POPAD_OK=3Dy
>> CONFIG_X86_ALIGNMENT_16=3Dy
>> CONFIG_X86_MINIMUM_CPU_FAMILY=3D4
>> CONFIG_CPU_SUP_INTEL=3Dy
>> CONFIG_CPU_SUP_CYRIX_32=3Dy
>> CONFIG_CPU_SUP_AMD=3Dy
>> CONFIG_CPU_SUP_CENTAUR=3Dy
>> CONFIG_CPU_SUP_TRANSMETA_32=3Dy
>> CONFIG_CPU_SUP_UMC_32=3Dy
>> CONFIG_DMI=3Dy
>> CONFIG_NR_CPUS=3D1
>> CONFIG_PREEMPT_NONE=3Dy
>> CONFIG_VM86=3Dy
>> CONFIG_HIGHMEM4G=3Dy
>> CONFIG_PAGE_OFFSET=3D0xC0000000
>> CONFIG_HIGHMEM=3Dy
>> CONFIG_NEED_NODE_MEMMAP_SIZE=3Dy
>> CONFIG_ARCH_FLATMEM_ENABLE=3Dy
>> CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
>> CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
>> CONFIG_ILLEGAL_POINTER_VALUE=3D0
>> CONFIG_SELECT_MEMORY_MODEL=3Dy
>> CONFIG_SPARSEMEM_MANUAL=3Dy
>> CONFIG_SPARSEMEM=3Dy
>> CONFIG_HAVE_MEMORY_PRESENT=3Dy
>> CONFIG_SPARSEMEM_STATIC=3Dy
>> CONFIG_SPLIT_PTLOCK_CPUS=3D4
>> CONFIG_ZONE_DMA_FLAG=3D1
>> CONFIG_BOUNCE=3Dy
>> CONFIG_VIRT_TO_BUS=3Dy
>> CONFIG_DEFAULT_MMAP_MIN_ADDR=3D65536
>> CONFIG_MTRR=3Dy
>> CONFIG_X86_PAT=3Dy
>> CONFIG_ARCH_USES_PG_UNCACHED=3Dy
>> CONFIG_HZ_1000=3Dy
>> CONFIG_HZ=3D1000
>> CONFIG_PHYSICAL_START=3D0x1000000
>> CONFIG_PHYSICAL_ALIGN=3D0x1000000
>> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
>> CONFIG_PCI=3Dy
>> CONFIG_PCI_GOANY=3Dy
>> CONFIG_PCI_BIOS=3Dy
>> CONFIG_PCI_DIRECT=3Dy
>> CONFIG_PCI_DOMAINS=3Dy
>> CONFIG_ISA_DMA_API=3Dy
>> CONFIG_K8_NB=3Dy
>> CONFIG_BINFMT_ELF=3Dy
>> CONFIG_HAVE_AOUT=3Dy
>> CONFIG_HAVE_ATOMIC_IOMAP=3Dy
>> CONFIG_NET=3Dy
>> CONFIG_UNIX=3Dy
>> CONFIG_INET=3Dy
>> CONFIG_IP_FIB_HASH=3Dy
>> CONFIG_TCP_CONG_CUBIC=3Dy
>> CONFIG_DEFAULT_TCP_CONG=3D"cubic"
>> CONFIG_IPV6=3Dy
>> CONFIG_UEVENT_HELPER_PATH=3D""
>> CONFIG_DEVTMPFS=3Dy
>> CONFIG_DEVTMPFS_MOUNT=3Dy
>> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
>> CONFIG_FW_LOADER=3Dy
>> CONFIG_EXTRA_FIRMWARE=3D""
>> CONFIG_HAVE_IDE=3Dy
>> CONFIG_SCSI_MOD=3Dy
>> CONFIG_NETDEVICES=3Dy
>> CONFIG_VETH=3Dy
>> CONFIG_INPUT=3Dy
>> CONFIG_INPUT_MOUSEDEV=3Dy
>> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
>> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D576
>> CONFIG_INPUT_KEYBOARD=3Dy
>> CONFIG_KEYBOARD_ATKBD=3Dy
>> CONFIG_SERIO=3Dy
>> CONFIG_SERIO_I8042=3Dy
>> CONFIG_SERIO_LIBPS2=3Dy
>> CONFIG_VT=3Dy
>> CONFIG_CONSOLE_TRANSLATIONS=3Dy
>> CONFIG_VT_CONSOLE=3Dy
>> CONFIG_HW_CONSOLE=3Dy
>> CONFIG_FIX_EARLYCON_MEM=3Dy
>> CONFIG_UNIX98_PTYS=3Dy
>> CONFIG_DEVPORT=3Dy
>> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
>> CONFIG_SSB_POSSIBLE=3Dy
>> CONFIG_VGA_ARB=3Dy
>> CONFIG_VGA_ARB_MAX_GPUS=3D16
>> CONFIG_VGA_CONSOLE=3Dy
>> CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
>> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D64
>> CONFIG_DUMMY_CONSOLE=3Dy
>> CONFIG_FIRMWARE_MEMMAP=3Dy
>> CONFIG_FILE_LOCKING=3Dy
>> CONFIG_PROC_FS=3Dy
>> CONFIG_PROC_SYSCTL=3Dy
>> CONFIG_PROC_PAGE_MONITOR=3Dy
>> CONFIG_SYSFS=3Dy
>> CONFIG_MSDOS_PARTITION=3Dy
>> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
>> CONFIG_FRAME_WARN=3D2048
>> CONFIG_DEBUG_BUGVERBOSE=3Dy
>> CONFIG_DEBUG_MEMORY_INIT=3Dy
>> CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
>> CONFIG_USER_STACKTRACE_SUPPORT=3Dy
>> CONFIG_HAVE_FUNCTION_TRACER=3Dy
>> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
>> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=3Dy
>> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
>> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
>> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
>> CONFIG_HAVE_SYSCALL_TRACEPOINTS=3Dy
>> CONFIG_TRACING_SUPPORT=3Dy
>> CONFIG_HAVE_ARCH_KGDB=3Dy
>> CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
>> CONFIG_EARLY_PRINTK=3Dy
>> CONFIG_DOUBLEFAULT=3Dy
>> CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
>> CONFIG_IO_DELAY_TYPE_0X80=3D0
>> CONFIG_IO_DELAY_TYPE_0XED=3D1
>> CONFIG_IO_DELAY_TYPE_UDELAY=3D2
>> CONFIG_IO_DELAY_TYPE_NONE=3D3
>> CONFIG_IO_DELAY_0X80=3Dy
>> CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
>> CONFIG_DEFAULT_SECURITY_DAC=3Dy
>> CONFIG_DEFAULT_SECURITY=3D""
>> CONFIG_HAVE_KVM=3Dy
>> CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
>> CONFIG_GENERIC_FIND_NEXT_BIT=3Dy
>> CONFIG_GENERIC_FIND_LAST_BIT=3Dy
>> CONFIG_ZLIB_INFLATE=3Dy
>> CONFIG_LZO_DECOMPRESS=3Dy
>> CONFIG_DECOMPRESS_GZIP=3Dy
>> CONFIG_DECOMPRESS_BZIP2=3Dy
>> CONFIG_DECOMPRESS_LZMA=3Dy
>> CONFIG_DECOMPRESS_LZO=3Dy
>> CONFIG_HAS_IOMEM=3Dy
>> CONFIG_HAS_IOPORT=3Dy
>> CONFIG_HAS_DMA=3Dy
>> CONFIG_NLATTR=3Dy
>>
>
> Hi,
>
> curiously, i'm facing a similar problem in 2.6.36.1
>
> in my container, when i configure ipv6 adress on the interfaces, ever=
ything
> seems good on the first boot of the host. If i shutdown my container =
(lxc), then
> boot it, i observe the following logs:
> Dec  6 17:04:12 suntory.u06.univ-nantes.prive kernel: [  368.192019]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:04:22 suntory.u06.univ-nantes.prive kernel: [  378.432018]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:04:32 suntory.u06.univ-nantes.prive kernel: [  388.672015]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:04:42 suntory.u06.univ-nantes.prive kernel: [  398.912016]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:04:53 suntory.u06.univ-nantes.prive kernel: [  409.152016]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:03 suntory.u06.univ-nantes.prive kernel: [  419.392018]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:13 suntory.u06.univ-nantes.prive kernel: [  429.632018]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:23 suntory.u06.univ-nantes.prive kernel: [  439.876016]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:34 suntory.u06.univ-nantes.prive kernel: [  450.116015]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:44 suntory.u06.univ-nantes.prive kernel: [  460.356019]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:05:54 suntory.u06.univ-nantes.prive kernel: [  470.596020]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:06:04 suntory.u06.univ-nantes.prive kernel: [  480.836019]
> unregister_netdevice: waiting for lo to become free. Usage count =3D =
4
> Dec  6 17:06:05 suntory.u06.univ-nantes.prive kernel: [  481.468021] =
INFO: task
> lxc-start:3805 blocked for more than 120 seconds.
>
> Then i must reboot the host.
> The same on kernel 2.6.34, but everything is good on a 2.6.32
>
> Some relvant informations about the kernel:
> root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i sysfs
> # CONFIG_SYSFS_DEPRECATED_V2 is not set
> CONFIG_ACPI_SYSFS_POWER=3Dy
> # CONFIG_WIRELESS_EXT_SYSFS is not set
> CONFIG_ISCSI_BOOT_SYSFS=3Dm
> CONFIG_RTC_INTF_SYSFS=3Dy
> CONFIG_SYSFS=3Dy
> root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i net_ns
> CONFIG_NET_NS=3Dy
>
> Is there anything in my configuration, i must check in order to get i=
pv6 working
> fully in the container?

2.6.37-rc4 is working here.  There were problems earlier in the earlier
rcs. Can you try that?

There have been a couple of different reference counting bugs between
2.6.34 and the present, and I haven't tracked them, just noticed they
exist.

Eric
