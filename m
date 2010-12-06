From: Menil Jean-Philippe <jean-philippe.menil@univ-nantes.fr>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (adding
 ipv6 address to interface)
Date: Mon, 06 Dec 2010 17:08:47 +0100
Message-ID: <4CFD0A8F.8010906@univ-nantes.fr>
References: <20100710235323.5336f627@xenia.leun.net>	<20100711192939.1c25dcaf@xenia.leun.net>	<20100804153543.56f6ecad@xenia.leun.net>	<20100804214618.GA6289@kroah.com>	<20100805001105.5a3453ed@xenia.leun.net>	<m1lj8l29zm.fsf@fess.ebiederm.org>	<20100805112538.60a46cb1@xenia.leun.net>	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>	<20100805134707.0442a7b1@xenia.leun.net>	<20101021171532.54af5e97@xenia.leun.net>	<20101022124858.GA719746@jupiter.n2.diac24.net>	<20101022190532.00e9e5d8@xenia.leun.net> <20101024151541.161bf46c@xenia.leun.net>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080504030802060008020209"
Cc: Michael Leun <lkml20100708@newton.leun.net>,
	David Lamparter <equinox@diac24.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101024151541.161bf46c@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080504030802060008020209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Le 24/10/2010 15:15, Michael Leun a écrit :
