From: Sachin Sant <sachinp@in.ibm.com>
Subject: [PowerPC] Next May 8 boot failure: OOPS during ibmveth module init
Date: Fri, 08 May 2009 18:22:48 +0530
Message-ID: <4A042B20.4090903@in.ibm.com>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010701030102040508090001"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@ozlabs.org
To: linux-next@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:42951 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871AbZEHMww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 08:52:52 -0400
In-Reply-To: <20090508180251.f53f204e.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010701030102040508090001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Todays Next failed to boot on a Power6 JS22 blade with following oops.

Unable to handle kernel paging request for data at address 0x654af306c04b990
Faulting instruction address: 0xc00000000003a740
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod
NIP: c00000000003a740 LR: c000000000361e20 CTR: 0000000000000000
REGS: c000000042af6e80 TRAP: 0300   Not tainted  (2.6.30-rc4-next-20090508)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28222286  XER: 20000001
DAR: 0654af306c04b990, DSISR: 0000000040000000
TASK = c0000000428084d0[590] 'modprobe' THREAD: c000000042af4000 CPU: 0
GPR00: c000000000361e10 c000000042af7100 c000000000eb8190 c00000004427cc80
GPR04: 0654af306c04b990 0000000000000006 0000000000000000 0000000000000002
GPR08: c00000004427cc00 0000000000000088 0000000000000280 000000000000007c
GPR12: 0000000084222284 c000000000f92400 0000000000000000 0000000000000000
GPR16: 0000000000000000 0000000000000000 d000000000ed4346 d000000000ed3aa0
GPR20: d000000000ed6358 c00000004427cc00 00000000ffffffff 0000000000000000
GPR24: 0000000000000000 c0000000402d0000 0000000000000010 c00000004194b400
GPR28: 0000000000000006 0654af306c04b990 c000000000e44f18 0000000000000000
NIP [c00000000003a740] .memcpy+0x240/0x278
LR [c000000000361e20] .__nla_put+0x30/0x4c
Call Trace:
[c000000042af7100] [c000000000361e10] .__nla_put+0x20/0x4c (unreliable)
[c000000042af7190] [c000000000361e88] .nla_put+0x4c/0x60
[c000000042af7200] [c00000000053993c] .rtnl_fill_ifinfo+0x308/0x614
[c000000042af7300] [c00000000053a118] .rtmsg_ifinfo+0x104/0x198
[c000000042af73b0] [c00000000053a244] .rtnetlink_event+0x98/0xb0
[c000000042af7430] [c0000000005c8330] .notifier_call_chain+0x68/0xdc
[c000000042af74d0] [c000000000530488] .register_netdevice+0x390/0x418
[c000000042af75a0] [c000000000530568] .register_netdev+0x58/0x80
[c000000042af7630] [d000000000ed2da4] .ibmveth_probe+0x2c8/0x3a4 [ibmveth]
[c000000042af7730] [c000000000023208] .vio_bus_probe+0x2f0/0x358
[c000000042af77f0] [c000000000462be0] .driver_probe_device+0xd4/0x1bc
[c000000042af7890] [c000000000462d5c] .__driver_attach+0x94/0xd8
[c000000042af7920] [c000000000462164] .bus_for_each_dev+0x80/0xe8
[c000000042af79d0] [c0000000004629b0] .driver_attach+0x28/0x40
[c000000042af7a50] [c000000000461808] .bus_add_driver+0xdc/0x27c
[c000000042af7af0] [c0000000004631d0] .driver_register+0xf0/0x1b0
[c000000042af7b90] [c000000000025178] .vio_register_driver+0x44/0x60
[c000000042af7c20] [d000000000ed2ed4] .ibmveth_module_init+0x54/0xa60 [ibmveth]
[c000000042af7ca0] [c0000000000092c0] .do_one_initcall+0x80/0x19c
[c000000042af7d90] [c0000000000bf884] .SyS_init_module+0xe0/0x248
[c000000042af7e30] [c000000000008534] syscall_exit+0x0/0x40
Instruction dump:
7cb01120 7c862214 7c661a14 4bfffe04 409c001c 80040000 81240004 38840008
90030000 91230004 38630008 409d0014 <80040000> 38840004 90030000 38630004
---[ end trace 695e9dc0c5a9da2f ]---

