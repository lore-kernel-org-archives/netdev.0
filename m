From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Fri, 18 Jul 2008 18:36:42 +0300
Message-ID: <4880B88A.6060201@embedded-sol.com>
References: <4866211E.6040704@embedded-sol.com> <200807140947.46733.sr@denx.de> <487B0B75.1070506@embedded-sol.com> <200807181655.54760.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:37597 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885AbYGRPhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 11:37:01 -0400
In-Reply-To: <200807181655.54760.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stefen

Are you sure your NFS root is mounted via e1000e ? I cannot complete the 
boot
with 2.6.26 release if e1000e is compiled into the kernel and on-board 
NICs disconnected.
This is what I get:

e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:41:00.0: enabling device (0006 -> 0007)
eth0: (PCI Express:2.5GB/s:Width x1) 00:1b:21:1e:2d:2a
eth0: Intel(R) PRO/1000 Network Connection
eth0: MAC: 1, PHY: 4, PBA No: d50854-003
PPC 4xx OCP EMAC driver, version 3.54
MAL v2 /plb/mcmal, 2 TX channels, 16 RX channels
ZMII /plb/opb/emac-zmii@ef600d00 initialized
RGMII /plb/opb/emac-rgmii@ef601500 initialized with MDIO support
TAH /plb/opb/emac-tah@ef601350 initialized
TAH /plb/opb/emac-tah@ef601450 initialized
/plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
eth1: EMAC-0 /plb/opb/ethernet@ef600e00, MAC 00:10:ec:00:f9:f8
eth1: found Generic MII PHY (0x00)
/plb/opb/emac-rgmii@ef601500: input 1 in RGMII mode
eth2: EMAC-1 /plb/opb/ethernet@ef600f00, MAC 00:10:ec:80:f9:f8
eth2: found Generic MII PHY (0x01)
4cc000000.nor_flash: Found 1 x16 devices at 0x0 in 16-bit bank
 Amd/Fujitsu Extended Query Table at 0x0040
4cc000000.nor_flash: CFI does not contain boot bank location. Assuming top.
number of CFI chips: 1
cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
RedBoot partition parsing not available
Creating 7 MTD partitions on "4cc000000.nor_flash":
0x00000000-0x001e0000 : "kernel"
0x001e0000-0x00200000 : "dtb"
0x00200000-0x01600000 : "ramdisk"
0x01600000-0x01a00000 : "jffs2"
0x01a00000-0x03f60000 : "user"
0x03f60000-0x03fa0000 : "env"
0x03fa0000-0x04000000 : "u-boot"
i2c /dev entries driver
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
eth1: link is down
eth2: link is down
Sending DHCP requests .<6>eth0: Link is Up 100 Mbps Full Duplex, Flow 
Control: RX/TX
eth0: 10/100 speed: disabling TSO
., OK
IP-Config: Got DHCP answer from 10.0.0.1, my address is 10.0.0.30
IP-Config: Complete:
     device=eth0, addr=10.0.0.30, mask=255.0.0.0, gw=255.255.255.255,
     host=Canyonlands, domain=, nis-domain=(none),
     bootserver=10.0.0.1, rootserver=10.0.0.1, rootpath=/nfsroot
Looking up port of RPC 100003/2 on 10.0.0.1
Looking up port of RPC 100005/1 on 10.0.0.1
VFS: Mounted root (nfs filesystem).
Freeing unused kernel memory: 168k init
INIT: version 2.86 booting
usbcore: Unknown symbol add_uevent_var
                Welcome to DENX Embedded Linux Environment
                Press 'I' to enter interactive startup.
Cannot access the Hardware Clock via any known method.
Use the --debug option to see the details of our search for an access 
method.
Setting clock : Thu Jan  1 01:00:07 CET 1970 [  OK  ]
Building the cache
nfs: server 10.0.0.1 not responding, still trying
nfs: server 10.0.0.1 not responding, still trying
nfs: server 10.0.0.1 not responding, still trying
nfs: server 10.0.0.1 not responding, still trying
nfs: server 10.0.0.1 not responding, still trying

Felix.

Stefan Roese wrote:
> Hi Felix,
>
> I just tried this on my Canyonlands with the kernel.org 2.6.26 release:
>
> e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> e1000e 0001:81:00.0: enabling device (0006 -> 0007)
> eth0: (PCI Express:2.5GB/s:Width x1) 00:1b:21:04:a3:47
> eth0: Intel(R) PRO/1000 Network Connection
> eth0: MAC: 1, PHY: 4, PBA No: d50854-003
> ...
>
> -bash-3.2# uname -a
> Linux canyonlands 2.6.26 #2 Fri Jul 18 16:46:00 CEST 2008 ppc ppc ppc GNU/Linux
> -bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=2
> 2+0 records in
> 2+0 records out
> 1024 bytes (1.0 kB) copied, 0.015222 s, 67.3 kB/s
> -bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=3
> 3+0 records in
> 3+0 records out
> 1536 bytes (1.5 kB) copied, 0.014824 s, 104 kB/s
> -bash-3.2# dd if=/dev/zero of=/mnt/test bs=512 count=256
> 256+0 records in
> 256+0 records out
> 131072 bytes (131 kB) copied, 0.099793 s, 1.3 MB/s
> -bash-3.2# dmesg -c
> -bash-3.2#                                      
>
> So no problems here.
>
> Rootfs NFS is mounted via e1000e of course.
>
> Did you try with kernel.org 2.6.26 too? If not, please do so.
>
> Best regards,
> Stefan
>
> =====================================================================
> DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
> HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
> Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
> =====================================================================
>   