> On Fri, 22 Oct 2010 19:05:32 +0200
> Michael Leun<lkml20100708@newton.leun.net>  wrote:
>
>> On Fri, 22 Oct 2010 14:48:58 +0200
>> David Lamparter<equinox@diac24.net>  wrote:
>>
>>> On Thu, Oct 21, 2010 at 05:15:32PM +0200, Michael Leun wrote:
>>>> unfortunately the bug described below originally reported in
>>>> 2.6.35-rcX is still there in 2.6.36.
>>>
>>> can you post your full kernel .config?
>>
>> Please find below.
>>
>>> I'm using network namespaces quite extensively - OpenVPN and IPv6
>>> included - and i haven't hit this bug. That makes it rather likely
>>> it depends on some option difference.
>>
>> I take candidates for options to change for test... ;-)
>>
>> Maybe I will try to strip it down for test towards a minimal config.
>
> Now I have tried a kernel config with almost everything disabled -
> please find below.
>
> If I have overlooked anything I should disable (or if you suggest I
> should not disable, but enable any option) - please tell me.
>
> I've created an ~2.5MB bootable ISO image based on buildroot/busybox
> with this kernel, which also shows this bug (e.g. when run in
> VirtualBox).
>
> If anybody is interested I could send this image as mail attachment or
> provide a download link.
>
> ml@xenia:~>  grep -v "^#" .config |grep -v "^ *$"
> CONFIG_X86_32=y
> CONFIG_X86=y
> CONFIG_INSTRUCTION_DECODER=y
> CONFIG_OUTPUT_FORMAT="elf32-i386"
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
> CONFIG_GENERIC_CMOS_UPDATE=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_MMU=y
> CONFIG_ZONE_DMA=y
> CONFIG_NEED_SG_DMA_LENGTH=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_DEFAULT_IDLE=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> CONFIG_ARCH_POPULATES_NODE_MAP=y
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
> CONFIG_HAVE_EARLY_RES=y
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_X86_32_LAZY_GS=y
> CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
> CONFIG_KTIME_SCALAR=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_CONSTRUCTORS=y
> CONFIG_EXPERIMENTAL=y
> CONFIG_BROKEN_ON_SMP=y
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_CROSS_COMPILE=""
> CONFIG_LOCALVERSION=""
> CONFIG_HAVE_KERNEL_GZIP=y
> CONFIG_HAVE_KERNEL_BZIP2=y
> CONFIG_HAVE_KERNEL_LZMA=y
> CONFIG_HAVE_KERNEL_LZO=y
> CONFIG_KERNEL_LZMA=y
> CONFIG_TREE_RCU=y
> CONFIG_RCU_FANOUT=32
> CONFIG_IKCONFIG=y
> CONFIG_IKCONFIG_PROC=y
> CONFIG_LOG_BUF_SHIFT=18
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> CONFIG_NAMESPACES=y
> CONFIG_NET_NS=y
> CONFIG_BLK_DEV_INITRD=y
> CONFIG_INITRAMFS_SOURCE=""
> CONFIG_RD_GZIP=y
> CONFIG_RD_BZIP2=y
> CONFIG_RD_LZMA=y
> CONFIG_RD_LZO=y
> CONFIG_SYSCTL=y
> CONFIG_ANON_INODES=y
> CONFIG_UID16=y
> CONFIG_SYSCTL_SYSCALL=y
> CONFIG_KALLSYMS=y
> CONFIG_HOTPLUG=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> CONFIG_PCSPKR_PLATFORM=y
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_AIO=y
> CONFIG_HAVE_PERF_EVENTS=y
> CONFIG_PERF_EVENTS=y
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_PCI_QUIRKS=y
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> CONFIG_HAVE_OPROFILE=y
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> CONFIG_HAVE_IOREMAP_PROT=y
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> CONFIG_HAVE_OPTPROBES=y
> CONFIG_HAVE_ARCH_TRACEHOOK=y
> CONFIG_HAVE_DMA_ATTRS=y
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
> CONFIG_HAVE_DMA_API_DEBUG=y
> CONFIG_HAVE_HW_BREAKPOINT=y
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
> CONFIG_HAVE_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_PERF_EVENTS_NMI=y
> CONFIG_HAVE_GENERIC_DMA_COHERENT=y
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> CONFIG_BASE_SMALL=0
> CONFIG_BLOCK=y
> CONFIG_LBDAF=y
> CONFIG_IOSCHED_NOOP=y
> CONFIG_DEFAULT_NOOP=y
> CONFIG_DEFAULT_IOSCHED="noop"
> CONFIG_INLINE_SPIN_UNLOCK=y
> CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
> CONFIG_INLINE_READ_UNLOCK=y
> CONFIG_INLINE_READ_UNLOCK_IRQ=y
> CONFIG_INLINE_WRITE_UNLOCK=y
> CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> CONFIG_M586=y
> CONFIG_X86_CPU=y
> CONFIG_X86_INTERNODE_CACHE_SHIFT=5
> CONFIG_X86_CMPXCHG=y
> CONFIG_X86_L1_CACHE_SHIFT=5
> CONFIG_X86_XADD=y
> CONFIG_X86_F00F_BUG=y
> CONFIG_X86_WP_WORKS_OK=y
> CONFIG_X86_INVLPG=y
> CONFIG_X86_BSWAP=y
> CONFIG_X86_POPAD_OK=y
> CONFIG_X86_ALIGNMENT_16=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=4
> CONFIG_CPU_SUP_INTEL=y
> CONFIG_CPU_SUP_CYRIX_32=y
> CONFIG_CPU_SUP_AMD=y
> CONFIG_CPU_SUP_CENTAUR=y
> CONFIG_CPU_SUP_TRANSMETA_32=y
> CONFIG_CPU_SUP_UMC_32=y
> CONFIG_DMI=y
> CONFIG_NR_CPUS=1
> CONFIG_PREEMPT_NONE=y
> CONFIG_VM86=y
> CONFIG_HIGHMEM4G=y
> CONFIG_PAGE_OFFSET=0xC0000000
> CONFIG_HIGHMEM=y
> CONFIG_NEED_NODE_MEMMAP_SIZE=y
> CONFIG_ARCH_FLATMEM_ENABLE=y
> CONFIG_ARCH_SPARSEMEM_ENABLE=y
> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> CONFIG_ILLEGAL_POINTER_VALUE=0
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_SPARSEMEM_MANUAL=y
> CONFIG_SPARSEMEM=y
> CONFIG_HAVE_MEMORY_PRESENT=y
> CONFIG_SPARSEMEM_STATIC=y
> CONFIG_SPLIT_PTLOCK_CPUS=4
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
> CONFIG_MTRR=y
> CONFIG_X86_PAT=y
> CONFIG_ARCH_USES_PG_UNCACHED=y
> CONFIG_HZ_1000=y
> CONFIG_HZ=1000
> CONFIG_PHYSICAL_START=0x1000000
> CONFIG_PHYSICAL_ALIGN=0x1000000
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> CONFIG_PCI=y
> CONFIG_PCI_GOANY=y
> CONFIG_PCI_BIOS=y
> CONFIG_PCI_DIRECT=y
> CONFIG_PCI_DOMAINS=y
> CONFIG_ISA_DMA_API=y
> CONFIG_K8_NB=y
> CONFIG_BINFMT_ELF=y
> CONFIG_HAVE_AOUT=y
> CONFIG_HAVE_ATOMIC_IOMAP=y
> CONFIG_NET=y
> CONFIG_UNIX=y
> CONFIG_INET=y
> CONFIG_IP_FIB_HASH=y
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_DEFAULT_TCP_CONG="cubic"
> CONFIG_IPV6=y
> CONFIG_UEVENT_HELPER_PATH=""
> CONFIG_DEVTMPFS=y
> CONFIG_DEVTMPFS_MOUNT=y
> CONFIG_PREVENT_FIRMWARE_BUILD=y
> CONFIG_FW_LOADER=y
> CONFIG_EXTRA_FIRMWARE=""
> CONFIG_HAVE_IDE=y
> CONFIG_SCSI_MOD=y
> CONFIG_NETDEVICES=y
> CONFIG_VETH=y
> CONFIG_INPUT=y
> CONFIG_INPUT_MOUSEDEV=y
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=576
> CONFIG_INPUT_KEYBOARD=y
> CONFIG_KEYBOARD_ATKBD=y
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> CONFIG_SERIO_LIBPS2=y
> CONFIG_VT=y
> CONFIG_CONSOLE_TRANSLATIONS=y
> CONFIG_VT_CONSOLE=y
> CONFIG_HW_CONSOLE=y
> CONFIG_FIX_EARLYCON_MEM=y
> CONFIG_UNIX98_PTYS=y
> CONFIG_DEVPORT=y
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
> CONFIG_SSB_POSSIBLE=y
> CONFIG_VGA_ARB=y
> CONFIG_VGA_ARB_MAX_GPUS=16
> CONFIG_VGA_CONSOLE=y
> CONFIG_VGACON_SOFT_SCROLLBACK=y
> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
> CONFIG_DUMMY_CONSOLE=y
> CONFIG_FIRMWARE_MEMMAP=y
> CONFIG_FILE_LOCKING=y
> CONFIG_PROC_FS=y
> CONFIG_PROC_SYSCTL=y
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SYSFS=y
> CONFIG_MSDOS_PARTITION=y
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> CONFIG_FRAME_WARN=2048
> CONFIG_DEBUG_BUGVERBOSE=y
> CONFIG_DEBUG_MEMORY_INIT=y
> CONFIG_ARCH_WANT_FRAME_POINTERS=y
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> CONFIG_TRACING_SUPPORT=y
> CONFIG_HAVE_ARCH_KGDB=y
> CONFIG_HAVE_ARCH_KMEMCHECK=y
> CONFIG_EARLY_PRINTK=y
> CONFIG_DOUBLEFAULT=y
> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> CONFIG_IO_DELAY_0X80=y
> CONFIG_DEFAULT_IO_DELAY_TYPE=0
> CONFIG_DEFAULT_SECURITY_DAC=y
> CONFIG_DEFAULT_SECURITY=""
> CONFIG_HAVE_KVM=y
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_FIND_NEXT_BIT=y
> CONFIG_GENERIC_FIND_LAST_BIT=y
> CONFIG_ZLIB_INFLATE=y
> CONFIG_LZO_DECOMPRESS=y
> CONFIG_DECOMPRESS_GZIP=y
> CONFIG_DECOMPRESS_BZIP2=y
> CONFIG_DECOMPRESS_LZMA=y
> CONFIG_DECOMPRESS_LZO=y
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
> CONFIG_NLATTR=y
>

