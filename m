From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: bnx2x null pointer dereference
Date: Thu, 31 Jul 2008 16:49:52 -0600
Message-ID: <200807311649.53177.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Justin Chen <justin.chen@hp.com>,
	Bill Hayes <bill.hayes@hp.com>,
	Myron Stowe <myron.stowe@hp.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:5162 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758520AbYGaWuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 18:50:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The crash below occurred because "params->bp == NULL" in
bnx2x_update_mng().  This is with the 1.45.11 driver version
on a RHEL 5.2 kernel.

This is on a prototype ia64 box, and I'm told that there's
some bnx2x firmware that is missing from the system firmware,
so this might be a "we don't care about this problem because
users will never see this situation" sort of thing.

But it is annoying that it crashes the box rather than just
causing the driver to ignore the device.

Bjorn


[root@fstldhcp175 ~]# lsmod | grep bnx
[root@fstldhcp175 ~]# modprobe bnx2x
[bnx2x_get_hwinfo:7653(eth2)]warning constant MAC workaround active
bnx2x: MCP disabled, must load devices in order!
[bnx2x_get_hwinfo:7653(eth3)]warning constant MAC workaround active
[bnx2x_get_hwinfo:7653(eth8)]warning constant MAC workaround active
bnx2x: MCP disabled, must load devices in order!
[bnx2x_get_hwinfo:7653(eth9)]warning constant MAC workaround active
[root@fstldhcp175 ~]# ip[6870]: NaT consumption 17179869216 [1]
Modules linked in: bnx2x(U) autofs4 hidp rfcomm l2cap bluetooth sunrpc ipv6 xfrm_nalgo crypto_api vfat fat dm_multipath button parport_pc lp parport sg igb e1000e shpchp dm_snapshot dm_zero dm_mirror dm_mod qla2xxx scsi_transport_fc sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd

Pid: 6870, CPU 3, comm:                   ip
psr : 0000101008526030 ifs : 8000000000000007 ip  : [<a000000208b44570>]    Tainted: G     
ip is at bnx2x_update_mng+0x30/0x60 [bnx2x]
unat: 0000000000000000 pfs : 0000000000000817 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000065a659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000208b55c50 b6  : a000000208b2c9c0 b7  : a00000010000b820
f6  : 1003e0000000000000000 f7  : 0fff1b100040000000000
f8  : 10015b100040000000000 f9  : 0ffff8000000000000000
f10 : 10015b10003fff4efffc0 f11 : 1003e0000000000588002
r1  : a000000208b6c638 r2  : 0000000000000200 r3  : 000000000000ff00
r8  : 00000000000005a0 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : e00010000eecfd80 r13 : e00010000eec8000
r14 : 0000000000000300 r15 : 0000000000000664 r16 : 0000000000000000
r17 : e00010000cb92d20 r18 : e00010000cb92d40 r19 : 000000000000ff00
r20 : e00010000cb92d14 r21 : e00010000cb92d04 r22 : e00010000cb92d10
r23 : e00010000cb92d20 r24 : a000000208b6706c r25 : 0000000000000188
r26 : a000000208b6706c r27 : 0000000000000000 r28 : a000000208b67d08
r29 : 000000000100f402 r30 : a000000208b67d0a r31 : 0000000000000001

Call Trace:
 [<a000000100013ae0>] show_stack+0x40/0xa0
                                sp=e00010000eecf7a0 bsp=e00010000eec9688
 [<a0000001000143e0>] show_regs+0x840/0x880
                                sp=e00010000eecf970 bsp=e00010000eec9630
 [<a000000100037bc0>] die+0x1c0/0x2c0
                                sp=e00010000eecf970 bsp=e00010000eec95e0
 [<a000000100037d10>] die_if_kernel+0x50/0x80
                                sp=e00010000eecf990 bsp=e00010000eec95b0
 [<a000000100633280>] ia64_fault+0x1160/0x1280
                                sp=e00010000eecf990 bsp=e00010000eec9558
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                                sp=e00010000eecfbb0 bsp=e00010000eec9558
 [<a000000208b44570>] bnx2x_update_mng+0x30/0x60 [bnx2x]
                                sp=e00010000eecfd80 bsp=e00010000eec9520
 [<a000000208b55c50>] bnx2x_link_reset+0x90/0x520 [bnx2x]
                                sp=e00010000eecfd80 bsp=e00010000eec94a0
 [<a000000208b1e230>] bnx2x__link_reset+0x50/0x80 [bnx2x]
                                sp=e00010000eecfd80 bsp=e00010000eec9480
 [<a000000208b34b30>] bnx2x_init_hw+0x930/0x1600 [bnx2x]
                                sp=e00010000eecfd80 bsp=e00010000eec9430
 [<a000000208b36cc0>] bnx2x_nic_load+0x14c0/0x2580 [bnx2x]
                                sp=e00010000eecfdb0 bsp=e00010000eec93c8
 [<a000000208b396b0>] bnx2x_open+0x50/0x80 [bnx2x]
                                sp=e00010000eecfdd0 bsp=e00010000eec93a8
 [<a000000100525470>] dev_open+0xf0/0x1e0
                                sp=e00010000eecfdd0 bsp=e00010000eec9388
 [<a00000010051f740>] dev_change_flags+0xc0/0x240
                                sp=e00010000eecfdd0 bsp=e00010000eec9348
 [<a0000001005d2080>] devinet_ioctl+0x5a0/0xfe0
                                sp=e00010000eecfdd0 bsp=e00010000eec92e8
 [<a0000001005d33c0>] inet_ioctl+0x180/0x220
                                sp=e00010000eecfe10 bsp=e00010000eec92b8
 [<a000000100505fc0>] sock_ioctl+0x5a0/0x620
                                sp=e00010000eecfe10 bsp=e00010000eec9288
 [<a000000100192590>] do_ioctl+0x90/0x180
                                sp=e00010000eecfe10 bsp=e00010000eec9248
 [<a000000100192f00>] vfs_ioctl+0x880/0x8e0
                                sp=e00010000eecfe10 bsp=e00010000eec9200
 [<a000000100193030>] sys_ioctl+0xd0/0x140
                                sp=e00010000eecfe20 bsp=e00010000eec9178
 [<a00000010000bdb0>] __ia64_trace_syscall+0xd0/0x110
                                sp=e00010000eecfe30 bsp=e00010000eec9178
 [<a000000000010620>] __start_ivt_text+0xffffffff00010620/0x400
                                sp=e00010000eed0000 bsp=e00010000eec9178
 <0>Kernel panic - not syncing: Fatal exception
