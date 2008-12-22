From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: net-next: mii-tool qweasd: Unable to handle kernel NULL ptr dereference
Date: Mon, 22 Dec 2008 01:59:19 +0100
Message-ID: <m3y6y9qb2w.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36342 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbYLVA7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2008 19:59:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm...

IXP4xx (ARM), basically net-next:

# mii-tool qweasd

Unable to handle kernel NULL pointer dereference at virtual address 000000b4
pgd = c66b4000
[000000b4] *pgd=066eb031, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1]
Modules linked in: ixp4xx_hss ixp4xx_eth ixp4xx_npe ixp4xx_qmgr e1000
CPU: 0    Not tainted  (2.6.28-rc8 #81)
PC is at dev_ifsioc+0x24/0x3f8
LR is at 0xb
pc : [<c0268530>]    lr : [<0000000b>]    psr: 60000013
sp : c6701e4c  ip : d38cb615  fp : c6701e64
r10: 000124e8  r9 : 000125a4  r8 : 00000000
r7 : c6701e8c  r6 : c6701e8c  r5 : 00000000  r4 : 00008947
r3 : 00000033  r2 : 00000064  r1 : 00000006  r0 : 00000000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0000397f  Table: 066b4000  DAC: 00000015
Process mii-tool (pid: 372, stack limit = 0xc6700268)
Stack: (0xc6701e4c to 0xc6702000)
1e40:                            00008947 c0469630 00000000 c6701edc c6701e68 
1e60: c0269038 c0268518 c6701e98 c6701e78 c0116864 c00eca20 c663801c c78b6940 
1e80: 00000015 c68d333c c044dd74 61657771 00006473 00000000 00000000 00000000 
1ea0: 00000000 00000000 00000000 c00fbadc c6700000 00008947 fffffdfd 000125a4 
1ec0: c65ca83c c00e8004 c6700000 000124e8 c6701ef8 c6701ee0 c02577cc c0268910 
1ee0: c65ca83c 00008947 000125a4 c6701f14 c6701efc c0153fc8 c0257738 00000003 
1f00: c65ca83c 000125a4 c6701f80 c6701f18 c01543ac c0153fa0 00000000 00000000 
1f20: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
1f40: 00000000 00000000 00000000 00000000 00000000 00000000 00000003 000125a4 
1f60: 00008947 c65ca83c c00e8004 c6700000 000124e8 c6701fa4 c6701f84 c015452c 
1f80: c0154040 00000000 00000000 00000003 bec31f7e 00000036 00000000 c6701fa8 
1fa0: c00e7fcc c01544f8 00000000 00000003 00000003 00008947 000125a4 000125b3 
1fc0: 00000000 00000003 bec31f7e bec31ebc 000124e0 bec31eb4 000124e8 00012518 
1fe0: 400e2290 bec31de0 00009208 400e2294 60000010 00000003 00000000 00000000 
Backtrace: 
[<c026850c>] (dev_ifsioc+0x0/0x3f8) from [<c0269038>] (dev_ioctl+0x734/0x88c)
 r6:00000000 r5:c0469630 r4:00008947
[<c0268904>] (dev_ioctl+0x0/0x88c) from [<c02577cc>] (sock_ioctl+0xa0/0x268)
[<c025772c>] (sock_ioctl+0x0/0x268) from [<c0153fc8>] (vfs_ioctl+0x34/0x78)
 r6:000125a4 r5:00008947 r4:c65ca83c
[<c0153f94>] (vfs_ioctl+0x0/0x78) from [<c01543ac>] (do_vfs_ioctl+0x378/0x4b8)
 r6:000125a4 r5:c65ca83c r4:00000003
[<c0154034>] (do_vfs_ioctl+0x0/0x4b8) from [<c015452c>] (sys_ioctl+0x40/0x68)
[<c01544ec>] (sys_ioctl+0x0/0x68) from [<c00e7fcc>] (__sys_trace_return+0x0/0x34
)
 r7:00000036 r6:bec31f7e r5:00000003 r4:00000000
Code: ebfff3a3 e2443c89 e2433014 e1a05000 (e59010b4) 
---[ end trace d056cfda3cfe4acb ]---

strace says:
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
ioctl(3, SIOCGMIIPHY <unfinished ...>
+++ killed by SIGSEGV +++

I can bisect this but perhaps someone already knows what's wrong?
-- 
Krzysztof Halasa