Hi,

curiously, i'm facing a similar problem in 2.6.36.1

in my container, when i configure ipv6 adress on the interfaces, 
everything seems good on the first boot of the host. If i shutdown my 
container (lxc), then boot it, i observe the following logs:
Dec  6 17:04:12 suntory.u06.univ-nantes.prive kernel: [  368.192019] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:04:22 suntory.u06.univ-nantes.prive kernel: [  378.432018] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:04:32 suntory.u06.univ-nantes.prive kernel: [  388.672015] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:04:42 suntory.u06.univ-nantes.prive kernel: [  398.912016] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:04:53 suntory.u06.univ-nantes.prive kernel: [  409.152016] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:03 suntory.u06.univ-nantes.prive kernel: [  419.392018] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:13 suntory.u06.univ-nantes.prive kernel: [  429.632018] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:23 suntory.u06.univ-nantes.prive kernel: [  439.876016] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:34 suntory.u06.univ-nantes.prive kernel: [  450.116015] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:44 suntory.u06.univ-nantes.prive kernel: [  460.356019] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:05:54 suntory.u06.univ-nantes.prive kernel: [  470.596020] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:06:04 suntory.u06.univ-nantes.prive kernel: [  480.836019] 
unregister_netdevice: waiting for lo to become free. Usage count = 4
Dec  6 17:06:05 suntory.u06.univ-nantes.prive kernel: [  481.468021] 
INFO: task lxc-start:3805 blocked for more than 120 seconds.

Then i must reboot the host.
The same on kernel 2.6.34, but everything is good on a 2.6.32

Some relvant informations about the kernel:
root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i sysfs
# CONFIG_SYSFS_DEPRECATED_V2 is not set
CONFIG_ACPI_SYSFS_POWER=y
# CONFIG_WIRELESS_EXT_SYSFS is not set
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_RTC_INTF_SYSFS=y
CONFIG_SYSFS=y
root@suntory:~# cat /boot/config-2.6.36.1-dsiun-1d | grep -i net_ns
CONFIG_NET_NS=y

Is there anything in my configuration, i must check in order to get ipv6 
working fully in the container?

Regards.

--------------080504030802060008020209
Content-Type: text/x-vcard; charset=utf-8;
 name="jean-philippe_menil.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="jean-philippe_menil.vcf"

begin:vcard
fn:Jean-Philippe Menil
n:Menil;Jean-Philippe
org;quoted-printable:Universit=C3=A9 de Nantes;IRTS
adr;quoted-printable:;;2 rue de la Houssini=C3=A8re;Nantes;;44322;France
email;internet:jean-philippe.menil@univ-nantes.fr
title:Reseau
tel;work:02 53 48 49 27
tel;fax:(33)2 51 12 58 60 
tel;cell:06 45 38 87 75
url:http://www.cri.univ-nantes.fr
version:2.1
end:vcard


--------------080504030802060008020209--
