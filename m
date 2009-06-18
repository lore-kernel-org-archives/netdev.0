From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: kernel dies if loopback device not intialized
Date: Wed, 17 Jun 2009 18:18:09 -0700
Message-ID: <20090617181809.5233da40@nehalam>
References: <20090610203536.4357d309@nehalam>
	<1245080498.7134.15.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43134 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbZFRBSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 21:18:13 -0400
In-Reply-To: <1245080498.7134.15.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2009 15:41:38 +0000
John Dykstra <john.dykstra1@gmail.com> wrote:

> On Wed, 2009-06-10 at 20:35 -0700, Stephen Hemminger wrote:
> > This OOPS happens if system is booted up and loopback device
> > is not initialized. This means the loopback device is not yet in the
> > route table so when arp goes to send the error report, the route
> > lookup thinks it is a martian and then dies.
> > 
> > Granted this is a startup script problem, but kernel shouldn't die.
> > 
> > [   55.601158] IP: [<c028968c>] ip_handle_martian_source+0x75/0xb8
> > [   55.604044] Oops: 0000 [#1] SMP
> > [   55.604044] last sysfs file: /sys/kernel/uevent_seqnum
> > [   55.604044] Modules linked in: iptable_nat ip6table_filter
> > iptable_filter ip6table_raw ip6_tables xt_NOTRACK iptable_raw ip_tables
> > x_tables nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_h323
> > nf_conntrack_h323 nf_nat_sip nf_conntrack_sip nf_nat_proto_gre nf_nat_tftp
> > nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_tftp
> > nf_conntrack_ftp nf_conntrack ipv6 md_mod parport_pc parport psmouse
> > pcspkr serio_raw vmxnet container ac button i2c_piix4 i2c_core shpchp
> > pci_hotplug intel_agp agpgart evdev vfat fat ext2 battery squashfs loop
> > unionfs nls_utf8 isofs nls_base zlib_inflate ext3 jbd mbcache sd_mod sg
> > crc_t10dif sr_mod cdrom ata_piix pata_acpi floppy ata_generic mptspi
> > mptscsih mptbase scsi_transport_spi libata scsi_mod thermal processor fan
> > thermal_sys
> > [   55.604044]
> > [   55.604044] Pid: 0, comm: swapper Not tainted (2.6.29-1-586-vyatta #1)
> > VMware Virtual Platform
> > [   55.604044] EIP: 0060:[<c028968c>] EFLAGS: 00010293 CPU: 0
> > [   55.604044] EIP is at ip_handle_martian_source+0x75/0xb8
> > [   55.604044] EAX: 0000000e EBX: 00000000 ECX: c03e3d28 EDX: c03611e7
> > [   55.604044] ESI: ddc40000 EDI: fffffc00 EBP: 00000000 ESP: c03e3d28
> > [   55.604044]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> > [   55.604044] Process swapper (pid: 0, ti=c03e2000 task=c038533c
> > task.ti=c03e2000)
> > [   55.604044] Stack:
> > [   55.604044]  00000003 0100007f ffffffea c028c45b 1000000f 0100007f
> > 00000000 00000003
> > [   55.604044]  00000246 0100007f de5e9180 00000004 dfa6c600 df24ea80
> > c03e3dcc c03e3d90
> > [   55.604044]  00000000 00000003 00000000 1000000f 0100007f 00000000
> > 00000000 00000000
> > [   55.604044] Call Trace:
> > [   55.604044]  [<c028c45b>] ip_route_input+0xbf8/0xc20
> > [   55.604044]  [<c02ac0a9>] icmp_send+0x361/0x4c4
> > [   55.604044]  [<c0135a7e>] sched_clock_cpu+0x13f/0x14b
> > [   55.604044]  [<c011cf34>] update_rq_clock+0xe/0x1c
> > [   55.604044]  [<c0289174>] ipv4_link_failure+0x14/0x37
> > [   55.604044]  [<c02aa056>] arp_error_report+0x1c/0x24
> > [   55.604044]  [<c027a3ae>] neigh_timer_handler+0x1c4/0x282
> > [   55.604044]  [<c027a1ea>] neigh_timer_handler+0x0/0x282
> > [   55.604044]  [<c01298eb>] run_timer_softirq+0x139/0x191
> > [   55.604044]  [<c027a1ea>] neigh_timer_handler+0x0/0x282
> > [   55.604044]  [<c012680a>] __do_softirq+0x83/0x103
> > [   55.604044]  [<c01268bc>] do_softirq+0x32/0x36
> > [   55.604044]  [<c01269d7>] irq_exit+0x35/0x62
> > [   55.604044]  [<c010fbc4>] smp_apic_timer_interrupt+0x71/0x7b
> > [   55.604044]  [<c0103a48>] apic_timer_interrupt+0x28/0x30
> > [   55.604044]  [<c01085f0>] default_idle+0x2a/0x3d
> > [   55.604044]  [<c0102489>] cpu_idle+0x57/0x72
> > [   55.604044] Code: e8 a1 f1 04 00 83 c4 10 66 83 be d2 00 00 00 00 74 58
> > 8b bf 98 00 00 00 85 ff 74 4e 68 e7 11 36 c0 31 db e8 7e f1 04 00 58 eb 29
> > <0f> b6 04 1f 50 68 c8 20 35 c0 e8 6c f1 04 00 0f b7 86 d2 00 00
> > [   55.604044] EIP: [<c028968c>] ip_handle_martian_source+0x75/0xb8 SS:ESP
> > 0068:c03e3d28
> > [   55.604044] ---[ end trace bfa8f60b4b45cd60 ]---
> > [   55.604044] Kernel panic - not syncing: Fatal exception in interrupt
> 
> The oops seems to be from the skb passed to ip_handle_martian_source(),
> which is the skb pulled from the ARP queue.  Either skb->mac_header is
> bogus, or the skb pointer itself is:
> 
> 	movl	148(%edi), %edi	# <variable>.mac_header, D.47506
> 	testl	%edi, %edi	# D.47506
> 	je	.L141	#,
> 	pushl	$.LC1	#
> 	xorl	%ebx, %ebx	# i
> 	call	printk	#
> 	popl	%eax	#
> 	jmp	.L136	#
> .L137:
> 	movzbl	(%ebx,%edi), %eax	#* D.47506, tmp72    ******** trap here *******
> 	pushl	%eax	# tmp72
> 	pushl	$.LC2	#
> 	call	printk	#
> 	movzwl	210(%esi), %eax	# <variable>.hard_header_len, <variable>.hard_header_len
> 	popl	%edx	#
> 	decl	%eax	# tmp74
> 	cmpl	%eax, %ebx	# tmp74, i
> 	popl	%ecx	#
> 	jge	.L138	#,
> 	pushl	$.LC3	#
> 	call	printk	#
> 	popl	%eax	#
> .L138:
> 	incl	%ebx	# i
> .L136:
> 	movzwl	210(%esi), %eax	# <variable>.hard_header_len, <variable>.hard_header_len
> 	cmpl	%eax, %ebx	# <variable>.hard_header_len, i
> 	jl	.L137	#,
> 
> Stephen, I haven't been able to reproduce this--can you provide a
> recipe?  Where is that packet coming from?
> 
>   --  John
> 

This looks like it is fixed by the mac_header patch I just sent.
There are several paths calling pskb_expand_head() that would corrupt
mac_header.  mac_header was initially NULL, but then some path wanted
to expand for new header and increased by a fixed amount. Probably ICMP
adding it's header to original IP packet.

-- 
