From: Danie Wessels <dawessels@telkomsa.net>
Subject: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T together
Date: Wed, 20 Jul 2011 12:44:40 +0200
Message-ID: <4E26B198.4020606@telkomsa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wblv-ip-mesg-2-3.saix.net ([196.25.240.101]:64515 "EHLO
	wblv-ip-mesg-2-3.saix.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab1GTL11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 07:27:27 -0400
Received: from lulu.wessels (dsl-240-213-90.telkomadsl.co.za [41.240.213.90])
	by wblv-ip-mesg-2-3.saix.net (Postfix) with ESMTP id C37AD21A4
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 12:43:43 +0200 (SAST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I would like to use my onboard NIC (eth0) with its r8168 driver from 
RealTek together with my D-Link NIC (eth4=eth1) with its r8169 default 
driver from the install. Sepatately they seem to work...but I would like 
a firewall set up with NAT and had it before I "upgraded". ;^)

2 Questions:
1) How can / should I modify the rules (in /etc/rules.d ?) and apply 
them for the kernel to load both drivers? (Even if it is just temporary 
until next update and I have to apply it again)
2) Are there still known issues with instability of the r8168 drivers 
(as per Ubuntu bug lists)?

Here follows ALL the info I though was relevant(?).
I am running Ubutnu 11.04: uname -av
Linux weer 2.6.38-8-generic #42-Ubuntu SMP Mon Apr 11 03:31:50 UTC 2011 
i686 i686 i386 GNU/Linux

With default install:
    grep Gigabit lshw.txt -A 13 -B 2
    *-network
    description: Ethernet interface
    product: RTL8111/8168B PCI Express Gigabit Ethernet controller
    vendor: Realtek Semiconductor Co., Ltd.
    physical id: 0
    bus info: pci@0000:03:00.0
    logical name: eth0
    version: 01
    serial: 00:1c:c0:a7:03:49
    size: 10Mbit/s
    capacity: 1Gbit/s
    width: 64 bits
    clock: 33MHz
    capabilities: pm vpd msi pciexpress bus_master cap_list rom ethernet 
physical tp mii 10bt
    10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
    configuration: autonegotiation=on broadcast=yes driver=r8169 
driverversion=2.3LK-NAPI
    alias: pci:v000010ECd00008168sv*sd*bc*sc*i*
    depends:
    vermagic: 2.6.38-8-generic SMP mod_unload modversions 686
    parm: eee_enable:int
    parm: speed:force phy operation. Deprecated by ethtool (8). (array 
of int)
    parm: duplex:force phy operation. Deprecated by ethtool (8). (array 
of int)
    parm: autoneg:force phy operation. Deprecated by ethtool (8). (array 
of int)
    parm: rx_copybreak:Copy breakpoint for copy-only-tiny-frames (int)
    parm: use_dac:Enable PCI DAC. Unsafe on 32 bit PCI slot. (int)
    parm: debug:Debug verbosity level (0=none, ..., 16=all) (int)

On start up I get from dmesg
    dmesg
    [ 1.368802] <30>udev[71]: starting version 167
    [ 1.485938] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
    [ 1.485956] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> 
IRQ 17
    [ 1.485994] r8169 0000:03:00.0: setting latency timer to 64
    [ 1.486061] r8169 0000:03:00.0: irq 43 for MSI/MSI-X
    [ 1.486546] r8169 0000:03:00.0: eth0: RTL8168b/8111b at 0xf8024000, 
00:1c:c0:a7:03:49, XID
    98500000 IRQ 43
    [ 1.500171] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
    [ 1.500191] r8169 0000:04:06.0: PCI INT A -> GSI 21 (level, low) -> 
IRQ 21
:
    [ 91.680437] r8169 0000:03:00.0: eth0: link down
    [ 91.680442] r8169 0000:03:00.0: eth0: link down
    [ 91.682304] ADDRCONF(NETDEV_UP): eth0: link is not ready
    [ 91.685229] r8169 0000:04:06.0: eth4: link down
    [ 91.685410] ADDRCONF(NETDEV_UP): eth4: link is not ready
    [ 93.666844] r8169 0000:04:06.0: eth4: link up
    [ 93.666993] ADDRCONF(NETDEV_CHANGE): eth4: link becomes ready
    [ 94.424913] svc: failed to register lockdv1 RPC service (errno 97).
    [ 94.424944] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state 
recovery directory
    [ 94.612971] NFSD: starting 90-second grace period

I now have:
    /lib/modules/2.6.38-8-generic/kernel/drivers/net/r8168.ko eth0 
0000:03:00.0:
    /lib/modules/2.6.38-8-generic/kernel/drivers/net/r8169.ko eth4 
