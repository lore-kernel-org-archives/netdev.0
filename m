From: Pavan Naregundi <pavan@linux.vnet.ibm.com>
Subject: system hangs while executing 'rmmod ehea'
Date: Fri, 24 Jul 2009 17:13:44 +0530
Message-ID: <4A699E70.2090900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: HERING2@de.ibm.com, THEMANN@de.ibm.com, TKLEIN@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:52780 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbZGXLn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 07:43:59 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n6OBfNr1015109
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 21:41:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6OBhwns397802
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 21:43:58 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6OBhv3Q018386
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 21:43:57 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Everyone,

System hanged while executing "rmmod ehea" command as explained below,

This problem is seen on all the System P machines using ehea driver.

IBM eHEA ethernet device driver (Release EHEA_0101)
 
=================
mjs22lp5:~ # ifconfig 
eth2      Link encap:Ethernet  HWaddr 00:1A:64:45:89:04  
          inet addr:9.126.89.223  Bcast:9.126.89.255  Mask:255.255.255.0
          inet6 addr: fe80::21a:64ff:fe45:8904/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:430 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:51856342052 (49454.0 Mb)  TX bytes:72696983018 (69329.2 Mb)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:2 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:100 (100.0 b)  TX bytes:100 (100.0 b)

mjs22lp5:~ # ifdown eth2
    eth2      name: IBM Host Ethernet Adapter Port 0
mjs22lp5:~ # ifup eth2
    eth2      name: IBM Host Ethernet Adapter Port 0
mjs22lp5:~ # ifdown eth2
    eth2      name: IBM Host Ethernet Adapter Port 0
mjs22lp5:~ # dmesg 
ehea: eth2: Logical port down
ehea: eth2: Physical port up
ehea: External switch port is backup port
ehea: eth2: Logical port up: 1000Mbps Full Duplex
ehea: eth2: Physical port up
ehea: External switch port is backup port
irq: irq 775 on host null mapped to virtual irq 263
irq: irq 776 on host null mapped to virtual irq 264
ehea: eth2: Logical port down
ehea: eth2: Physical port up
ehea: External switch port is backup port
mjs22lp5:~ # rmmod ehea
SysRq : Entering xmon
cpu 0x0: Vector: 501 (Hardware Interrupt) at [c000000000f23b40]
    pc: c00000000000e538: .raw_local_irq_restore+0x78/0x8c
    lr: c0000000000144f8: .cpu_idle+0x118/0x1bc
    sp: c000000000f23dc0
   msr: 8000000000009032
  current = 0xc000000000e55450
  paca    = 0xc000000001002400
    pid   = 0, comm = swapper
enter ? for help
[c000000000f23dc0] c0000000000144f8 .cpu_idle+0x118/0x1bc (unreliable)
[c000000000f23e60] c000000000009eb0 .rest_init+0x94/0xc4
[c000000000f23ee0] c000000000840cd4 .start_kernel+0x444/0x468
[c000000000f23f90] c0000000000083ec .start_here_common+0x1c/0x30
0:mon> c
cpus stopped: 0-3
0:mon> c 1
1:mon> t
[c000000040457e30] c0000000000144f8 .cpu_idle+0x118/0x1bc (unreliable)
[c000000040457ed0] c0000000005d0614 .start_secondary+0x36c/0x3ac
[c000000040457f90] c0000000000082d4 .start_secondary_prolog+0x10/0x14
1:mon> c 3
3:mon> t
[c00000004045fe30] c0000000000144f8 .cpu_idle+0x118/0x1bc (unreliable)
[c00000004045fed0] c0000000005d0614 .start_secondary+0x36c/0x3ac
[c00000004045ff90] c0000000000082d4 .start_secondary_prolog+0x10/0x14
3:mon> c 2
2:mon> t
[c00000003c4f75e0] c0000000005191b8 .netif_napi_del+0x54/0xb0 (unreliable)
[c00000003c4f7680] c0000000005192cc .free_netdev+0xb8/0x14c
[c00000003c4f7720] d0000000010b0af4 .ehea_shutdown_single_port+0x74/0xa4 [ehea]
[c00000003c4f77b0] d0000000010ba870 .ehea_remove+0x60/0x130 [ehea]
[c00000003c4f7860] c0000000004fef98 .of_platform_device_remove+0x58/0x78
[c00000003c4f78f0] c00000000043c1b4 .__device_release_driver+0xc8/0x138
[c00000003c4f7990] c00000000043c310 .driver_detach+0xec/0x154
[c00000003c4f7a40] c00000000043ac90 .bus_remove_driver+0xd4/0x130
[c00000003c4f7ae0] c00000000043cc20 .driver_unregister+0xa0/0xc8
[c00000003c4f7b80] c0000000004ff160 .of_unregister_driver+0x2c/0x48
[c00000003c4f7c10] c00000000002b380 .ibmebus_unregister_driver+0x2c/0x48
[c00000003c4f7ca0] d0000000010ba790 .ehea_module_exit+0x4c/0xcc [ehea]
[c00000003c4f7d30] c0000000000dd0f8 .SyS_delete_module+0x21c/0x2c0
[c00000003c4f7e30] c000000000008534 syscall_exit+0x0/0x40
--- Exception: c01 (System Call) at 00000fff9fb6b3d0
SP (fffeccb0710) is in userspace
2:mon> e
cpu 0x2: Vector: 501 (Hardware Interrupt) at [c00000003c4f7360]
    pc: c00000000050e1f4: .kfree_skb+0xe4/0xf4
    lr: c0000000005191b8: .netif_napi_del+0x54/0xb0
    sp: c00000003c4f75e0
   msr: 8000000000009032
  current = 0xc00000003c303ac0
  paca    = 0xc000000001002800
    pid   = 3138, comm = rmmod
