From: Steve Wise <swise@opengridcomputing.com>
Subject: cxgb3 regression in 2.6.22-rc5
Date: Mon, 18 Jun 2007 12:05:41 -0500
Message-ID: <4676BB65.7070603@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:39788 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752923AbXFRRhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 13:37:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I get this crash running the chelsio cxgb3 module on 2.6.22-rc5.  This 
is regression.  I believe Divy from Chelsio has already posted a fix for 
this.  This needs to be in 2.6.22...

Jeff do you have this fix queued for 2.6.22?

I think Divy's patches are here:

http://lkml.org/lkml/2007/5/30/291

and here:

http://lkml.org/lkml/2007/6/5/211


Thanks,

Steve.



----

Unable to handle kernel NULL pointer dereference at 0000000000000220 RIP:
  [<ffffffff881f34f9>] :cxgb3:process_responses+0x6a3/0xa06
PGD 73d98067 PUD 0
Oops: 0002 [1] SMP
CPU 0
Modules linked in: iw_cxgb3 cxgb3 parport_pc lp parport autofs4 sunrpc 
rdma_ucm rdma_cm iw_cm ib_addr dm_multipath button battery ac i2c_i801 
i2c_core ib_mthca ib_ipoib ib_umad ib_ucm ib_uverbs ib_cm ib_sa ib_mad 
ib_core e1000 floppy dm_snapshot dm_zero dm_mirror ext3 jbd dm_mod 
ata_piix libata sd_mod scsi_mod
Pid: 0, comm: swapper Not tainted 2.6.22-rc5-g802c7fc4 #1
RIP: 0010:[<ffffffff881f34f9>]  [<ffffffff881f34f9>] 
:cxgb3:process_responses+0x6a3/0xa06
RSP: 0018:ffffffff8059be00  EFLAGS: 00010206
RAX: 0000000100012ecf RBX: ffff81006f9c77c0 RCX: ffff81006f9c8a00
RDX: 0000000000000000 RSI: ffff8100702b9046 RDI: ffff81006f9c77c0
RBP: ffff81006f9c8a02 R08: 0000000000000000 R09: ffff81006f9c77c0
R10: 0000000000000000 R11: ffffffff804d2080 R12: ffff81006f98c480
R13: ffff810070350000 R14: 0000000000000046 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffffffff80516000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000220 CR3: 0000000073d97000 CR4: 00000000000006e0
Process swapper (pid: 0, threadinfo ffffffff8053e000, task ffffffff804d2080)
Stack:  0000000000000000 ffff8100026374b0 0000000000000000 0000002b00000000
  0000000283000000 0000000000000001 0000004000000000 ffff8100701c0100
  0000004002637440 ffff81006f98c000 ffff810002637440 0000000000000000
Call Trace:
  <IRQ>  [<ffffffff8041482e>] __lock_text_start+0x6/0x10
  [<ffffffff80223c02>] run_rebalance_domains+0x3f4/0x434
  [<ffffffff881f3892>] :cxgb3:napi_rx_handler+0x36/0xb6
  [<ffffffff803b3559>] net_rx_action+0xb1/0x167
  [<ffffffff8022e839>] __do_softirq+0x50/0xbb
  [<ffffffff8020a42c>] call_softirq+0x1c/0x28
  [<ffffffff8020b5e9>] do_softirq+0x2e/0x95
  [<ffffffff8020b5a3>] do_IRQ+0xb7/0xcf
  [<ffffffff80207bc5>] mwait_idle+0x0/0x42
