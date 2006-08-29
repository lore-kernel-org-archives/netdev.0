From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7071] New: Can't bring Sun Quad GigaSwift
 Ethernet interfaces up (Cassini driver)
Date: Tue, 29 Aug 2006 09:29:58 -0700
Message-ID: <20060829092958.0de9c6af.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ludallinux@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56038 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965065AbWH2QaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:30:05 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 29 Aug 2006 09:15:29 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7071] New: Can't bring Sun Quad GigaSwift Ethernet interfaces up (Cassini driver)


http://bugzilla.kernel.org/show_bug.cgi?id=7071

           Summary: Can't bring Sun Quad GigaSwift Ethernet interfaces up
                    (Cassini driver)
    Kernel Version: 2.6.17.11 #2 SMP PREEMPT
            Status: NEW
          Severity: blocking
             Owner: jgarzik@pobox.com
         Submitter: ludallinux@free.fr


Most recent kernel where this bug did not occur:
Distribution: Debian for Sparc
Hardware Environment: Sun Netra T1125
Software Environment: sparc64 GNU/Linux
Problem Description: can't bring Sun Quad GigaSwift Ethernet interfaces up

Steps to reproduce: compile Cassini driver as module, boot and load the cassini 
driver : new interfaces are recognized correctly, and ethtool can see them. 
Then, try to bring up the ethernet interfaces using the "ifconfig" command --> 
ifconfig crashes :

toundra:~# lsmod         
Module                  Size  Used by
toundra:~# modinfo cassini
filename:       /lib/modules/2.6.17.11/kernel/drivers/net/cassini.ko
author:         Adrian Sun (asun@darksunrising.com)
description:    Sun Cassini(+) ethernet driver
license:        GPL
vermagic:       2.6.17.11 SMP preempt mod_unload gcc-4.1
depends:        
alias:          pci:v0000108Ed0000ABBAsv*sd*bc*sc*i*
alias:          pci:v0000100Bd00000035sv*sd*bc*sc*i*
parm:           linkdown_timeout:min reset interval in sec. for PCS linkdown 
issue; disabled if not positive (int)
parm:           link_mode:default link mode (int)
parm:           cassini_debug:Cassini bitmapped debugging message enable value 
(int)
toundra:~# 
toundra:~# modprobe cassini
cassini.c:v1.4 (1 July 2004)
eth0: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[0] 00:14:4f:24:47:a4 
eth1: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[0] 00:14:4f:24:47:a5 
eth2: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[0] 00:14:4f:24:47:a6 
eth3: Sun Cassini+ (64bit/66MHz PCI/Cu) Ethernet[0] 00:14:4f:24:47:a7 

toundra:~# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
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
        Transceiver: internal
        Auto-negotiation: on
        Current message level: 0x000000ff (255)
        Link detected: yes
toundra:~# ifconfig eth1 up
Unable to handle kernel NULL pointer dereference
tsk->{mm,active_mm}->context = 000000000000048e
tsk->{mm,active_mm}->pgd = fffff80080736000
              \|/ ____ \|/
              "@'/ .. \`@"
              /_| \__/ |_\
                 \__U_/
ifconfig(1501): Oops [#1]
TSTATE: 0000000080009605 TPC: 000000000041cf74 TNPC: 000000000041cf78 Y: 
00000000    Not tainted
TPC: <request_irq+0x14/0x500>
g0: 00000000f0000018 g1: 000000000000ae78 g2: fffff800afe0d800 g3: 
fffff800aec56da0
g4: fffff800805d1260 g5: fffff8007fbf2000 g6: fffff800aec2c000 g7: 
fffff800ae5983a0
o0: 0000000000000000 o1: 0000000000000000 o2: 0000000000000001 o3: 
0000000000000002
o4: 0000000000000010 o5: fffff800ae779d20 sp: fffff800aec2eda1 ret_pc: 
0000000010002190
RPC: <cas_spare_recover+0x210/0x2a0 [cassini]>
l0: 0000000000000000 l1: 0000000000000100 l2: fffff800aec504d8 l3: 
fffff800aec2f650
l4: fffff800aec56db0 l5: 00000000f7ea330c l6: fffff800aec504d0 l7: 
00000000f8002000
i0: ffffffffffffffea i1: 0000000010003640 i2: 0000000004000000 i3: 
fffff800aec50000
i4: fffff800aec50000 i5: 104307a000000000 i6: fffff800aec2ee71 i7: 
0000000010007cf4
I7: <cas_open+0x214/0x300 [cassini]>
Caller[0000000010007cf4]: cas_open+0x214/0x300 [cassini]
Caller[0000000000625ff0]: dev_open+0x50/0xc0
Caller[00000000006249c8]: dev_change_flags+0x128/0x180
Caller[0000000000675984]: devinet_ioctl+0x704/0x820
Caller[0000000000618ed8]: sock_ioctl+0x1b8/0x280
Caller[00000000004b18a4]: do_ioctl+0x24/0xa0
Caller[00000000004b198c]: vfs_ioctl+0x6c/0x360
Caller[00000000004b1ca8]: sys_ioctl+0x28/0x60
Caller[00000000004d2e94]: dev_ifsioc+0x54/0x320
Caller[00000000004ce0fc]: compat_sys_ioctl+0xdc/0x3a0
Caller[0000000000406c14]: linux_sparc_syscall32+0x34/0x40
Caller[0000000000011330]: 0x11330
Instruction DUMP: 02c64022  b0103fea  a1322000 <c25c2008> 02c0401e  b0103fed  
27001c30  8214e140  80a40001 
Killed
toundra:~#

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