0000:04:06.0:
-

    root@weer:~# grep "816" lsmod*
    lsmodr8169.txt:filename: 
/lib/modules/2.6.38-8-generic/kernel/drivers/net/r8169.ko
    lsmodr8169.txt:firmware: rtl_nic/rtl8168d-2.fw
    lsmodr8169.txt:firmware: rtl_nic/rtl8168d-1.fw
    lsmodr8169.txt:description: RealTek RTL-8169 Gigabit Ethernet driver
    lsmodr8169.txt:author: Realtek and the Linux r8169 crew 
<netdev@vger.kernel.org>
    lsmodr8169.txt:alias: pci:v00000001d00008168sv*sd00002410bc*sc*i*
    lsmodr8169.txt:alias: pci:v000010ECd00008169sv*sd*bc*sc*i*
    lsmodr8169.txt:alias: pci:v000010ECd00008168sv*sd*bc*sc*i*
    lsmodr8169.txt:alias: pci:v000010ECd00008167sv*sd*bc*sc*i*
    lsmod.txt:r8169 42534 0

    root@weer:~# grep "bit" lspci.txt
    03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168B PCI Express Gigabit
    Ethernet controller (rev 01)
    04:06.0 Ethernet controller: D-Link System Inc DGE-528T Gigabit 
Ethernet Adapter (rev 10)

    root@weer:~# modinfo r8168
    filename: /lib/modules/2.6.38-8-generic/kernel/drivers/net/r8168.ko
    version: 8.024.00-NAPI
    license: GPL
    description: RealTek RTL-8168 Gigabit Ethernet driver
    author: Realtek and the Linux r8168 crew <netdev&am;vger.kernel.org>
    srcversion: F7DC35DC47F0220384E5AE2

    root@weer:~# modprobe -l -i r816* -v
    kernel/drivers/net/r8168.ko
    root@weer:~# grep eth udevadm_export_db.txt -A 8
    P: /devices/pci0000:00/0000:00:1c.1/0000:03:00.0/net/eth0
    E: UDEV_LOG=3
    E: DEVPATH=/devices/pci0000:00/0000:00:1c.1/0000:03:00.0/net/eth0
    E: INTERFACE=eth0
    E: IFINDEX=2
    E: SUBSYSTEM=net
    E: ID_VENDOR_FROM_DATABASE=Realtek Semiconductor Co., Ltd.
    E: ID_MODEL_FROM_DATABASE=RTL8111/8168B PCI Express Gigabit Ethernet 
controller
    E: ID_BUS=pci
    E: ID_VENDOR_ID=0x10ec
    E: ID_MODEL_ID=0x8168
    E: ID_MM_CANDIDATE=1
    --
    P: /devices/pci0000:00/0000:00:1e.0/0000:04:06.0/net/eth4
    E: UDEV_LOG=3
    E: DEVPATH=/devices/pci0000:00/0000:00:1e.0/0000:04:06.0/net/eth4
    E: INTERFACE=eth4
    E: IFINDEX=3
    E: SUBSYSTEM=net
    E: ID_VENDOR_FROM_DATABASE=D-Link System Inc
    E: ID_MODEL_FROM_DATABASE=DGE-528T Gigabit Ethernet Adapter
    E: ID_BUS=pci
    E: ID_VENDOR_ID=0x1186
    E: ID_MODEL_ID=0x4300
    E: ID_MM_CANDIDATE=1
    udevadm info --export-db >udevadm_export_db1.txt


    root@weer:~# grep Intel lshw.txt -A 2 -B 2
    description: Motherboard
    product: DG31PR
    vendor: Intel Corporation
    physical id: 0
    version: AAD97573-302
    --
    *-firmware
    description: BIOS
    vendor: Intel Corp.
    physical id: 0
    version: PRG3110H.86A.0052.2008.0612.1910
    *-cpu:0
    description: CPU
    product: Intel(R) Core(TM)2 Duo CPU E6550 @ 2.33GHz
    vendor: Intel Corp.
    physical id: 4
    bus info: cpu@0
    --
    description: Host bridge
    product: 82G33/G31/P35/P31 Express DRAM Controller
    vendor: Intel Corporation
    physical id: 100
    bus info: pci@0000:00:00.0
    --
    description: PCI bridge
    product: 82G33/G31/P35/P31 Express PCI Express Root Port
    vendor: Intel Corporation
    physical id: 1
    bus info: pci@0000:00:01.0

Best regards
Danie

-- 
Danie Wessels
Sel: +27 82 432 2975; Tel: +27 12 663 2564; Faks: +27 12 663 2564
