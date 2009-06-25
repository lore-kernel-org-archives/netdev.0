From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13623] New: Oops while changing mtu
Date: Thu, 25 Jun 2009 11:35:19 -0700
Message-ID: <20090625113519.f0ebbed5.akpm@linux-foundation.org>
References: <bug-13623-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	bryanhundven@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49854 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbZFYSfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 14:35:19 -0400
In-Reply-To: <bug-13623-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 25 Jun 2009 17:02:59 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13623
> 
>            Summary: Oops while changing mtu
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: bryanhundven@gmail.com
>         Regression: No
> 
> 
> HostA has an MTU of 9000 (jumbo frames).
> HostB (with sky2 driver) has MTU of 9000.
> 
> While HostA runs 'hping3 -d 65000 --flood -1 HostB', change MTU on HostB to
> 1500.
> 
> HostB should just drop packets, since it is receiving the wrong MTU size.
> Instead, we get oops.
> 

This looks like a sky2 bug.

> tacoma:~# ifconfig eth1 mtu 1500
> tacoma:~# [ 1605.000027] skb_over_panic: text:e0049c12 len:9010 put:9010 head:ddf24800 data:ddf24820 tail:0xddf26b52 end:0xddf24e20 dev:eth1
> [ 1605.011622] ------------[ cut here ]------------
> [ 1605.015593] kernel BUG at net/core/skbuff.c:126!
> [ 1605.015593] invalid opcode: 0000 [#1]
> [ 1605.015593] last sysfs file: /sys/class/net/lo/operstate
> [ 1605.015593] Modules linked in: iptable_filter ip_tables x_tables ipv6 evdev parport_pc parport i2c_i801 snd_pcm i2c_core snd_timer serio_raw iTCO_wdt snd soundcore snd_page_alloc rng_core intel_agp agpgart pcspkr ext3 jbd mbcache sd_mod piix ide_pci_generic ide_core ata_generic ata_piix uhci_hcd ehci_hcd libata skge scsi_mod usbcore sky2 thermal_sys
> [ 1605.015593]
> [ 1605.015593] Pid: 0, comm: swapper Not tainted (2.6.30 #1)
> [ 1605.015593] EIP: 0060:[<c027a4fc>] EFLAGS: 00010296 CPU: 0
> [ 1605.015593] EIP is at skb_put+0x5f/0x6a
> [ 1605.015593] EAX: 00000086 EBX: e0049c12 ECX: c03c3ec4 EDX: c0367c09
> [ 1605.015593] ESI: 000005f0 EDI: 00002332 EBP: de6e4b00 ESP: c03c3ec0
> [ 1605.015593]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> [ 1605.015593] Process swapper (pid: 0, ti=c03c2000 task=c038f2fc task.ti=c03c2000)
> [ 1605.015593] Stack:
> [ 1605.015593]  c0367c09 e0049c12 00002332 00002332 ddf24800 ddf24820 ddf26b52 ddf24e20
> [ 1605.015593]  dd9e2800 ddbdba40 e0049c12 00000040 dd85e908 00000040 0000044b dd85e900
> [ 1605.015593]  00000000 00000286 23320100 dd9e2800 dda82248 dd9e2b40 00000000 ddb98000
> [ 1605.015593] Call Trace:
> [ 1605.015593]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.015593]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.015593]  [<c012a1a0>] ? delayed_work_timer_fn+0x0/0x30
> [ 1605.015593]  [<c027edb8>] ? net_rx_action+0x6c/0x128
> [ 1605.015593]  [<c0121ff2>] ? __do_softirq+0x82/0x125
> [ 1605.015593]  [<c01220c2>] ? do_softirq+0x2d/0x37
> [ 1605.015593]  [<c0122185>] ? irq_exit+0x25/0x4e
> [ 1605.015593]  [<c010e641>] ? smp_apic_timer_interrupt+0x60/0x68
> [ 1605.015593]  [<c01035ea>] ? apic_timer_interrupt+0x2a/0x30
> [ 1605.015593]  [<c0130000>] ? unregister_reboot_notifier+0x3/0xc
> [ 1605.015593]  [<c0113670>] ? native_safe_halt+0x2/0x3
> [ 1605.015593]  [<c0107beb>] ? default_idle+0x56/0x99
> [ 1605.015593]  [<c0102277>] ? cpu_idle+0x28/0x41
> [ 1605.015593]  [<c03c490c>] ? start_kernel+0x282/0x285
> [ 1605.015593] Code: 53 35 c0 50 ff b1 a4 00 00 00 ff b1 a0 00 00 00 ff b1 ac 00 00 00 ff b1 a8 00 00 00 52 ff 71 50 53 68 09 7c 36 c0 e8 46 22 06 00 <0f> 0b 83 c4 24 eb fe 89 d8 5b c3 55 57 56 53 83 ec 24 fc 89 c5
> [ 1605.015593] EIP: [<c027a4fc>] skb_put+0x5f/0x6a SS:ESP 0068:c03c3ec0
> [ 1605.231961] ---[ end trace db341c436dab02c9 ]---
> [ 1605.236613] Kernel panic - not syncing: Fatal exception in interrupt
> [ 1605.243010] Pid: 0, comm: swapper Tainted: G      D    2.6.30 #1
> [ 1605.249067] Call Trace:
> [ 1605.251534]  [<c02dc6a3>] ? panic+0x38/0xd7
> [ 1605.255747]  [<c0105373>] ? oops_end+0x7e/0x89
> [ 1605.260261]  [<c0103c4e>] ? do_invalid_op+0x0/0x75
> [ 1605.265090]  [<c0103cba>] ? do_invalid_op+0x6c/0x75
> [ 1605.270039]  [<c027a4fc>] ? skb_put+0x5f/0x6a
> [ 1605.274442]  [<c0104594>] ? do_IRQ+0x53/0x63
> [ 1605.278742]  [<c0103589>] ? common_interrupt+0x29/0x30
> [ 1605.283944]  [<c011eeac>] ? vprintk+0x212/0x220
> [ 1605.288537]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.293904]  [<c02de065>] ? error_code+0x65/0x70
> [ 1605.298598]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.303960]  [<c0103c4e>] ? do_invalid_op+0x0/0x75
> [ 1605.308812]  [<c027a4fc>] ? skb_put+0x5f/0x6a
> [ 1605.313229]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.318612]  [<e0049c12>] ? sky2_poll+0x5e8/0xa8e [sky2]
> [ 1605.323982]  [<c012a1a0>] ? delayed_work_timer_fn+0x0/0x30
> [ 1605.329521]  [<c027edb8>] ? net_rx_action+0x6c/0x128
> [ 1605.334549]  [<c0121ff2>] ? __do_softirq+0x82/0x125
> [ 1605.339481]  [<c01220c2>] ? do_softirq+0x2d/0x37
> [ 1605.344135]  [<c0122185>] ? irq_exit+0x25/0x4e
> [ 1605.348627]  [<c010e641>] ? smp_apic_timer_interrupt+0x60/0x68
> [ 1605.354529]  [<c01035ea>] ? apic_timer_interrupt+0x2a/0x30
> [ 1605.360059]  [<c0130000>] ? unregister_reboot_notifier+0x3/0xc
> [ 1605.365954]  [<c0113670>] ? native_safe_halt+0x2/0x3
> [ 1605.370973]  [<c0107beb>] ? default_idle+0x56/0x99
> [ 1605.375811]  [<c0102277>] ? cpu_idle+0x28/0x41
> [ 1605.380301]  [<c03c490c>] ? start_kernel+0x282/0x285
> 
