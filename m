From: Andrew Morton <akpm@osdl.org>
Subject: e1000 breakage in git-netdev-all
Date: Mon, 17 Apr 2006 23:41:47 -0700
Message-ID: <20060417234147.6c1802de.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20691 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932254AbWDRGmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 02:42:31 -0400
To: John Ronciak <john.ronciak@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A bunch of e1000 changes just hit Jeff's tree.

I hit this.

skb_over_panic: text:ffffffff803b7dc5 len:3028 put:1514 head:ffff81017f83e870 data:ffff81017f83e882 tail:ffff81017f83f456 end:ffff81017f83ee70 dev:eth0
----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at net/core/skbuff.c:94
invalid opcode: 0000 [1] PREEMPT SMP 
last sysfs file: /class/vc/vcsa5/dev
CPU 3 
Modules linked in: pcmcia yenta_socket rsrc_nonstatic pcmcia_core video sony_acpi
Pid: 11697, comm: cc1 Not tainted 2.6.17-rc1-mm3 #66
RIP: 0010:[<ffffffff8043f2d6>] <ffffffff8043f2d6>{skb_over_panic+78}
RSP: 0000:ffff81017fd1be28  EFLAGS: 00010292
RAX: 000000000000009b RBX: 0000000000000000 RCX: 0000000000000213
RDX: ffffffff805ddad8 RSI: 0000000000000213 RDI: 0000000000000001
RBP: ffff81017fd1be48 R08: ffffffff805ddad8 R09: 0000000000000061
R10: 0000000000000061 R11: 0000000000000000 R12: ffff81017fb31500
R13: ffff81017f8e4548 R14: 00000000000005ea R15: 000000000000003b
FS:  00002b7e4f259b00(0000) GS:ffff81017fc74b20(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00002b7e547db000 CR3: 000000016098a000 CR4: 00000000000006e0
Process cc1 (pid: 11697, threadinfo ffff81015c6aa000, task ffff8101791120d0)
Stack: ffff81017f83f456 ffff81017f83ee70 ffff81017fb31000 ffff81017f83f456 
       ffff81017fd1bed8 ffffffff803b7dd0 23ff81017fd1be68 0000000100000001 
       ffffc20000010760 ffffc20000010740 
Call Trace: <IRQ> <ffffffff803b7dd0>{e1000_clean_rx_irq+836}
       <ffffffff803b79be>{e1000_intr+173} <ffffffff8024f26b>{handle_IRQ_event+48}
       <ffffffff8024f344>{__do_IRQ+163} <ffffffff8020bcd5>{do_IRQ+50}
       <ffffffff80209d84>{ret_from_intr+0} <EOI>

Code: 0f 0b 68 2b 74 52 80 c2 5e 00 c9 c3 55 49 89 d2 48 89 e5 52 
RIP <ffffffff8043f2d6>{skb_over_panic+78} RSP <ffff81017fd1be28>

The machine was being used as a distcc server at the time - just basic TCP
stuff.

I'll drop Jeff's tree for now.  Please let me know when we have a fix.
