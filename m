From: Hubert Tonneau <hubert.tonneau@fullpliant.org>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Wed, 16 Feb 2005 20:00:29 GMT
Message-ID: <052EQ8T12@server5.heliogroup.fr>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: shemminger@osdl.org, romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru,
        niv@us.ibm.com, rick.jones2@hp.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>
> Hubert, do you have netfilter enabled in the 2.6.10 kernel you are running?
> 
> I'm asking because the TCP changes in 2.6.10 are pretty benign
> (attached for the curious who want to review along), whereas
> netfilter had major updates particularly in the TCP connection
> tracking code.

There is no netfilter on this server.

> I also reviewed 2.6.10-ac11 for anything interesting wrt. TCP and the
> only thing in there is the tcp_retrans_try_collapse() missing check
> to avoid collapsing TSO segments.

I'm using 2.6.10-ac11 for security reasons. I could use 2.6.10-as1 as well.
As far as I know, they all behave exactly the same from the TCP point of view.
The difference is definetly between stock 2.6.9 and stock 2.6.10

If it helps, you can send me a patch reverting TCP changes between 2.6.10
and 2.6.9, and I'll give it a spin, just to be sure that the problem is
truely related to TCP code, not other changes side effects.

Anyway, here is the set of settings I'm using to build the kernel, and no
module is loaded while the test is running:

