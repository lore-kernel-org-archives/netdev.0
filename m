From: Brad Campbell <brad@wasp.net.au>
Subject: 2.6.28-rc8-git3 forcedeth WARNING (kills the interface)
Date: Thu, 03 Jul 2008 14:07:39 +0400
Message-ID: <486CA4EB.1040804@wasp.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wasp.net.au ([203.190.192.17]:59590 "EHLO wasp.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbYGCL57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 07:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

G'day all,
Same problem I reported in -rc7.

This is a vanilla kernel with the addition of the imq and adt7475 
modules. imq is not relevant here as I only added it this morning and 
this has been going on all week.

[1.] One line summary of the problem:

Ethernet interface stops passing traffic (so does a good pair of legs, 
but that's not important right now).

[2.] Full description of the problem/report:

After an indeterminate period of time, the network interface simply 
stops responding to any traffic.

An ifdown ; ifup will bring it back to life.

This is a dual interface on an MPC55 chipset. Only eth1 seems to suffer 
from this particular problem.

root@srv:~# ethtool eth0
Settings for eth0:
    Supported ports: [ MII ]
    Supported link modes:   10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Full
    Supports auto-negotiation: Yes
    Advertised link modes:  10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Full
    Advertised auto-negotiation: Yes
    Speed: 1000Mb/s
    Duplex: Full
    Port: MII
    PHYAD: 1
    Transceiver: external
    Auto-negotiation: on
    Supports Wake-on: g
    Wake-on: d
    Link detected: yes
root@srv:~# ethtool eth1
Settings for eth1:
    Supported ports: [ MII ]
    Supported link modes:   10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Full
    Supports auto-negotiation: Yes
    Advertised link modes:  10baseT/Half 10baseT/Full
                            100baseT/Half 100baseT/Full
                            1000baseT/Full
    Advertised auto-negotiation: Yes
    Speed: 100Mb/s
    Duplex: Full
    Port: MII
    PHYAD: 1
    Transceiver: external
    Auto-negotiation: on
    Supports Wake-on: g
    Wake-on: d
    Link detected: yes

eth0 gets bucketloads of these -->

Jul  2 19:34:13 srv kernel: [896280.326998] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:13 srv kernel: [896280.661227] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:14 srv kernel: [896281.765119] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:17 srv kernel: [896284.434394] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:17 srv kernel: [896284.683543] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:18 srv kernel: [896285.459628] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:19 srv kernel: [896286.162198] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:19 srv kernel: [896286.508541] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:19 srv kernel: [896286.877555] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:20 srv kernel: [896287.267308] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:20 srv kernel: [896287.339097] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:20 srv kernel: [896287.419509] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:20 srv kernel: [896287.572999] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:20 srv kernel: [896287.783227] eth0: too many iterations 
(6) in nv_nic_irq.
Jul  2 19:34:21 srv kernel: [896287.971101] eth0: too many iterations 
(6) in nv_nic_irq.

.. But that is an entirely different kettle of fish and does not stop me 
functioning.

[3.] Keywords (i.e., modules, networking, kernel):

networking, kernel

[4.] Kernel information
[4.1.] Kernel version (from /proc/version):

Linux version 2.6.26-rc8-git3 (brad@srv) (gcc version 4.1.2 20061115 
(prerelease) (Debian 4.1.1-21)) #4 SMP Thu Jul 3 11:55:41 GST 2008

[4.2.] Kernel .config file:

brad@srv:~$ zcat /proc/config.gz | awk '{if (($0 !~ /^#/) && (NF != 0) ) 
print $0}'
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_AOUT=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
CONFIG_NAMESPACES=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_SYSCTL=y
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_SLUB=y
CONFIG_HAVE_OPROFILE=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_KMOD=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLOCK_COMPAT=y
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_CLASSIC_RCU=y
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_PC=y
CONFIG_MEMTEST_BOOTPARAM=y
CONFIG_MEMTEST_BOOTPARAM_VALUE=0
CONFIG_MK8=y
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=8
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_AMD=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MTRR=y
CONFIG_X86_PAT=y
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_PHYSICAL_START=0x200000
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_PM=y
CONFIG_ACPI=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_POWERNOW_K8_ACPI=y
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIEASPM=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_HT_IRQ=y
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_BINFMT_MISC=m
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=m
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_FIB_HASH=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CT_ACCT=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CT_PROTO_DCCP=m
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=m
CONFIG_NF_CT_PROTO_UDPLITE=m
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NETFILTER_XTABLES=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_RECENT=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_MATCH_ADDRTYPE=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_IMQ=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_DCCP=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PROTO_UDPLITE=m
CONFIG_NF_NAT_PROTO_SCTP=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m
CONFIG_IP_SCTP=m
CONFIG_SCTP_HMAC_MD5=y
CONFIG_NET_SCHED=y
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_ROUTE=y
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_SCH_FIFO=y
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=m
CONFIG_PNP=y
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_HAVE_IDE=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_PROC_FS=y
CONFIG_BLK_DEV_SD=y
CONFIG_BLK_DEV_SR=y
CONFIG_CHR_DEV_SG=y
CONFIG_SCSI_WAIT_SCAN=m
CONFIG_ATA=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
CONFIG_SATA_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_RAID5_RESHAPE=y
CONFIG_NETDEVICES=y
CONFIG_DUMMY=m
CONFIG_IMQ=m
CONFIG_IMQ_BEHAVIOR_AB=y
CONFIG_IMQ_NUM_DEVS=16
CONFIG_TUN=y
CONFIG_NET_ETHERNET=y
CONFIG_NET_PCI=y
CONFIG_FORCEDETH=m
CONFIG_FORCEDETH_NAPI=y
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
CONFIG_PPPOL2TP=m
CONFIG_SLHC=m
CONFIG_INPUT=y
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_LIBPS2=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_RTC=y
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_NFORCE2=m
CONFIG_POWER_SUPPLY=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_THERMAL=y
CONFIG_SSB_POSSIBLE=y
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_VGASTATE=y
CONFIG_FB=y
CONFIG_FB_DDC=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_VGA_CONSOLE=y
CONFIG_VIDEO_SELECT=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
CONFIG_HIDRAW=y
CONFIG_USB_HID=m
CONFIG_USB_HIDDEV=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=m
CONFIG_USB_DEVICEFS=y
CONFIG_USB_DEVICE_CLASS=y
CONFIG_USB_SUSPEND=y
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_ACM=m
CONFIG_USB_STORAGE=m
CONFIG_USB_LIBUSUAL=y
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_DMIID=y
CONFIG_EXT2_FS=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_JBD=y
CONFIG_FS_MBCACHE=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=m
CONFIG_PROC_FS=y
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_CONFIGFS_FS=m
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_MSDOS_PARTITION=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_ISO8859_1=y
CONFIG_DLM=m
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DETECT_SOFTLOCKUP=y
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_EARLY_PRINTK=y
CONFIG_X86_MPPARSE=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_CRYPTO=m
CONFIG_CRYPTO_ALGAPI=m
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_HASH=m
CONFIG_CRYPTO_MANAGER=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_HMAC=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_DES=m
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_AMD=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_CRC_CCITT=m
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_LIBCRC32C=m
CONFIG_ZLIB_INFLATE=m
CONFIG_ZLIB_DEFLATE=m
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

[5.] Most recent kernel version which did not have the bug:

Don't know. I need a .26 kernel to survive a particular SATA error and 
this is a brand new machine for me, so it's never run anything older.

[6.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)

[ 2936.865224] ------------[ cut here ]------------
[ 2936.865224] WARNING: at net/sched/sch_generic.c:223 
dev_watchdog+0xf5/0x110()
[ 2936.865224] Modules linked in: xt_iprange xt_length xt_CLASSIFY 
sch_sfq sch_htb iptable_mangle xt_TCPMSS ipt_REJECT xt_state 
ipt_MASQUERADE ipt_REDIRECT xt_tcpudp iptable_filter iptable_nat nf_nat 
nf_conntrack_ipv4 nf_conntrack ip_tables x_tables adt7475 it87 hwmon_vid 
powernow_k8 k8temp cdc_acm i2c_nforce2 usbhid sata_sil sata_promise 
forcedeth ehci_hcd ohci_hcd sata_nv usbcore
[ 2936.865224] Pid: 13602, comm: rrdtool Not tainted 2.6.26-rc8-git3 #4
[ 2936.865224]
[ 2936.865224] Call Trace:
[ 2936.865224]  <IRQ>  [<ffffffff802338e4>] warn_on_slowpath+0x64/0xa0
[ 2936.865224]  [<ffffffffa0046198>] :forcedeth:reg_delay+0x58/0xb0
[ 2936.865224]  [<ffffffffa0046fb6>] :forcedeth:nv_drain_tx+0xb6/0x1a0
[ 2936.865224]  [<ffffffffa004504a>] :forcedeth:setup_hw_rings+0x2a/0x100
[ 2936.865224]  [<ffffffffa00492e7>] :forcedeth:nv_tx_timeout+0x287/0x2c0
[ 2936.865224]  [<ffffffff80463ce5>] dev_watchdog+0xf5/0x110
[ 2936.865224]  [<ffffffff8023d1b2>] run_timer_softirq+0x192/0x200
[ 2936.865224]  [<ffffffff802391a9>] __do_softirq+0x69/0xe0
[ 2936.865224]  [<ffffffff8020c61c>] call_softirq+0x1c/0x30
[ 2936.865224]  [<ffffffff8020eb85>] do_softirq+0x35/0x70
[ 2936.865224]  [<ffffffff80239137>] irq_exit+0x87/0x90
[ 2936.865224]  [<ffffffff8021b5fc>] smp_apic_timer_interrupt+0x7c/0xc0
[ 2936.865224]  [<ffffffff8020c0c6>] apic_timer_interrupt+0x66/0x70
[ 2936.865224]  <EOI>
[ 2936.865224] ---[ end trace 6e6bcab61ac567c9 ]---


[7.] A small shell script or example program which triggers the
     problem (if possible)

Not easily triggerable. Might happen 20 times in and hour and then not 
for 2 days.

[8.] Environment
[8.1.] Software (add the output of the ver_linux script here)

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux srv 2.6.26-rc8-git3 #4 SMP Thu Jul 3 11:55:41 GST 2008 x86_64 
GNU/Linux
 
Gnu C                  4.1.2
Gnu make               3.81
binutils               2.17
util-linux             2.12r
mount                  2.12r
module-init-tools      3.3-pre2
e2fsprogs              1.40-WIP
Linux C Library        2.3.6
Dynamic linker (ldd)   2.3.6
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   105
Modules Loaded         xt_iprange xt_length xt_CLASSIFY sch_sfq sch_htb 
iptable_mangle xt_TCPMSS ipt_REJECT xt_state ipt_MASQUERADE ipt_REDIRECT 
xt_tcpudp iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 
nf_conntrack ip_tables x_tables adt7475 it87 hwmon_vid powernow_k8 
k8temp cdc_acm i2c_nforce2 usbhid sata_sil sata_promise forcedeth 
ehci_hcd ohci_hcd sata_nv usbcore

[8.2.] Processor information (from /proc/cpuinfo):

processor    : 0
vendor_id    : AuthenticAMD
cpu family    : 15
model        : 75
model name    : AMD Athlon(tm) 64 X2 Dual Core Processor 3800+
stepping    : 2
cpu MHz        : 1000.000
cache size    : 512 KB
physical id    : 0
siblings    : 2
core id        : 0
cpu cores    : 2
apicid        : 0
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 1
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt 
rdtscp lm 3dnowext 3dnow rep_good pni cx16 lahf_lm cmp_legacy svm 
extapic cr8_legacy
bogomips    : 2010.58
TLB size    : 1024 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp tm stc

processor    : 1
vendor_id    : AuthenticAMD
cpu family    : 15
model        : 75
model name    : AMD Athlon(tm) 64 X2 Dual Core Processor 3800+
stepping    : 2
cpu MHz        : 1000.000
cache size    : 512 KB
physical id    : 0
siblings    : 2
core id        : 1
cpu cores    : 2
apicid        : 1
initial apicid    : 1
fpu        : yes
fpu_exception    : yes
cpuid level    : 1
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt 
rdtscp lm 3dnowext 3dnow rep_good pni cx16 lahf_lm cmp_legacy svm 
extapic cr8_legacy
bogomips    : 2010.58
TLB size    : 1024 4K pages
clflush size    : 64
cache_alignment    : 64
address sizes    : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp tm stc


[8.3.] Module information (from /proc/modules):

xt_iprange 3392 1 - Live 0xffffffffa00cb000
xt_length 2752 1 - Live 0xffffffffa00c9000
xt_CLASSIFY 2624 20 - Live 0xffffffffa00c7000
sch_sfq 7744 4 - Live 0xffffffffa00c4000
sch_htb 17472 1 - Live 0xffffffffa00be000
iptable_mangle 4032 1 - Live 0xffffffffa0061000
xt_TCPMSS 4352 1 - Live 0xffffffffa00bb000
ipt_REJECT 4160 1 - Live 0xffffffffa00b8000
xt_state 3072 3 - Live 0xffffffffa005b000
ipt_MASQUERADE 3904 2 - Live 0xffffffffa0054000
ipt_REDIRECT 2624 3 - Live 0xffffffffa0043000
xt_tcpudp 4224 35 - Live 0xffffffffa00b5000
iptable_filter 3968 1 - Live 0xffffffffa0030000
iptable_nat 6032 1 - Live 0xffffffffa00b2000
nf_nat 19032 3 ipt_MASQUERADE,ipt_REDIRECT,iptable_nat, Live 
0xffffffffa00ac000
nf_conntrack_ipv4 16344 6 iptable_nat,nf_nat, Live 0xffffffffa00a7000
nf_conntrack 58480 5 
xt_state,ipt_MASQUERADE,iptable_nat,nf_nat,nf_conntrack_ipv4, Live 
0xffffffffa0097000
ip_tables 18960 3 iptable_mangle,iptable_filter,iptable_nat, Live 
0xffffffffa0091000
x_tables 19656 11 
xt_iprange,xt_length,xt_CLASSIFY,xt_TCPMSS,ipt_REJECT,xt_state,ipt_MASQUERADE,ipt_REDIRECT,xt_tcpudp,iptable_nat,ip_tables, 
Live 0xffffffffa008b000
adt7475 20496 0 - Live 0xffffffffa0084000
it87 26968 0 - Live 0xffffffffa007c000
hwmon_vid 4096 1 it87, Live 0xffffffffa0026000
powernow_k8 14404 1 - Live 0xffffffffa0077000
k8temp 5760 0 - Live 0xffffffffa0074000
cdc_acm 16352 2 - Live 0xffffffffa006f000
i2c_nforce2 7616 0 - Live 0xffffffffa006c000
usbhid 30176 1 - Live 0xffffffffa0063000
sata_sil 10056 2 - Live 0xffffffffa005d000
sata_promise 13956 8 - Live 0xffffffffa0056000
forcedeth 54736 0 - Live 0xffffffffa0045000
ehci_hcd 35724 0 - Live 0xffffffffa0039000
ohci_hcd 23364 0 - Live 0xffffffffa0032000
sata_nv 25736 11 - Live 0xffffffffa0028000
usbcore 147864 6 cdc_acm,usbhid,ehci_hcd,ohci_hcd, Live 0xffffffffa0000000

[8.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)

0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-0060 : keyboard
0064-0064 : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : 0000:00:0c.0
01f0-01f7 : 0000:00:0c.0
0290-0297 : pnp 00:02
  0295-0296 : it87
    0295-0296 : it87
0376-0376 : 0000:00:0c.0
03c0-03df : vga+
03f6-03f6 : 0000:00:0c.0
03f8-03ff : serial
04d0-04d1 : pnp 00:02
0800-087f : pnp 00:02
0960-0967 : 0000:00:0d.1
  0960-0967 : sata_nv
0970-0977 : 0000:00:0d.0
  0970-0977 : sata_nv
09e0-09e7 : 0000:00:0d.1
  09e0-09e7 : sata_nv
09f0-09f7 : 0000:00:0d.0
  09f0-09f7 : sata_nv
0b60-0b63 : 0000:00:0d.1
  0b60-0b63 : sata_nv
0b70-0b73 : 0000:00:0d.0
  0b70-0b73 : sata_nv
0be0-0be3 : 0000:00:0d.1
  0be0-0be3 : sata_nv
0bf0-0bf3 : 0000:00:0d.0
  0bf0-0bf3 : sata_nv
0cf8-0cff : PCI conf1
1000-107f : pnp 00:01
  1000-1003 : ACPI PM1a_EVT_BLK
  1004-1005 : ACPI PM1a_CNT_BLK
  1008-100b : ACPI PM_TMR
  101c-101c : ACPI PM2_CNT_BLK
  1020-1027 : ACPI GPE0_BLK
1080-10ff : pnp 00:01
1400-147f : pnp 00:01
1480-14ff : pnp 00:01
  14a0-14af : ACPI GPE1_BLK
1800-187f : pnp 00:01
1880-18ff : pnp 00:01
1c00-1c3f : 0000:00:09.1
  1c00-1c3f : nForce2_smbus
1c40-1c7f : 0000:00:09.1
  1c40-1c7f : nForce2_smbus
7000-7fff : PCI Bus 0000:08
  7000-701f : 0000:08:00.0
  7400-743f : 0000:08:00.0
  7800-7803 : 0000:08:00.0
  7c00-7c07 : 0000:08:00.0
8000-9fff : PCI Bus 0000:03
  8000-9fff : PCI Bus 0000:04
    8000-807f : 0000:04:02.0
    8400-840f : 0000:04:02.0
    8800-883f : 0000:04:02.0
    8c00-8c0f : 0000:04:01.0
    9000-9003 : 0000:04:01.0
    9400-9407 : 0000:04:01.0
    9800-9803 : 0000:04:01.0
    9c00-9c07 : 0000:04:01.0
a000-afff : PCI Bus 0000:02
  a400-a47f : 0000:02:06.0
  a800-a80f : 0000:02:06.0
  ac00-ac3f : 0000:02:06.0
b000-b007 : 0000:00:11.0
  b000-b007 : forcedeth
b400-b407 : 0000:00:10.0
  b400-b407 : forcedeth
b800-b80f : 0000:00:0d.2
  b800-b80f : sata_nv
bc00-bc03 : 0000:00:0d.2
  bc00-bc03 : sata_nv
c000-c007 : 0000:00:0d.2
  c000-c007 : sata_nv
c400-c403 : 0000:00:0d.2
  c400-c403 : sata_nv
c800-c807 : 0000:00:0d.2
  c800-c807 : sata_nv
cc00-cc0f : 0000:00:0d.1
  cc00-cc0f : sata_nv
e000-e00f : 0000:00:0d.0
  e000-e00f : sata_nv
f400-f40f : 0000:00:0c.0


00000000-0009d3ff : System RAM
0009d400-0009ffff : reserved
000d8400-000dbfff : pnp 00:0b
000f0000-000fffff : reserved
00100000-dfeaffff : System RAM
  00200000-004d4a15 : Kernel code
  004d4a16-00637d3f : Kernel data
  006a4000-007fbdc7 : Kernel bss
  04000000-07ffffff : GART
dfeb0000-dfee2fff : ACPI Non-volatile Storage
dfee3000-dfeeffff : ACPI Tables
dfef0000-dfefffff : reserved
e0000000-efffffff : PCI Bus 0000:01
  e0000000-efffffff : 0000:01:00.0
    e0000000-efffffff : nvidiafb
f0000000-f3ffffff : PCI MMCONFIG 0
  f0000000-f3ffffff : reserved
f4000000-f40fffff : PCI Bus 0000:02
  f4000000-f4003fff : 0000:02:06.0
f4100000-f41fffff : PCI Bus 0000:03
  f4100000-f41fffff : PCI Bus 0000:04
    f4100000-f4103fff : 0000:04:02.0
fa000000-fcffffff : PCI Bus 0000:01
  fa000000-faffffff : 0000:01:00.0
    fa000000-faffffff : nvidiafb
  fb000000-fbffffff : 0000:01:00.0
    fb000000-fbffffff : nvidiafb
  fcfe0000-fcffffff : 0000:01:00.0
fdc00000-fdcfffff : PCI Bus 0000:08
  fdc80000-fdcbffff : 0000:08:00.0
  fdcff000-fdcff3ff : 0000:08:00.0
fdd00000-fdefffff : PCI Bus 0000:03
  fdd00000-fddfffff : PCI Bus 0000:04
    fdd00000-fdd7ffff : 0000:04:01.0
    fddc0000-fdddffff : 0000:04:02.0
    fddfe000-fddfefff : 0000:04:02.0
      fddfe000-fddfefff : sata_promise
    fddff000-fddff1ff : 0000:04:01.0
      fddff000-fddff1ff : sata_sil
  fdeff000-fdeff07f : 0000:03:00.1
fdf00000-fdffffff : PCI Bus 0000:02
  fdfc0000-fdfdffff : 0000:02:06.0
  fdff8000-fdffbfff : 0000:02:0b.0
  fdffe000-fdffe7ff : 0000:02:0b.0
  fdfff000-fdffffff : 0000:02:06.0
    fdfff000-fdffffff : sata_promise
fe020000-fe023fff : 0000:00:0e.1
fe025000-fe02500f : 0000:00:11.0
  fe025000-fe02500f : forcedeth
fe026000-fe0260ff : 0000:00:11.0
  fe026000-fe0260ff : forcedeth
fe027000-fe027fff : 0000:00:11.0
  fe027000-fe027fff : forcedeth
fe028000-fe02800f : 0000:00:10.0
  fe028000-fe02800f : forcedeth
fe029000-fe0290ff : 0000:00:10.0
  fe029000-fe0290ff : forcedeth
fe02a000-fe02afff : 0000:00:10.0
  fe02a000-fe02afff : forcedeth
fe02b000-fe02bfff : 0000:00:0d.2
  fe02b000-fe02bfff : sata_nv
fe02c000-fe02cfff : 0000:00:0d.1
  fe02c000-fe02cfff : sata_nv
fe02d000-fe02dfff : 0000:00:0d.0
  fe02d000-fe02dfff : sata_nv
fe02e000-fe02e0ff : 0000:00:0a.1
  fe02e000-fe02e0ff : ehci_hcd
fe02f000-fe02ffff : 0000:00:0a.0
  fe02f000-fe02ffff : ohci_hcd
fec00000-ffffffff : reserved
  fec00000-fec00fff : IOAPIC 0
  fee00000-fee00fff : Local APIC
  fefff000-fefff3ff : HPET 0
100000000-11fffffff : System RAM

[8.5.] PCI information ('lspci -vvv' as root)

00:00.0 RAM memory: nVidia Corporation C51 Host Bridge (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0
    Capabilities: [44] HyperTransport: Slave or Primary Interface
        Command: BaseUnitID=0 UnitCnt=15 MastHost- DefDir- DUL-
        Link Control 0: CFlE+ CST- CFE- <LkFail- Init+ EOC- TXO- 
<CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
        Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit 
DwFcInEn- LWO=16bit DwFcOutEn-
        Link Control 1: CFlE+ CST- CFE- <LkFail- Init+ EOC- TXO- 
<CRCErr=0 IsocEn+ LSEn+ ExtCTL- 64b-
        Link Config 1: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit 
DwFcInEn- LWO=16bit DwFcOutEn-
        Revision ID: 1.03
        Link Frequency 0: 1.0GHz
        Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
        Link Frequency Capability 0: 200MHz+ 300MHz+ 400MHz+ 500MHz+ 
600MHz+ 800MHz+ 1.0GHz+ 1.2GHz- 1.4GHz- 1.6GHz- Vend-
        Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD-
        Link Frequency 1: 1.0GHz
        Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
        Link Frequency Capability 1: 200MHz+ 300MHz+ 400MHz+ 500MHz+ 
600MHz+ 800MHz+ 1.0GHz+ 1.2GHz- 1.4GHz- 1.6GHz- Vend-
        Error Handling: PFlE+ OFlE+ PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- 
CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
        Prefetchable memory behind bridge Upper: 00-00
        Bus Number: 00
    Capabilities: [e0] HyperTransport: MSI Mapping

00:00.1 RAM memory: nVidia Corporation C51 Memory Controller 0 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR+ <PERR-

00:00.2 RAM memory: nVidia Corporation C51 Memory Controller 1 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:00.3 RAM memory: nVidia Corporation C51 Memory Controller 5 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:00.4 RAM memory: nVidia Corporation C51 Memory Controller 4 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0

00:00.5 RAM memory: nVidia Corporation C51 Host Bridge (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0
    Capabilities: [44] #00 [0000]

00:00.6 RAM memory: nVidia Corporation C51 Memory Controller 3 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:00.7 RAM memory: nVidia Corporation C51 Memory Controller 2 (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fc
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:04.0 PCI bridge: nVidia Corporation C51 PCI Express Bridge (rev a1) 
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fa000000-fcffffff
    Prefetchable memory behind bridge: 00000000e0000000-00000000efffffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4151
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
        Link: Speed 2.5Gb/s, Width x16
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:08.0 RAM memory: nVidia Corporation MCP55 Memory Controller (rev a1)
    Subsystem: nVidia Corporation Unknown device cb84
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0
    Capabilities: [44] HyperTransport: Slave or Primary Interface
        Command: BaseUnitID=8 UnitCnt=15 MastHost- DefDir- DUL-
        Link Control 0: CFlE+ CST- CFE- <LkFail- Init+ EOC- TXO- 
<CRCErr=0 IsocEn+ LSEn+ ExtCTL- 64b-
        Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit 
DwFcInEn- LWO=16bit DwFcOutEn-
        Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ 
<CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
        Link Config 1: MLWI=8bit DwFcIn- MLWO=8bit DwFcOut- LWI=8bit 
DwFcInEn- LWO=8bit DwFcOutEn-
        Revision ID: 1.03
        Link Frequency 0: 1.0GHz
        Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
        Link Frequency Capability 0: 200MHz+ 300MHz+ 400MHz+ 500MHz+ 
600MHz+ 800MHz+ 1.0GHz+ 1.2GHz- 1.4GHz- 1.6GHz- Vend-
        Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD-
        Link Frequency 1: 200MHz
        Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
        Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 
600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
        Error Handling: PFlE+ OFlE+ PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- 
CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
        Prefetchable memory behind bridge Upper: 00-00
        Bus Number: 00
    Capabilities: [e0] #00 [fee0]

00:09.0 ISA bridge: nVidia Corporation MCP55 LPC Bridge (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0

00:09.1 SMBus: nVidia Corporation MCP55 SMBus (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Interrupt: pin A routed to IRQ 10
    Region 4: I/O ports at 1c00 [size=64]
    Region 5: I/O ports at 1c40 [size=64]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:0a.0 USB Controller: nVidia Corporation MCP55 USB Controller (rev a1) 
(prog-if 10 [OHCI])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Interrupt: pin A routed to IRQ 20
    Region 0: Memory at fe02f000 (32-bit, non-prefetchable) [size=4K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:0a.1 USB Controller: nVidia Corporation MCP55 USB Controller (rev a2) 
(prog-if 20 [EHCI])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Interrupt: pin B routed to IRQ 23
    Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=256]
    Capabilities: [44] Debug port
    Capabilities: [80] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME+

00:0c.0 IDE interface: nVidia Corporation MCP55 IDE (rev a1) (prog-if 8a 
[Master SecP PriP])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) 
[disabled] [size=8]
    Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) 
[disabled] [size=1]
    Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) 
[disabled] [size=8]
    Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) 
[disabled] [size=1]
    Region 4: I/O ports at f400 [size=16]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:0d.0 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) 
(prog-if 85 [Master SecO PriO])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Interrupt: pin A routed to IRQ 23
    Region 0: I/O ports at 09f0 [size=8]
    Region 1: I/O ports at 0bf0 [size=4]
    Region 2: I/O ports at 0970 [size=8]
    Region 3: I/O ports at 0b70 [size=4]
    Region 4: I/O ports at e000 [size=16]
    Region 5: Memory at fe02d000 (32-bit, non-prefetchable) [size=4K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/2 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [cc] HyperTransport: MSI Mapping

00:0d.1 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) 
(prog-if 85 [Master SecO PriO])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Interrupt: pin B routed to IRQ 22
    Region 0: I/O ports at 09e0 [size=8]
    Region 1: I/O ports at 0be0 [size=4]
    Region 2: I/O ports at 0960 [size=8]
    Region 3: I/O ports at 0b60 [size=4]
    Region 4: I/O ports at cc00 [size=16]
    Region 5: Memory at fe02c000 (32-bit, non-prefetchable) [size=4K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/2 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [cc] HyperTransport: MSI Mapping

00:0d.2 IDE interface: nVidia Corporation MCP55 SATA Controller (rev a2) 
(prog-if 85 [Master SecO PriO])
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (750ns min, 250ns max)
    Interrupt: pin C routed to IRQ 21
    Region 0: I/O ports at c800 [size=8]
    Region 1: I/O ports at c400 [size=4]
    Region 2: I/O ports at c000 [size=8]
    Region 3: I/O ports at bc00 [size=4]
    Region 4: I/O ports at b800 [size=16]
    Region 5: Memory at fe02b000 (32-bit, non-prefetchable) [size=4K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [b0] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/2 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [cc] HyperTransport: MSI Mapping

00:0e.0 PCI bridge: nVidia Corporation MCP55 PCI bridge (rev a2) 
(prog-if 01 [Subtractive decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
    I/O behind bridge: 0000a000-0000afff
    Memory behind bridge: fdf00000-fdffffff
    Prefetchable memory behind bridge: f4000000-f40fffff
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [b8] Subsystem: nVidia Corporation Unknown device cb84
    Capabilities: [8c] HyperTransport: MSI Mapping

00:0e.1 Audio device: nVidia Corporation MCP55 High Definition Audio 
(rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81f6
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (500ns min, 1250ns max)
    Interrupt: pin B routed to IRQ 10
    Region 0: Memory at fe020000 (32-bit, non-prefetchable) [size=16K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
        Masking: 00000000  Pending: 00000000
    Capabilities: [6c] HyperTransport: MSI Mapping

00:10.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (250ns min, 5000ns max)
    Interrupt: pin A routed to IRQ 505
    Region 0: Memory at fe02a000 (32-bit, non-prefetchable) [size=4K]
    Region 1: I/O ports at b400 [size=8]
    Region 2: Memory at fe029000 (32-bit, non-prefetchable) [size=256]
    Region 3: Memory at fe028000 (32-bit, non-prefetchable) [size=16]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
    Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
        Vector table: BAR=2 offset=00000000
        PBA: BAR=3 offset=00000000
    Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
Queue=0/3 Enable+
        Address: 00000000fee0300c  Data: 41a1
        Masking: 000000fe  Pending: 00000000
    Capabilities: [6c] HyperTransport: MSI Mapping

00:11.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81fb
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (250ns min, 5000ns max)
    Interrupt: pin A routed to IRQ 504
    Region 0: Memory at fe027000 (32-bit, non-prefetchable) [size=4K]
    Region 1: I/O ports at b000 [size=8]
    Region 2: Memory at fe026000 (32-bit, non-prefetchable) [size=256]
    Region 3: Memory at fe025000 (32-bit, non-prefetchable) [size=16]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
    Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
        Vector table: BAR=2 offset=00000000
        PBA: BAR=3 offset=00000000
    Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
Queue=0/3 Enable+
        Address: 00000000fee0300c  Data: 41c1
        Masking: 000000fe  Pending: 00000000
    Capabilities: [6c] HyperTransport: MSI Mapping

00:12.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) 
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=03, subordinate=05, sec-latency=0
    I/O behind bridge: 00008000-00009fff
    Memory behind bridge: fdd00000-fdefffff
    Prefetchable memory behind bridge: 00000000f4100000-00000000f41fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4159
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s L1, Port 5
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x4
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:14.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) 
(prog-if 00 [Normal decode])
    Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4161
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x4
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:15.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) 
(prog-if 00 [Normal decode])
    Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4169
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x4
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:16.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) 
(prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=08, subordinate=08, sec-latency=0
    I/O behind bridge: 00007000-00007fff
    Memory behind bridge: fdc00000-fdcfffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4171
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 1
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
        Link: Speed 2.5Gb/s, Width x1
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:17.0 PCI bridge: nVidia Corporation MCP55 PCI Express bridge (rev a2) 
(prog-if 00 [Normal decode])
    Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Subsystem: nVidia Corporation Unknown device 0000
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/1 Enable+
        Address: 00000000fee0300c  Data: 4179
    Capabilities: [60] HyperTransport: MSI Mapping
    Capabilities: [80] Express Root Port (Slot+) IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <512ns, L1 <4us
        Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
        Link: Latency L0s <512ns, L1 <4us
        Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x16
        Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
        Slot: Number 0, PowerLimit 0.000000
        Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
        Slot: AttnInd Off, PwrInd On, Power-
        Root: Correctable- Non-Fatal- Fatal- PME-
    Capabilities: [100] Virtual Channel

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
HyperTransport Technology Configuration
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Capabilities: [80] HyperTransport: Host or Secondary Interface
        !!! Possibly incomplete decoding
        Command: WarmRst+ DblEnd-
        Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
        Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
        Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Address Map
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
DRAM Controller
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Miscellaneous Control
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Capabilities: [f0] #0f [0010]

01:00.0 VGA compatible controller: nVidia Corporation GeForce 7300 LE 
(rev a1) (prog-if 00 [VGA])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=16M]
    Region 1: Memory at e0000000 (64-bit, prefetchable) [size=256M]
    Region 3: Memory at fb000000 (64-bit, non-prefetchable) [size=16M]
    Expansion ROM at fcfe0000 [disabled] [size=128K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [68] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [78] Express Endpoint IRQ 0
        Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <256ns, L1 <4us
        Device: AtnBtn- AtnInd- PwrInd-
        Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
        Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
        Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
        Link: Latency L0s <256ns, L1 <4us
        Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
        Link: Speed 2.5Gb/s, Width x16
    Capabilities: [100] Virtual Channel
    Capabilities: [128] Power Budgeting

02:06.0 Mass storage controller: Promise Technology, Inc. PDC20318 
(SATA150 TX4) (rev 02)
    Subsystem: Promise Technology, Inc. PDC20318 (SATA150 TX4)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 96 (1000ns min, 4500ns max), Cache Line Size: 576 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: I/O ports at ac00 [size=64]
    Region 1: I/O ports at a800 [size=16]
    Region 2: I/O ports at a400 [size=128]
    Region 3: Memory at fdfff000 (32-bit, non-prefetchable) [size=4K]
    Region 4: Memory at fdfc0000 (32-bit, non-prefetchable) [size=128K]
    Expansion ROM at f4000000 [disabled] [size=16K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI+ D1+ D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

02:0b.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22/A 
IEEE-1394a-2000 Controller (PHY/Link) (prog-if 10 [OHCI])
    Subsystem: ASUSTeK Computer Inc. Unknown device 815b
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 32 (500ns min, 1000ns max), Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 10
    Region 0: Memory at fdffe000 (32-bit, non-prefetchable) [size=2K]
    Region 1: Memory at fdff8000 (32-bit, non-prefetchable) [size=16K]
    Capabilities: [44] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

03:00.0 PCI bridge: NEC Corporation uPD720400 PCI Express - PCI/PCI-X 
Bridge (rev 06) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Bus: primary=03, secondary=04, subordinate=04, sec-latency=32
    I/O behind bridge: 00008000-00009fff
    Memory behind bridge: fdd00000-fddfffff
    Prefetchable memory behind bridge: 00000000f4100000-00000000f41fffff
    Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=slow >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Express PCI/PCI-X Bridge IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <64ns, L1 <1us
        Device: AtnBtn- AtnInd- PwrInd-
        Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
        Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
        Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s L1, Port 0
        Link: Latency L0s <4us, L1 <16us
        Link: ASPM Disabled CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x4
    Capabilities: [54] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=conv
        Status: Dev=03:00.0 64bit- 133MHz- SCD- USC- SCO- SRD-
        Upstream: Capacity=32 CommitmentLimit=32
        Downstream: Capacity=16 CommitmentLimit=16
    Capabilities: [64] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2- AuxCurrent=55mA 
PME(D0+,D1+,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Bridge: PM- B3+
    Capabilities: [100] Advanced Error Reporting

03:00.1 PCI bridge: NEC Corporation uPD720400 PCI Express - PCI/PCI-X 
Bridge (rev 06) (prog-if 00 [Normal decode])
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0, Cache Line Size: 32 bytes
    Region 0: Memory at fdeff000 (64-bit, non-prefetchable) [size=128]
    Bus: primary=03, secondary=05, subordinate=05, sec-latency=32
    I/O behind bridge: 0000f000-00000fff
    Memory behind bridge: fff00000-000fffff
    Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
    Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=slow >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
    Capabilities: [40] Express PCI/PCI-X Bridge IRQ 0
        Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s <64ns, L1 <1us
        Device: AtnBtn- AtnInd- PwrInd-
        Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
        Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
        Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
        Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s L1, Port 0
        Link: Latency L0s <4us, L1 <16us
        Link: ASPM Disabled CommClk- ExtSynch-
        Link: Speed 2.5Gb/s, Width x4
    Capabilities: [54] PCI-X bridge device
        Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=conv
        Status: Dev=03:00.1 64bit- 133MHz- SCD- USC- SCO- SRD-
        Upstream: Capacity=32 CommitmentLimit=32
        Downstream: Capacity=16 CommitmentLimit=16
    Capabilities: [64] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2- AuxCurrent=55mA 
PME(D0+,D1+,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Bridge: PM- B3+
    Capabilities: [6c] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [7c] #0c [0000]
    Capabilities: [100] Advanced Error Reporting

04:01.0 Mass storage controller: Silicon Image, Inc. SiI 3112 
[SATALink/SATARaid] Serial ATA Controller (rev 02)
    Subsystem: Silicon Image, Inc. SiI 3112 SATALink Controller
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 32, Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: I/O ports at 9c00 [size=8]
    Region 1: I/O ports at 9800 [size=4]
    Region 2: I/O ports at 9400 [size=8]
    Region 3: I/O ports at 9000 [size=4]
    Region 4: I/O ports at 8c00 [size=16]
    Region 5: Memory at fddff000 (32-bit, non-prefetchable) [size=512]
    Expansion ROM at fdd00000 [disabled] [size=512K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=2 PME-

04:02.0 Mass storage controller: Promise Technology, Inc. PDC20318 
(SATA150 TX4) (rev 02)
    Subsystem: Promise Technology, Inc. PDC20318 (SATA150 TX4)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 96 (1000ns min, 4500ns max), Cache Line Size: 576 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: I/O ports at 8800 [size=64]
    Region 1: I/O ports at 8400 [size=16]
    Region 2: I/O ports at 8000 [size=128]
    Region 3: Memory at fddfe000 (32-bit, non-prefetchable) [size=4K]
    Region 4: Memory at fddc0000 (32-bit, non-prefetchable) [size=128K]
    Expansion ROM at f4100000 [disabled] [size=16K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI+ D1+ D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-

08:00.0 SATA controller: Marvell Technology Group Ltd. Unknown device 
6141 (rev 01) (prog-if 81)
    Subsystem: ASUSTeK Computer Inc. Unknown device 81d6
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
    Latency: 0 (2000ns min), Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 11
    Region 0: I/O ports at 7c00 [size=8]
    Region 1: I/O ports at 7800 [size=4]
    Region 2: I/O ports at 7400 [size=64]
    Region 4: I/O ports at 7000 [size=32]
    Region 5: Memory at fdcff000 (32-bit, non-prefetchable) [size=1K]
    Expansion ROM at fdc80000 [disabled] [size=256K]
    Capabilities: [48] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA 
PME(D0+,D1+,D2-,D3hot+,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- 
Queue=0/0 Enable-
        Address: 00000000  Data: 0000
    Capabilities: [e0] Express Legacy Endpoint IRQ 0
        Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
        Device: Latency L0s unlimited, L1 unlimited
        Device: AtnBtn- AtnInd- PwrInd-
        Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
        Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr+ NoSnoop-
        Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
        Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 1
        Link: Latency L0s <256ns, L1 unlimited
        Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
        Link: Speed 2.5Gb/s, Width x1
    Capabilities: [100] Advanced Error Reporting


[8.6.] SCSI information (from /proc/scsi/scsi)

Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi2 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: WDC WD7500AAKS-0 Rev: 30.0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi3 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: WDC WD7500AAKS-0 Rev: 30.0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi4 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: WDC WD7500AAKS-0 Rev: 30.0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi6 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi7 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi8 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi9 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi10 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi11 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi12 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: MAXTOR STM325031 Rev: 3.AA
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi13 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi14 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi15 Channel: 00 Id: 00 Lun: 00
  Vendor: ATA      Model: Maxtor 7Y250M0   Rev: YAR5
  Type:   Direct-Access                    ANSI  SCSI revision: 05

[8.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
:

[X.] Other notes, patches, fixes, workarounds:

I "work around it" with this betcherous hack which sits in a screen 
session from bootup.

cat brad@bklaptop2:~$ cat ifmonitor
#!/bin/bash

while true ; do
    ping -c1 -l3 192.168.254.2 > /dev/null ; res=$?
    if [ "$res" -eq 1 ] ; then
      /sbin/ifdown eth1
      /sbin/ifup eth1
      dmesg | tail > /tmp/argh-dmesg
      mail -s reset-interface root < /tmp/argh-dmesg
      echo
      echo Reset Interface `date`
    else
      echo -n .
    fi;
    sleep 2
done;



-- 
Dolphins are so intelligent that within a few weeks they can
train Americans to stand at the edge of the pool and throw them
fish.

