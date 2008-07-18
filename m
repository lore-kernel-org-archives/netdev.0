From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: READ ME, net-2.6 fully merged
Date: Fri, 18 Jul 2008 17:51:28 +0100
Message-ID: <20080718165128.GC10471@solarflare.com>
References: <20080718.033947.193705552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:40326 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751465AbYGRQvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 12:51:33 -0400
Content-Disposition: inline
In-Reply-To: <20080718.033947.193705552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> 
> I merged Linus's current tree into net-next-2.6, fixed up all
> the merge conflicts, and pushed this out as plain "net-2.6":
> 
> 	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

When I attempted to boot this on a test machine I got the following oops:

Fri Jul 18 17:44:51 2008 ------------[ cut here ]------------
Fri Jul 18 17:44:51 2008 kernel BUG at net/core/dev.c:1328!
Fri Jul 18 17:44:51 2008 invalid opcode: 0000 [#1] SMP
Fri Jul 18 17:44:51 2008 Modules linked in: xt_tcpudp ip6table_filter ip6_tables x_tables ipv6 ext2 floppy sfc e1000 i2c_algo_bit inet_lro mii shpchp button i2c_i801 i2c_core pcspkr ata_piix libata sd_mod scsi_mod dock ehci_hcd ohci_hcd uhci_hcd [last unloaded: microcode]
Fri Jul 18 17:44:51 2008
Fri Jul 18 17:44:51 2008 Pid: 0, comm: swapper Not tainted (2.6.26 #106)
Fri Jul 18 17:44:51 2008 EIP: 0060:[<c036e4fc>] EFLAGS: 00010246 CPU: 1
Fri Jul 18 17:44:51 2008 EIP is at __netif_schedule+0xd/0x44
Fri Jul 18 17:44:51 2008 EAX: c048b780 EBX: f6e742c0 ECX: c048b780 EDX: 00003938
Fri Jul 18 17:44:51 2008 ESI: f6f06460 EDI: 00000100 EBP: f784fedc ESP: f784fed8
Fri Jul 18 17:44:51 2008  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Fri Jul 18 17:44:51 2008 Process swapper (pid: 0, ti=f784e000 task=f7831c80 task.ti=f784e000)
Fri Jul 18 17:44:51 2008 Stack: f6e742c0 f784fefc f889092f f6f06000 f6e74740 f7846000 f6f06460 f7846000
Fri Jul 18 17:44:51 2008        00000100 f784ff1c c0226a9d f88906a6 f784ff08 f784ff08 00000001 c04949c4
Fri Jul 18 17:44:51 2008        0000000a f784ff34 c0223701 00000001 00000046 00000000 00000000 f784ff40
Fri Jul 18 17:44:51 2008 Call Trace:
Fri Jul 18 17:44:51 2008  [<f889092f>] ? e1000_watchdog+0x289/0x5eb [e1000]
Fri Jul 18 17:44:51 2008  [<c0226a9d>] ? run_timer_softirq+0xfd/0x158
Fri Jul 18 17:44:51 2008  [<f88906a6>] ? e1000_watchdog+0x0/0x5eb [e1000]
Fri Jul 18 17:44:51 2008  [<c0223701>] ? __do_softirq+0x64/0xcd
Fri Jul 18 17:44:51 2008  [<c022379f>] ? do_softirq+0x35/0x3a
Fri Jul 18 17:44:51 2008  [<c0223a2d>] ? irq_exit+0x38/0x3a
Fri Jul 18 17:44:51 2008  [<c020f5dd>] ? smp_apic_timer_interrupt+0x71/0x80
Fri Jul 18 17:44:51 2008  [<c0203710>] ? apic_timer_interrupt+0x28/0x30
Fri Jul 18 17:44:51 2008  [<c021007b>] ? balanced_irq+0x2da/0x4ae
Fri Jul 18 17:44:51 2008  [<c02083a3>] ? mwait_idle+0x35/0x3e
Fri Jul 18 17:44:51 2008  [<c02018f2>] ? cpu_idle+0xa4/0xbc
Fri Jul 18 17:44:51 2008  [<c03cd169>] ? start_secondary+0x169/0x16e
Fri Jul 18 17:44:51 2008  =======================
Fri Jul 18 17:44:51 2008 Code: b8 a0 6c 4d c0 01 c2 8b 42 28 89 01 b8 02 00 00 00 89 4a 28 e8 df 50 eb ff 53 9d 5b 5d c3 55 3d 80 b7 48 c0 89 e5 89 c1 53 75 04 <0f> 0b eb fe f0 0f ba 68 20 01 19 c0 85 c0 75 24
9c 5b fa 64 8b
Fri Jul 18 17:44:51 2008 EIP: [<c036e4fc>] __netif_schedule+0xd/0x44 SS:ESP 0068:f784fed8
Fri Jul 18 17:44:51 2008 Kernel panic - not syncing: Fatal exception in interrupt

The line is:
	BUG_ON(q == &noop_qdisc);

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