CONFIG_2GB:  y
CONFIG_ACPI:  y
CONFIG_ACPI_AC:  m
CONFIG_ACPI_BATTERY:  m
CONFIG_ACPI_BUTTON:  m
CONFIG_ACPI_FAN:  m
CONFIG_ACPI_PROCESSOR:  y
CONFIG_ACPI_SLEEP:  y
CONFIG_ACPI_THERMAL:  y
CONFIG_ACPI_VIDEO:  m
CONFIG_APM_RTC_IS_GMT:  y
CONFIG_ATALK:  m
CONFIG_AUTODETECT_RAID:  y
CONFIG_AUTOFS_FS:  m
CONFIG_BINFMT_ELF:  y
CONFIG_BINFMT_MISC:  y
CONFIG_BLK_DEV_CMD640:  y
CONFIG_BLK_DEV_FD:  m
CONFIG_BLK_DEV_GENERIC:  y
CONFIG_BLK_DEV_IDE:  y
CONFIG_BLK_DEV_IDECD:  m
CONFIG_BLK_DEV_IDEDISK:  y
CONFIG_BLK_DEV_IDEDMA:  y
CONFIG_BLK_DEV_IDEDMA_PCI:  y
CONFIG_BLK_DEV_IDEPCI:  y
CONFIG_BLK_DEV_IDESCSI:  m
CONFIG_BLK_DEV_LOOP:  m
CONFIG_BLK_DEV_MD:  y
CONFIG_BLK_DEV_NBD:  m
CONFIG_BLK_DEV_PIIX:  y
CONFIG_BLK_DEV_RAM:  m
CONFIG_BLK_DEV_RZ1000:  y
CONFIG_BLK_DEV_SD:  y
CONFIG_BLK_DEV_SR:  m
CONFIG_BLK_DEV_TRIRON:  y
CONFIG_BSD_PROCESS_ACCT:  y
CONFIG_CHR_DEV_SG:  m
CONFIG_CHR_DEV_ST:  m
CONFIG_CODA_FS:  m
CONFIG_E1000:  y
CONFIG_EXPERIMENTAL:  y
CONFIG_EXT2_FS:  y
CONFIG_EXT3_FS:  y
CONFIG_EXT3_FS_XATTR:  y
CONFIG_FAT_FS:  m
CONFIG_FILTER:  y
CONFIG_FUSION:  y
CONFIG_FUSION_CTL:  m
CONFIG_FUSION_ISENSE:  m
CONFIG_FUSION_LAN:  m
CONFIG_HFSPLUS_FS:  m
CONFIG_HFS_FS:  m
CONFIG_HIGHMEM:  y
CONFIG_HIGHMEM4G:  y
CONFIG_HPET_TIMER:  y
CONFIG_HPFS_FS:  m
CONFIG_IDE:  y
CONFIG_IDEDMA_AUTO:  y
CONFIG_IDEDMA_ONLYDISK:  y
CONFIG_IDEDMA_PCI_AUTO:  y
CONFIG_IDEPCI_SHARE_IRQ:  y
CONFIG_IDE_GENERIC:  y
CONFIG_INET:  y
CONFIG_INPUT:  y
CONFIG_INPUT_KEYBDEV:  m
CONFIG_INPUT_KEYBOARD:  y
CONFIG_INPUT_MOUSE:  y
CONFIG_INPUT_MOUSEDEV:  m
CONFIG_IP_ALIAS:  y
CONFIG_IP_ROUTE_VERBOSE:  y
CONFIG_IRQBALANCE:  y
CONFIG_ISO9660_FS:  m
CONFIG_KCORE_ELF:  y
CONFIG_KEYBOARD_ATKBD:  y
CONFIG_LEGACY_PTYS:  y
CONFIG_LOCKD:  m
CONFIG_M386:  n
CONFIG_M486:  n
CONFIG_M586:  n
CONFIG_M686:  n
CONFIG_MAC_PARTITION:  y
CONFIG_MD:  y
CONFIG_MD_BOOT:  y
CONFIG_MD_LINEAR:  y
CONFIG_MD_LVM:  n
CONFIG_MD_MIRRORING:  y
CONFIG_MD_RAID0:  y
CONFIG_MD_RAID1:  y
CONFIG_MD_RAID5:  y
CONFIG_MD_STRIPED:  y
CONFIG_MD_TRANSLUCENT:  n
CONFIG_MODULES:  y
CONFIG_MODULE_UNLOAD:  y
CONFIG_MOUSE:  m
CONFIG_MOUSE_PS2:  y
CONFIG_MPENTIUM4:  y
CONFIG_MSDOS_FS:  m
CONFIG_MTRR:  y
CONFIG_NET:  y
CONFIG_NETDEVICES:  y
CONFIG_NET_ETHERNET:  y
CONFIG_NFSD:  m
CONFIG_NFS_FS:  m
CONFIG_NLS:  y
CONFIG_NLS_CODEPAGE_437:  m
CONFIG_NLS_CODEPAGE_850:  m
CONFIG_NLS_ISO8859_1:  m
CONFIG_NLS_UTF8:  m
CONFIG_NTFS_FS:  m
CONFIG_OOM_KILLER:  y
CONFIG_PACKET:  y
CONFIG_PARPORT:  m
CONFIG_PARPORT_PC:  m
CONFIG_PCI:  y
CONFIG_PCI_BIOS:  y
CONFIG_PCI_GOANY:  y
CONFIG_PCI_OLD_PROC:  y
CONFIG_PCI_QUIRKS:  y
CONFIG_PIIX_TUNING:  y
CONFIG_PM:  y
CONFIG_PPP:  m
CONFIG_PPPOE:  m
CONFIG_PPP_ASYNC:  m
CONFIG_PPP_BSDCOMP:  m
CONFIG_PPP_DEFLATE:  m
CONFIG_PPP_FILTER:  y
CONFIG_PPP_SYNC_TTY:  m
CONFIG_PREEMPT:  y
CONFIG_PRINTER:  m
CONFIG_PRINTER_READBACK:  y
CONFIG_PROC_FS:  y
CONFIG_PSMOUSE:  y
CONFIG_QNX4FS_FS:  m
CONFIG_REGPARM:  y
CONFIG_RTC:  y
CONFIG_SCSI:  y
CONFIG_SCSI_PROC_FS:  y
CONFIG_SERIAL:  m
CONFIG_SERIAL_8250:  m
CONFIG_SHAPER:  m
CONFIG_SLIP:  m
CONFIG_SMB_FS:  m
CONFIG_SMP:  y
CONFIG_SOUND:  m
CONFIG_SUNRPC:  m
CONFIG_SYSCTL:  y
CONFIG_SYSVIPC:  y
CONFIG_UFS_FS:  m
CONFIG_UMSDOS_FS:  m
CONFIG_UNIX:  y
CONFIG_USB:  m
CONFIG_USB_ACM:  m
CONFIG_USB_AUDIO:  m
CONFIG_USB_CDCETHER:  m
CONFIG_USB_DEVICEFS:  y
CONFIG_USB_EHCI_HCD:  m
CONFIG_USB_HID:  m
CONFIG_USB_HIDINPUT:  y
CONFIG_USB_KBD:  m
CONFIG_USB_MOUSE:  m
CONFIG_USB_OHCI:  m
CONFIG_USB_OHCI_HCD:  m
CONFIG_USB_PRINTER:  m
CONFIG_USB_SERIAL:  m
CONFIG_USB_STORAGE:  m
CONFIG_USB_UHCI:  m
CONFIG_USB_UHCI_ALT:  m
CONFIG_USB_UHCI_HCD:  m
CONFIG_VFAT_FS:  m
CONFIG_VGA_CONSOLE:  y
CONFIG_VT:  y
CONFIG_VT_CONSOLE:  y
CONFIG_X86_MCE:  y
CONFIG_X86_UP_APIC:  y
CONFIG_X86_UP_IOAPIC:  y