udevd-event[587]: '/sbin/modprobe' abnormal exit

Unable to handle kernel paging request for data at address 0x654af306c04b990
Faulting instruction address: 0xc000000000543ce0
Oops: Kernel access of bad area, sig: 11 [#2]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod
NIP: c000000000543ce0 LR: c000000000543dcc CTR: c00000000053dd98
REGS: c0000000408b3740 TRAP: 0300   Tainted: G      D     (2.6.30-rc4-next-20090508)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24042428  XER: 00000001
DAR: 0654af306c04b990, DSISR: 0000000040000000
TASK = c00000004053d880[752] 'udevd' THREAD: c0000000408b0000 CPU: 3
GPR00: c000000000543dcc c0000000408b39c0 c000000000eb8190 c0000000448e0000
GPR04: 0000000000010000 c000000000796dec 0000000000000006 0000000000000000
GPR08: c00000004265cf34 c000000000ea7250 c00000004265cf34 0000000000000000
GPR12: 0000000044042488 c000000000f92a00 0000000000000001 0000000000000001
GPR16: 00000000100372dc 00000000100374e0 00000000100376f8 0000000000000000
GPR20: 0000000010036ec8 0000000000000000 00000fffdb3a6618 0000000000000200
GPR24: 0000000000000006 0000000000000005 c0000000448f0000 c0000000448e0000
GPR28: 0654af306c04b990 0000000000000000 c000000000e45318 c0000000448e0000
NIP [c000000000543ce0] ._format_mac_addr+0x54/0xd4
LR [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
Call Trace:
[c0000000408b39c0] [c00000000010c9a4] .__alloc_pages_internal+0x1b8/0x590 (unreliable)
[c0000000408b3a70] [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
[c0000000408b3b00] [c00000000053dde8] .show_address+0x50/0x88
[c0000000408b3b90] [c00000000045ead4] .dev_attr_show+0x4c/0x94
[c0000000408b3c20] [c0000000001bce48] .sysfs_read_file+0x10c/0x1d0
[c0000000408b3ce0] [c00000000014c9a0] .vfs_read+0xd0/0x1bc
[c0000000408b3d80] [c00000000014cb94] .SyS_read+0x58/0xa0
[c0000000408b3e30] [c000000000008534] syscall_exit+0x0/0x40
Instruction dump:
f8010010 ebc2cc58 f821ff51 7c7b1b78 7cd83378 7cbc2b78 7f432214 7c7f1b78
3ba00000 3b26ffff 48000044 e8be8000 <88dc0000> 3b9c0001 4be0ff89 60000000
---[ end trace 695e9dc0c5a9da30 ]---

attempt to access beyond end of device

Next May 7 with same config boots fine.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------


--------------010701030102040508090001
Content-Type: text/plain;
 name="log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="log"

boot: next
Using 007ba4b8 bytes for initrd buffer
Please wait, loading kernel...
Allocated 01500000 bytes for kernel @ 02200000
   Elf64 kernel loaded...
Loading ramdisk...
ramdisk loaded 007ba4b8 @ 03700000
OF stdout device is: /vdevice/vty@30000000
Preparing to boot Linux version 2.6.30-rc4-next-20090508 (root@mjs22lp5) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #3 SMP Fri May 8 17:04:14 IST 2009
Calling ibm,client-architecture... done
command line: root=/dev/sda3 sysrq=8 
memory layout at init:
  alloc_bottom : 0000000003ec0000
  alloc_top    : 0000000008000000
  alloc_top_hi : 0000000008000000
  rmo_top      : 0000000008000000
  ram_top      : 0000000008000000
instantiating rtas at 0x0000000007630000... done
boot cpu hw idx 0000000000000000
starting cpu hw idx 0000000000000002... done
copying OF device tree...
Building dt strings...
Building dt structure...
Device tree strings 0x0000000003ed0000 -> 0x0000000003ed1585
Device tree struct  0x0000000003ee0000 -> 0x0000000003ef0000
Calling quiesce...
returning from prom_init
Phyp-dump disabled at boot time
Using pSeries machine description
Using 1TB segments
Found initrd at 0xc000000003700000:0xc000000003eba4b8
console [udbg0] enabled
Partition configured for 8 cpus.
CPU maps initialized for 2 threads per core
Starting Linux PPC64 #3 SMP Fri May 8 17:04:14 IST 2009
-----------------------------------------------------
ppc64_pft_size                = 0x19
physicalMemorySize            = 0x80000000
htab_hash_mask                = 0x3ffff
-----------------------------------------------------
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.30-rc4-next-20090508 (root@mjs22lp5) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #3 SMP Fri May 8 17:04:14 IST 2009
[boot]0012 Setup Arch
EEH: No capable adapters found
PPC64 nvram contains 15360 bytes
Zone PFN ranges:
  DMA      0x00000000 -> 0x00008000
  Normal   0x00008000 -> 0x00008000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    1: 0x00000000 -> 0x00000800
    0: 0x00000800 -> 0x00004600
    1: 0x00004600 -> 0x00008000
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 32726
Policy zone: DMA
Kernel command line: root=/dev/sda3 sysrq=8 
Experimental hierarchical RCU implementation.
Experimental hierarchical RCU init done.
NR_IRQS:512
[boot]0020 XICS Init
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
clocksource: timebase mult[7d0000] shift[22] registered
Console: colour dummy device 80x25
console handover: boot [udbg0] -> real [hvc0]
allocated 1310720 bytes of page_cgroup
please try cgroup_disable=memory option if you don't want
freeing bootmem node 0
freeing bootmem node 1
Memory: 2032704k/2097152k available (13056k kernel code, 69440k reserved, 2048k data, 4268k bss, 4672k init)
Calibrating delay loop... 1022.36 BogoMIPS (lpj=5111808)
Security Framework initialized
SELinux:  Disabled at boot.
Dentry cache hash table entries: 262144 (order: 5, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 4, 1048576 bytes)
Mount-cache hash table entries: 4096
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Processor 1 found.
Processor 2 found.
Processor 3 found.
Brought up 4 CPUs
net_namespace: 1888 bytes
NET: Registered protocol family 16
IBM eBus Device Driver
PCI: Probing PCI hardware
bio: create slab <bio-0> at 0
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
Failed to register trace events module notifier
NET: Registered protocol family 2
IP route cache hash table entries: 16384 (order: 1, 131072 bytes)
TCP established hash table entries: 65536 (order: 4, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 65536 bind 65536)
TCP reno registered
NET: Registered protocol family 1
Unpacking initramfs...
Freeing initrd memory: 7913k freed
IOMMU table initialized, virtual merging enabled
audit: initializing netlink socket (disabled)
type=2000 audit(1241782614.530:1): initialized
HugeTLB registered 16 MB page size, pre-allocated 0 pages
HugeTLB registered 16 GB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 8192 (order 0, 65536 bytes)
Btrfs loaded
msgmni has been set to 3984
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
Generic RTC Driver v1.07
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
input: Macintosh mouse button emulation as /devices/virtual/input/input0
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
mice: PS/2 mouse device common for all mice
EDAC MC: Ver: 2.1.0 May  8 2009
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 15
registered taskstats version 1
Freeing unused kernel memory: 4672k freed
doing fast boot
SysRq : Changing Loglevel
Loglevel set to 8
SCSI subsystem initialized
vio_register_driver: driver ibmvscsi registering
ibmvscsi 30000002: SRP_VERSION: 16.a
scsi0 : IBM POWER Virtual SCSI Adapter 1.5.8
ibmvscsi 30000002: partner initialization complete
ibmvscsi 30000002: sent SRP login
ibmvscsi 30000002: SRP_LOGIN succeeded
ibmvscsi 30000002: host srp version: 16.a, host partition 06-1C12A (1), OS 3, max io 262144
scsi 0:0:1:0: Direct-Access     AIX      VDASD            0001 PQ: 0 ANSI: 3
scsi 0:0:2:0: CD-ROM            AIX      VOPTA                 PQ: 0 ANSI: 4
Creating device nodes with udev
udevd version 128 started
Driver 'sd' needs updating - please use bus_type methods
sd 0:0:1:0: [sda] 33554432 512-byte hardware sectors: (17.1 GB/16.0 GiB)
sd 0:0:1:0: [sda] Write Protect is off
sd 0:0:1:0: [sda] Mode Sense: 17 00 00 08
sd 0:0:1:0: [sda] Cache data unavailable
sd 0:0:1:0: [sda] Assuming drive cache: write through
sd 0:0:1:0: [sda] Cache data unavailable
sd 0:0:1:0: [sda] Assuming drive cache: write through
 sda: sda1 sda2 sda3
sd 0:0:1:0: [sda] Attached SCSI disk
Boot logging started on /dev/hvc0(/dev/console) at Fri May  8 11:36:54 2009
Waiting for device /dev/sda3 to appear:  ok
showconsole: Warning: the ioctl TIOCGDEV is not known by the kernel
fsck 1.41.1 (01-Sep-2008)
[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/sda3 
/dev/sda3: clean, 263693/983040 files, 2840945/3929888 blocks
fsck succeeded. Mounting root device read-write.
Mounting root /dev/sda3
mount -o rw,acl,user_xattr -t ext3 /dev/sda3 /root
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with writeback data mode.
mount: can't find /root/proc in /etc/fstab or /etc/mtab
INIT: version 2.86 booting
System Boot Control: Running /etc/init.d/boot
Mounting procfs at /proc                                             done
Mounting sysfs at /sys                                               done
Mounting debugfs at /sys/kernel/debug                                done
Remounting tmpfs at /dev                                             done
Initializing /dev                                                    done
Mounting devpts at /dev/pts                                          done
Starting udevd: udevd version 128 started
                                                                     done
Loading drivers, configuring devices: sd 0:0:1:0: Attached scsi generic sg0 type 0
scsi 0:0:2:0: Attached scsi generic sg1 type 5
drivers/net/ibmveth.c: ibmveth: IBM i/pSeries Virtual Ethernet Driver 1.03
vio_register_driver: driver ibmveth registering
Unable to handle kernel paging request for data at address 0x654af306c04b990
Faulting instruction address: 0xc00000000003a740
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod
NIP: c00000000003a740 LR: c000000000361e20 CTR: 0000000000000000
REGS: c000000042af6e80 TRAP: 0300   Not tainted  (2.6.30-rc4-next-20090508)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28222286  XER: 20000001
DAR: 0654af306c04b990, DSISR: 0000000040000000
TASK = c0000000428084d0[590] 'modprobe' THREAD: c000000042af4000 CPU: 0
GPR00: c000000000361e10 c000000042af7100 c000000000eb8190 c00000004427cc80 
GPR04: 0654af306c04b990 0000000000000006 0000000000000000 0000000000000002 
GPR08: c00000004427cc00 0000000000000088 0000000000000280 000000000000007c 
GPR12: 0000000084222284 c000000000f92400 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 d000000000ed4346 d000000000ed3aa0 
GPR20: d000000000ed6358 c00000004427cc00 00000000ffffffff 0000000000000000 
GPR24: 0000000000000000 c0000000402d0000 0000000000000010 c00000004194b400 
GPR28: 0000000000000006 0654af306c04b990 c000000000e44f18 0000000000000000 
NIP [c00000000003a740] .memcpy+0x240/0x278
LR [c000000000361e20] .__nla_put+0x30/0x4c
Call Trace:
[c000000042af7100] [c000000000361e10] .__nla_put+0x20/0x4c (unreliable)
[c000000042af7190] [c000000000361e88] .nla_put+0x4c/0x60
[c000000042af7200] [c00000000053993c] .rtnl_fill_ifinfo+0x308/0x614
[c000000042af7300] [c00000000053a118] .rtmsg_ifinfo+0x104/0x198
[c000000042af73b0] [c00000000053a244] .rtnetlink_event+0x98/0xb0
[c000000042af7430] [c0000000005c8330] .notifier_call_chain+0x68/0xdc
[c000000042af74d0] [c000000000530488] .register_netdevice+0x390/0x418
[c000000042af75a0] [c000000000530568] .register_netdev+0x58/0x80
[c000000042af7630] [d000000000ed2da4] .ibmveth_probe+0x2c8/0x3a4 [ibmveth]
[c000000042af7730] [c000000000023208] .vio_bus_probe+0x2f0/0x358
[c000000042af77f0] [c000000000462be0] .driver_probe_device+0xd4/0x1bc
[c000000042af7890] [c000000000462d5c] .__driver_attach+0x94/0xd8
[c000000042af7920] [c000000000462164] .bus_for_each_dev+0x80/0xe8
[c000000042af79d0] [c0000000004629b0] .driver_attach+0x28/0x40
[c000000042af7a50] [c000000000461808] .bus_add_driver+0xdc/0x27c
[c000000042af7af0] [c0000000004631d0] .driver_register+0xf0/0x1b0
[c000000042af7b90] [c000000000025178] .vio_register_driver+0x44/0x60
[c000000042af7c20] [d000000000ed2ed4] .ibmveth_module_init+0x54/0xa60 [ibmveth]
[c000000042af7ca0] [c0000000000092c0] .do_one_initcall+0x80/0x19c
[c000000042af7d90] [c0000000000bf884] .SyS_init_module+0xe0/0x248
[c000000042af7e30] [c000000000008534] syscall_exit+0x0/0x40
Instruction dump:
7cb01120 7c862214 7c661a14 4bfffe04 409c001c 80040000 81240004 38840008 
90030000 91230004 38630008 409d0014 <80040000> 38840004 90030000 38630004 
---[ end trace 695e9dc0c5a9da2f ]---
udevd-event[587]: '/sbin/modprobe' abnormal exit

Unable to handle kernel paging request for data at address 0x654af306c04b990
Faulting instruction address: 0xc000000000543ce0
Oops: Kernel access of bad area, sig: 11 [#2]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: ibmveth(+) sg sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt scsi_mod
NIP: c000000000543ce0 LR: c000000000543dcc CTR: c00000000053dd98
REGS: c0000000408b3740 TRAP: 0300   Tainted: G      D     (2.6.30-rc4-next-20090508)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24042428  XER: 00000001
DAR: 0654af306c04b990, DSISR: 0000000040000000
TASK = c00000004053d880[752] 'udevd' THREAD: c0000000408b0000 CPU: 3
GPR00: c000000000543dcc c0000000408b39c0 c000000000eb8190 c0000000448e0000 
GPR04: 0000000000010000 c000000000796dec 0000000000000006 0000000000000000 
GPR08: c00000004265cf34 c000000000ea7250 c00000004265cf34 0000000000000000 
GPR12: 0000000044042488 c000000000f92a00 0000000000000001 0000000000000001 
GPR16: 00000000100372dc 00000000100374e0 00000000100376f8 0000000000000000 
GPR20: 0000000010036ec8 0000000000000000 00000fffdb3a6618 0000000000000200 
GPR24: 0000000000000006 0000000000000005 c0000000448f0000 c0000000448e0000 
GPR28: 0654af306c04b990 0000000000000000 c000000000e45318 c0000000448e0000 
NIP [c000000000543ce0] ._format_mac_addr+0x54/0xd4
LR [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
Call Trace:
[c0000000408b39c0] [c00000000010c9a4] .__alloc_pages_internal+0x1b8/0x590 (unreliable)
[c0000000408b3a70] [c000000000543dcc] .sysfs_format_mac+0x30/0x6c
[c0000000408b3b00] [c00000000053dde8] .show_address+0x50/0x88
[c0000000408b3b90] [c00000000045ead4] .dev_attr_show+0x4c/0x94
[c0000000408b3c20] [c0000000001bce48] .sysfs_read_file+0x10c/0x1d0
[c0000000408b3ce0] [c00000000014c9a0] .vfs_read+0xd0/0x1bc
[c0000000408b3d80] [c00000000014cb94] .SyS_read+0x58/0xa0
[c0000000408b3e30] [c000000000008534] syscall_exit+0x0/0x40
Instruction dump:
f8010010 ebc2cc58 f821ff51 7c7b1b78 7cd83378 7cbc2b78 7f432214 7c7f1b78 
3ba00000 3b26ffff 48000044 e8be8000 <88dc0000> 3b9c0001 4be0ff89 60000000 
---[ end trace 695e9dc0c5a9da30 ]---
attempt to access beyond end of device
sda3: rw=0, want=31439208, limit=31439205
IBM eHEA ethernet device driver (Release EHEA_0101)
irq: irq 590080 on host null mapped to virtual irq 256
Driver 'sr' needs updating - please use bus_type methods
sr0: scsi-1 drive
Uniform CD-ROM driver Revision: 3.20
sr 0:0:2:0: Attached scsi CD-ROM sr0




--------------010701030102040508090001--
