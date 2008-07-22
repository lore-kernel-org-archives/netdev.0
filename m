From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: netif_schedule and mpc5200_fec
Date: Tue, 22 Jul 2008 15:47:51 -0400
Message-ID: <9e4733910807221247r38509c76uf625195b712a1145@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: ppc-dev <Linuxppc-dev@ozlabs.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:53672 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbYGVTrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 15:47:52 -0400
Received: by yw-out-2324.google.com with SMTP id 9so867090ywe.1
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 12:47:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just updated to linus/master and mpc5200_fec won't boot.

Guessing it is this patch but I haven't looked at it yet.

commit 263ba3204a434d0ca851e1321b31cd58376b86cb
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jul 15 03:47:41 2008 -0700

    netdev: Convert all drivers away from netif_schedule().

    They logically all want to trigger a schedule for all device
    TX queues.

    Signed-off-by: David S. Miller <davem@davemloft.net>


Sending DHCP requests .<0>------------[ cut here ]------------
Badness at c01da570 [verbose debug info unavailable]
NIP: c01da570 LR: c015b31c CTR: c015b234
REGS: c382de70 TRAP: 0700   Not tainted  (2.6.26-efika)
MSR: 00029032 <EE,ME,IR,DR>  CR: 22000082  XER: 00000000
TASK = c3815000[4] 'events/0' THREAD: c382c000
GPR00: 00000001 c382df20 c3815000 c031e468 c38f25a0 00000000 00000000 00000000
GPR08: c382dfb4 c0330000 00000000 c031e468 3181b461 ffffffff 03ffe000 ffffffff
GPR16: 00000001 00000000 007ffc00 00000000 00000000 03ff8838 00000000 00000004
GPR24: 00000000 00000000 c032b46c c0330000 c38a2e00 00000001 c38f2780 c38f2400
NIP [c01da570] __netif_schedule+0x3c/0xac
LR [c015b31c] mpc52xx_fec_adjust_link+0xe8/0x194
Call Trace:
[c382df20] [c002eeb0] queue_work+0x58/0x6c (unreliable)
[c382df40] [c015b31c] mpc52xx_fec_adjust_link+0xe8/0x194
[c382df60] [c0158cd0] phy_state_machine+0xec/0x4e0
[c382df80] [c002eb0c] run_workqueue+0xb4/0x148
[c382dfa0] [c002f070] worker_thread+0x9c/0xb8
[c382dfd0] [c0032954] kthread+0x4c/0x88
[c382dff0] [c000f538] kernel_thread+0x44/0x60
Instruction dump:
7c6b1b78 3929e468 7f834800 39200002 90010024 38030024 bfa10014 40be0030
3d20c033 80099988 7c000034 5400d97e <0f000000> 2f800000 41be0054 38000001
PHY: f0003000:00 - Link is Up - 100/Full
., OK


-- 
Jon Smirl
jonsmirl@gmail.com