2:mon> r
R00 = c0000000005191b8   R07 = c000000040371fe0
R01 = c00000003c4f75e0   R08 = 0000000000000005
R02 = c000000000f161d0   R09 = c000000040568708
R03 = 0000000000000000   R10 = c000000040568228
R04 = c000000001493468   R11 = c000000040568708
R05 = c000000000e5e780   R12 = d0000000010bb6a8
R06 = c0000000404f3e00   R13 = c000000001002800
pc  = c00000000050e1f4 .kfree_skb+0xe4/0xf4
lr  = c0000000005191b8 .netif_napi_del+0x54/0xb0
msr = 8000000000009032   cr  = 44000822
ctr = c000000000519214   xer = 0000000020000020   trap =  501
2:mon> di %pc 20
c00000000050e1f4  eba1ffe8      ld      r29,-24(r1)
c00000000050e1f8  ebc1fff0      ld      r30,-16(r1)
c00000000050e1fc  ebe1fff8      ld      r31,-8(r1)
c00000000050e200  4e800020      blr
c00000000050e204  7c0802a6      mflr    r0
c00000000050e208  f8010010      std     r0,16(r1)
c00000000050e20c  fb41ffd0      std     r26,-48(r1)
c00000000050e210  fb61ffd8      std     r27,-40(r1)
c00000000050e214  fb81ffe0      std     r28,-32(r1)
c00000000050e218  fba1ffe8      std     r29,-24(r1)
c00000000050e21c  fbc1fff0      std     r30,-16(r1)
c00000000050e220  fbe1fff8      std     r31,-8(r1)
c00000000050e224  f821ff51      stdu    r1,-176(r1)
c00000000050e228  7c3f0b78      mr      r31,r1
c00000000050e22c  ebc2ca50      ld      r30,-13744(r2)
c00000000050e230  7c7d1b78      mr      r29,r3
c00000000050e234  7c9a2378      mr      r26,r4
c00000000050e238  60000000      nop
 ...
c00000000050e240  eb7d0010      ld      r27,16(r29)
c00000000050e244  2fbb0000      cmpdi   cr7,r27,0
c00000000050e248  419e0154      beq     cr7,c00000000050e39c    #
.skb_tstamp_tx+0x198/0x1c0
c00000000050e24c  7fa3eb78      mr      r3,r29
c00000000050e250  38800020      li      r4,32
c00000000050e254  4bfffc61      bl      c00000000050deb4        #
.skb_clone+0x0/0xdc
c00000000050e258  7c7c1b79      mr.     r28,r3
c00000000050e25c  41820140      beq     c00000000050e39c        #
.skb_tstamp_tx+0x198/0x1c0
c00000000050e260  2fba0000      cmpdi   cr7,r26,0
c00000000050e264  419e0024      beq     cr7,c00000000050e288    #
.skb_tstamp_tx+0x84/0x1c0
c00000000050e268  801c00d4      lwz     r0,212(r28)
c00000000050e26c  e97c00d8      ld      r11,216(r28)
c00000000050e270  e93a0000      ld      r9,0(r26)
2:mon> 
====================

# uname -a
Linux mjs22lp5 2.6.31-rc4-next-20090723 #1 SMP Thu Jul 23 14:37:21 IST 2009
ppc64 ppc64 ppc64 GNU/Linux



Steps to reproduce:
1. Say, eth0 which is using ehea 
2. ifdown eth0
3. ifup eth0
4. ifdown eth0
5. rmmod ehea        // This command should hang the system