Since we are at it, here are the hardware components of the box:

8086 	Intel Corporation 	254C 	E7501 	0 		Host Controller
8086 	Intel Corporation 	2543 	E7500/E7501 	0 		HI_B Virtual PCI-to-PCI Bridge
8086 	Intel Corporation 	2545 	E7500/E7501 	0 		HI_C Virtual PCI-to-PCI Bridge
8086 	Intel Corporation 	2547 	E7500/E7501 	0 		HI_D Virtual PCI-to-PCI Bridge
8086 	Intel Corporation 	2482 	82801CA/CAM 	10 		USB Controller
8086 	Intel Corporation 	244E 	82801BA/CA/DB, 6300ESB 	0 		Hub Interface to PCI Bridge
8086 	Intel Corporation 	2480 	82801CA 	0 		LPC Interface Bridge
8086 	Intel Corporation 	248B 	82801CA 	0 		UltraATA/100 IDE Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1461 	14611014 	0 		I/OxAPIC Interrupt Controller
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1460 	82870P2 	0 		Hub Interface-to-PCI Bridge
8086 	Intel Corporation 	1026 	82545GM 	18 		Gigabit Ethernet Controller
8086 	Intel Corporation 	100D 	82544GC 	1C 		Gigabit Ethernet Controller (LOM)
8086 	Intel Corporation 	0309 	80303 	0 		I/O Processor PCI-to-PCI Bridge Unit
1000 	LSI Logic 	0030 	LSI53C1020/1030 	78 		PCI-X to Ultra320 SCSI Controller
1000 	LSI Logic 	0030 	LSI53C1020/1030 	79 		PCI-X to Ultra320 SCSI Controller
1002 	ATI Technologies 	4752 	Rage XL PCI 	0 	

And the interrupts (while running 2.6.9):

           CPU0       CPU1       
  0:  159132374  132686719    IO-APIC-edge  timer
  1:          9          0    IO-APIC-edge  i8042
  8:          0          0    IO-APIC-edge  rtc
  9:          0          0   IO-APIC-level  acpi
 14:          1          0    IO-APIC-edge  ide0
 24:   22225220          0   IO-APIC-level  eth0
 28:          4  134406507   IO-APIC-level  eth1
120:     532730     578109   IO-APIC-level  ioc0
121:    1931739    1327672   IO-APIC-level  ioc1
NMI:          0          0 
LOC:  291863458  291863528 
ERR:          0
MIS:          0

/proc/net/dev

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth0:2512143307 20914618    0    0    0     0          0         0 1951489031 52933097    0    0    0     0       0          0
  eth1:943883086 75451745    0    0    0     0          0         0 201914508 171409895    0    0    0     0       0          0
    lo:2247204588  748445    0    0    0     0          0         0 2247204588  748445    0    0    0     0       0          0

/proc/net/route

Iface Destination Gateway  Flags RefCnt Use Metric Mask MTU Window IRTT                                                       
eth0 207C29D5 00000000 0001 0 0 0 F0FFFFFF 0 0 0                                                                               
eth1 00606B0A 00000000 0001 0 0 0 00FFFFFF 0 0 0                                                                               
eth0 00000000 217C29D5 0003 0 0 0 00000000 0 0 0                                                                               
