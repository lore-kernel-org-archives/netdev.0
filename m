From: Ira Snyder <iws@ovro.caltech.edu>
Subject: [BUG BISECTED] boot hangs while bringing up gianfar ethernet
Date: Thu, 29 Jan 2009 11:41:45 -0800
Message-ID: <20090129194145.GA4647@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:33502 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbZA2Tls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:41:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm working on a Freescale MPC8349EMDS board. I have been booting it
over NFS for a long time now. I try to run the latest git kernels to
find possible problems.

Recently, I haven't been able to boot over NFS anymore. When the machine
tries to bring up the ethernet interface, it just hangs forever. There
are no softlockup warnings, the machine has locked up completely.

Here is the commit I bisected it down to. I tried running git revert,
but there have been other changes which prevent an easy revert.

After building each kernel, I compiled and used the dts file from that
kernel. There shouldn't be any conflicts there.

I'm happy to test patches to fix the problem.

Thanks,
Ira

8c7396aebb68994c0519e438eecdf4d5fa9c7844 is first bad commit
commit 8c7396aebb68994c0519e438eecdf4d5fa9c7844
Author: Dai Haruki <dai.haruki@freescale.com>
Date:   Wed Dec 17 16:52:00 2008 -0800

    gianfar: Merge Tx and Rx interrupt for scheduling clean up ring
    
    No clean up function is executed in the interrupt context by this patch.
    
    Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
    Acked-by: Andy Fleming <afleming@freescale.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 723044a20168b125c2ad8f2cb6c826651de681d6 27fc12f4b0aa42c86f481e8d7e0d9979de607294 M	drivers


iws@desk1 ~/devel/linux-2.6 $ git bisect log
git-bisect start
# good: [4a6908a3a050aacc9c3a2f36b276b46c0629ad91] Linux 2.6.28
git-bisect good 4a6908a3a050aacc9c3a2f36b276b46c0629ad91
# bad: [18e352e4a73465349711a9324767e1b2453383e2] Linux 2.6.29-rc3
git-bisect bad 18e352e4a73465349711a9324767e1b2453383e2
# bad: [b67ff8ce122f3353bd741db48ce1756c12fb5f2d] kbuild: ignore a few files in headers_check
git-bisect bad b67ff8ce122f3353bd741db48ce1756c12fb5f2d
# bad: [0191b625ca5a46206d2fb862bb08f36f2fcb3b31] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
git-bisect bad 0191b625ca5a46206d2fb862bb08f36f2fcb3b31
# good: [54a696bd07c14d3b1192d03ce7269bc59b45209a] Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6
git-bisect good 54a696bd07c14d3b1192d03ce7269bc59b45209a
# good: [07fb0f1799dcb6b3df527909811fd6704278842e] netns PF_KEY: part 2
git-bisect good 07fb0f1799dcb6b3df527909811fd6704278842e
# good: [82a9928db560c429807f02467d22394f944a8916] tc35815: Enable StripCRC feature
git-bisect good 82a9928db560c429807f02467d22394f944a8916
# good: [82a9928db560c429807f02467d22394f944a8916] tc35815: Enable StripCRC feature
git-bisect good 82a9928db560c429807f02467d22394f944a8916
# bad: [3b5b35d02264580950d1e1565431b99d97c20ded] bonding: use port_params in __update_lacpdu_from_port
git-bisect bad 3b5b35d02264580950d1e1565431b99d97c20ded
# good: [56bde885903bdb9d9531fd569096ec8c7a2d60ee] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
git-bisect good 56bde885903bdb9d9531fd569096ec8c7a2d60ee
# good: [f250dcdac111a8369220b8e192eae6c56dc1098a] ipv6: fix the return interface index when get it while no message is received
git-bisect good f250dcdac111a8369220b8e192eae6c56dc1098a
# good: [fc10af8e658936f7b2bddd077f7ddcbe1eddc066] vcan: whitespace fixes
git-bisect good fc10af8e658936f7b2bddd077f7ddcbe1eddc066
# bad: [8c7396aebb68994c0519e438eecdf4d5fa9c7844] gianfar: Merge Tx and Rx interrupt for scheduling clean up ring
git-bisect bad 8c7396aebb68994c0519e438eecdf4d5fa9c7844
# good: [9732d523212060c44a4723332bdc5ee429eeabc3] Phonet: USB CDC Phonet function for gadget framework
git-bisect good 9732d523212060c44a4723332bdc5ee429eeabc3
# good: [8882d9a60028a9937e9c5652cfb80d4399ce5242] gianfar: Fix packet drop when out of memory
git-bisect good 8882d9a60028a9937e9c5652cfb80d4399ce5242
# good: [c50a5d9aedef5b0b289d07f6d73934d394e50b3f] gianfar: Use interface name in interrupt name to distinguish the source.
git-bisect good c50a5d9aedef5b0b289d07f6d73934d394e50b3f


Here is the output of a bad boot. A good one starts init immediately
after this point.

debug: ignoring loglevel setting.
Using MPC834x MDS machine description
Linux version 2.6.28-rc8-01311-g8c7396a (iws@desk1) (gcc version 4.2.2) #37 Thu Jan 29 11:11:23 PST 2009
Found legacy serial port 0 for /soc8349@e0000000/serial@4500
  mem=e0004500, taddr=e0004500, irq=0, clk=266000000, speed=0
Found legacy serial port 1 for /soc8349@e0000000/serial@4600 
  mem=e0004600, taddr=e0004600, irq=0, clk=266000000, speed=0
