From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Mon, 29 Mar 2010 16:40:09 +0800
Message-ID: <4BB06769.7040708@canonical.com>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
	<20100327125703.GB5880@pengutronix.de>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	linux-kernel@vger.kernel.org, kernel-team@lists.ubuntu.com,
	gerg@uclinux.org, linux-arm-kernel@lists.infradead.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <20100327125703.GB5880@pengutronix.de>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Sender: kernel-team-bounces@lists.ubuntu.com
Errors-To: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

On 03/27/2010 08:57 PM, Wolfram Sang wrote:
> On Fri, Mar 26, 2010 at 05:50:52PM +0800, Bryan Wu wrote:
>> BugLink: http://bugs.launchpad.net/bugs/457878
>>
>>   - removed old MII phy control code
>>   - add phylib supporting
>>   - add ethtool interface to make user space NetworkManager works
>>
>> Tested on Freescale i.MX51 Babbage board.
>
> Sadly, I have problems here booting a custom board:
>

Firstly, I working on our Ubuntu Lucid 2.6.31 based kernel. This patch works
fine on our system. Then I forward port it to 2.6.34-rc2 Linus mainline kernel.
It also works fine on my hardware.
---
# dmesg
Linux version 2.6.34-rc2 (roc@roc-desktop) (gcc version 4.4.1 (Sourcery G++ Lite 
2009q3-67) ) #7 Mon Mar 29 15:37:54 CST 2010
CPU: ARMv7 Processor [412fc081] revision 1 (ARMv7), cr=10c53c7f
CPU: VIPT nonaliasing data cache, VIPT nonaliasing instruction cache
Machine: Freescale MX51 Babbage Board
Memory policy: ECC disabled, Data cache writeback
On node 0 totalpages: 131072
free_area_init_node: node 0, pgdat c0372874, node_mem_map c03d0000
   Normal zone: 1024 pages used for memmap
   Normal zone: 0 pages reserved
   Normal zone: 130048 pages, LIFO batch:31
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 130048
Kernel command line: root=/dev/ram ro console=ttymxc0,115200
PID hash table entries: 2048 (order: 1, 8192 bytes)
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Memory: 512MB = 512MB total
Memory: 501556k/501556k available, 22732k reserved, 0K highmem
Virtual kernel memory layout:
     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
     DMA     : 0xffc00000 - 0xffe00000   (   2 MB)
     vmalloc : 0xe0800000 - 0xf4000000   ( 312 MB)
     lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
     modules : 0xbf000000 - 0xc0000000   (  16 MB)
       .init : 0xc0008000 - 0xc0024000   ( 112 kB)
       .text : 0xc0024000 - 0xc034f000   (3244 kB)
       .data : 0xc0350000 - 0xc0372e80   ( 140 kB)
SLUB: Genslabs=11, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Hierarchical RCU implementation.
NR_IRQS:272
TrustZone Interrupt Controller (TZIC) initialized
start_kernel(): bug: interrupts were enabled early
Console: colour dummy device 80x30
Calibrating delay loop... 95.84 BogoMIPS (lpj=479232)
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
NET: Registered protocol family 16
bio: create slab <bio-0> at 0
SCSI subsystem initialized
Switching to clocksource mxc_timer1
NET: Registered protocol family 2
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 16384 (order: 4, 65536 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
TCP reno registered
UDP hash table entries: 256 (order: 0, 4096 bytes)
UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
NET: Registered protocol family 1
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
Trying to unpack rootfs image as initramfs...
rootfs image is not initramfs (junk in compressed archive); looks like an initrd
Freeing initrd memory: 14336K
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
fuse init (API version 7.13)
msgmni has been set to 1007
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
Serial: IMX driver
imx-uart.0: ttymxc0 at MMIO 0x73fbc000 (irq = 31) is a IMX
console [ttymxc0] enabled
imx-uart.1: ttymxc1 at MMIO 0x73fc0000 (irq = 32) is a IMX
imx-uart.2: ttymxc2 at MMIO 0x7000c000 (irq = 33) is a IMX
brd: module loaded
loop: module loaded
FEC Ethernet Driver
fec_enet_mii_bus: probed
eth0: Freescale FEC PHY driver [SMSC LAN8700] (mii_bus:phy_addr=0:00, irq=-1)
mice: PS/2 mouse device common for all mice
TCP cubic registered
NET: Registered protocol family 17
VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 2
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
RAMDISK: ext2 filesystem found at block 0
RAMDISK: Loading 8192KiB [1 disk] into ram disk... done.
VFS: Mounted root (ext2 filesystem) readonly on device 1:0.
Freeing init memory: 112K
PHY: 0:00 - Link is Up - 100/Full
PHY: 0:00 - Link is Down
PHY: 0:00 - Link is Up - 100/Full
# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:04:9F:00:E8:C8
           inet addr:192.168.0.102  Bcast:192.168.0.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:728 errors:0 dropped:0 overruns:0 frame:0
           TX packets:72 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:221308 (216.1 KiB)  TX bytes:6832 (6.6 KiB)
           Base address:0x6000

# uname -a
Linux (none) 2.6.34-rc2 #7 Mon Mar 29 15:37:54 CST 2010 armv7l GNU/Linux


# ping 192.168.0.1
PING 192.168.0.1 (192.168.0.1): 56 data bytes
64 bytes from 192.168.0.1: seq=0 ttl=127 time=13.397 ms
64 bytes from 192.168.0.1: seq=1 ttl=127 time=4.791 ms
64 bytes from 192.168.0.1: seq=2 ttl=127 time=4.746 ms
64 bytes from 192.168.0.1: seq=3 ttl=127 time=4.573 ms
64 bytes from 192.168.0.1: seq=4 ttl=127 time=4.635 ms
64 bytes from 192.168.0.1: seq=5 ttl=127 time=4.560 ms
64 bytes from 192.168.0.1: seq=6 ttl=127 time=4.678 ms
64 bytes from 192.168.0.1: seq=7 ttl=127 time=4.498 ms
64 bytes from 192.168.0.1: seq=8 ttl=127 time=4.557 ms
^C
--- 192.168.0.1 ping statistics ---
9 packets transmitted, 9 packets received, 0% packet loss
round-trip min/avg/max = 4.498/5.603/13.397 ms
---

Is that possible for more guys to take a look at this patch? Any feedback are
welcome.

Thanks,
-Bryan