console [udbg0] enabled                                      
setup_arch: bootmem    
mpc834x_mds_setup_arch()
arch: exit              
Top of RAM: 0x10000000, Total RAM: 0x10000000
Memory hole size: 0MB                        
Zone PFN ranges:     
  DMA      0x00000000 -> 0x00010000
  Normal   0x00010000 -> 0x00010000
Movable zone start PFN for each node
early_node_map[1] active PFN ranges 
    0: 0x00000000 -> 0x00010000    
On node 0 totalpages: 65536    
free_area_init_node: node 0, pgdat c029c178, node_mem_map c0402000
  DMA zone: 512 pages used for memmap                             
  DMA zone: 0 pages reserved         
  DMA zone: 65024 pages, LIFO batch:15
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 65024
Kernel command line: root=/dev/nfs rw nfsroot=192.168.17.59:/exports/stage3-ppc-2008.0 ip=192.168.17.55:192.168.17.59:192.168.17.1:255.255.255.0:mpc8349emds:eth0:off console=ttyS0,115200 ignore_loglevel
RCU-based detection of stalled CPUs is enabled.
IPIC (128 IRQ sources) at fdff4700             
PID hash table entries: 1024 (order: 10, 4096 bytes)
time_init: decrementer frequency = 66.500000 MHz    
time_init: processor frequency   = 532.000000 MHz
clocksource: timebase mult[3c267f1] shift[22] registered
clockevent: decrementer mult[1106] shift[16] cpu[0]     
Console: colour dummy device 80x25                 
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)  
Memory: 256768k/262144k available (2536k kernel code, 5192k reserved, 140k data, 208k bss, 148k init)
SLUB: Genslabs=12, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
Calibrating delay loop... 132.60 BogoMIPS (lpj=265216)                 
Mount-cache hash table entries: 512                   
net_namespace: 520 bytes           
NET: Registered protocol family 16
                                  
Registering ipic with sysfs...
Freescale Elo / Elo Plus DMA driver
NET: Registered protocol family 2  
Switched to high resolution mode on CPU 0
IP route cache hash table entries: 2048 (order: 1, 8192 bytes)
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)       
TCP: Hash tables configured (established 8192 bind 8192) 
TCP reno registered                                     
NET: Registered protocol family 1
fsl-elo-dma e00082a8.dma: Probe the Freescale DMA driver for fsl,elo-dma controller at e00082a8...
fsl-elo-dma e00082a8.dma: #0 (fsl,elo-dma-channel), irq 71
fsl-elo-dma e00082a8.dma: #1 (fsl,elo-dma-channel), irq 71
fsl-elo-dma e00082a8.dma: #2 (fsl,elo-dma-channel), irq 71
fsl-elo-dma e00082a8.dma: #3 (fsl,elo-dma-channel), irq 71
msgmni has been set to 501                                
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered                                        
io scheduler deadline registered (default)
Serial: 8250/16550 driver4 ports, IRQ sharing disabled
serial8250.0: ttyS0 at MMIO 0xe0004500 (irq = 16) is a 16550A
                                                             console handover: boot [udbg0] -> real [ttyS0]
serial8250.0: ttyS1 at MMIO 0xe0004600 (irq = 17) is a 16550A
brd: module loaded
loop: module loaded
Gianfar MII Bus: probed
Gianfar MII Bus: probed
eth0 (fsl-gianfar): not using net_device_ops yet
eth0: Gianfar Ethernet Controller Version 1.2, 00:04:9f:ef:23:33
eth0: Running with NAPI enabled
eth0: 256/256 RX/TX BD ring size
eth1 (fsl-gianfar): not using net_device_ops yet
eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:7e:21
eth1: Running with NAPI enabled
eth1: 256/256 RX/TX BD ring size
Fixed MDIO Bus: probed
mice: PS/2 mouse device common for all mice
i2c /dev entries driver
talitos e0030000.crypto: hwrng
alg: No test for authenc(hmac(sha1),cbc(aes)) (authenc-hmac-sha1-cbc-aes-talitos)
talitos e0030000.crypto: authenc-hmac-sha1-cbc-aes-talitos
alg: No test for authenc(hmac(sha1),cbc(des3_ede)) (authenc-hmac-sha1-cbc-3des-talitos)
talitos e0030000.crypto: authenc-hmac-sha1-cbc-3des-talitos
alg: No test for authenc(hmac(sha256),cbc(aes)) (authenc-hmac-sha256-cbc-aes-talitos)
talitos e0030000.crypto: authenc-hmac-sha256-cbc-aes-talitos
alg: No test for authenc(hmac(sha256),cbc(des3_ede)) (authenc-hmac-sha256-cbc-3des-talitos)
talitos e0030000.crypto: authenc-hmac-sha256-cbc-3des-talitos
alg: No test for authenc(hmac(md5),cbc(aes)) (authenc-hmac-md5-cbc-aes-talitos)
talitos e0030000.crypto: authenc-hmac-md5-cbc-aes-talitos
alg: No test for authenc(hmac(md5),cbc(des3_ede)) (authenc-hmac-md5-cbc-3des-talitos)
talitos e0030000.crypto: authenc-hmac-md5-cbc-3des-talitos
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
IP-Config: Complete:
     device=eth0, addr=192.168.17.55, mask=255.255.255.0, gw=192.168.17.1,
     host=mpc8349emds, domain=, nis-domain=(none),
     bootserver=192.168.17.59, rootserver=192.168.17.59, rootpath=
Looking up port of RPC 100003/2 on 192.168.17.59
PHY: mdio@24520:00 - Link is Up - 1000/Full

