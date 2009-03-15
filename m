From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
 resetting -> dead NIC
Date: Sun, 15 Mar 2009 14:32:14 -0700
Message-ID: <20090315143214.90c71fb7.akpm@linux-foundation.org>
References: <bug-12877-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, berni@birkenwald.de
To: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37561 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbZCOVib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 17:38:31 -0400
In-Reply-To: <bug-12877-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 15 Mar 2009 07:23:00 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12877
> 
>            Summary: tg3: eth0 transit timed out, resetting -> dead NIC
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.28.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: berni@birkenwald.de
> 
> 
> Latest working kernel version: none
> Earliest failing kernel version: 2.6.28.1
> Distribution: Debian Lenny
> Hardware Environment: HP DL320G5p
> Software Environment: Debian Lenny host for KVM VMs
> Problem Description:
> 
> Every couple of weeks the network of my colo box dies with the following
> message:
> 
> [784060.816020] ------------[ cut here ]------------
> [784060.869153] WARNING: at net/sched/sch_generic.c:226
> dev_watchdog+0x121/0x1b8()
> [784060.953146] NETDEV WATCHDOG: eth0 (tg3): transmit timed out
> [784061.018138] Modules linked in: esp6 xfrm6_mode_tunnel authenc esp4
> xfrm4_mode_tunnel tun kvm_intel kvm xt_NOTRACK ip6table_raw ip6t_LOG
> nf_conntrack_ipv6 ip6table_filter ip6_tables xt_physdev ipt_LOG xt_tcpudp
> nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_hashlimit
> iptable_filter ip_tables x_tables bridge stp llc deflate zlib_deflate
> zlib_inflate ctr twofish twofish_common camellia serpent blowfish des_generic
> cbc aes_x86_64 aes_generic xcbc sha256_generic sha1_generic crypto_null af_key
> dm_crypt ipv6 coretemp loop ipmi_si ipmi_msghandler hpilo hpwdt pcspkr shpchp
> pci_hotplug container button psmouse serio_raw evdev ext3 jbd dm_mirror
> dm_region_hash dm_log dm_snapshot dm_mod raid1 md_mod sg sd_mod sr_mod cdrom
> usbhid hid ata_piix ata_generic libata scsi_mod ide_pci_generic ide_core
> ehci_hcd tg3 libphy uhci_hcd thermal processor fan thermal_sys
> [784061.891133] Pid: 0, comm: swapper Not tainted 2.6.28.7 #1
> [784061.954129] Call Trace:
> [784061.983133]  <IRQ>  [<ffffffff802398aa>] warn_slowpath+0xb4/0xda
> [784062.053147]  [<ffffffffa0269998>] dst_output+0x0/0xb [ipv6]
> [784062.118130]  [<ffffffff803e35a8>] nf_hook_slow+0x62/0xc3
> [784062.180139]  [<ffffffffa0269998>] dst_output+0x0/0xb [ipv6]
> [784062.245126]  [<ffffffff80332437>] __next_cpu+0x19/0x26
> [784062.305124]  [<ffffffff80212a61>] read_tsc+0xa/0x1f
> [784062.362126]  [<ffffffff80251c69>] getnstimeofday+0x52/0xac
> [784062.426126]  [<ffffffff803d9bd1>] dev_watchdog+0x121/0x1b8
> [784062.490124]  [<ffffffff8025015f>] sched_clock_tick+0x8a/0x92
> [784062.556124]  [<ffffffff803d9ab0>] dev_watchdog+0x0/0x1b8
> [784062.618123]  [<ffffffff80241f50>] run_timer_softirq+0x198/0x21a
> [784062.687118]  [<ffffffff80251c69>] getnstimeofday+0x52/0xac
> [784062.751117]  [<ffffffff8023e61a>] __do_softirq+0x83/0x143
> [784062.814116]  [<ffffffff8020d6ec>] call_softirq+0x1c/0x28
> [784062.876119]  [<ffffffff8020ecd0>] do_softirq+0x3c/0x81
> [784062.936114]  [<ffffffff8023e338>] irq_exit+0x3f/0x83
> [784062.994139]  [<ffffffff8021be99>] smp_apic_timer_interrupt+0x92/0xab
> [784063.068116]  [<ffffffff8020cef8>] apic_timer_interrupt+0x88/0x90
> [784063.138109]  <EOI>  [<ffffffffa03c4a20>] handle_halt+0x0/0x12 [kvm_intel]
> [784063.217116]  [<ffffffff802134fe>] mwait_idle+0x3c/0x46
> [784063.277113]  [<ffffffff8020b0bd>] cpu_idle+0x51/0x92
> [784063.335127] ---[ end trace 444b547394c96982 ]---
> [784063.389142] tg3: eth0: transmit timed out, resetting
> [784063.447106] tg3: DEBUG: MAC_TX_STATUS[ffffffff] MAC_RX_STATUS[ffffffff]
> [784063.524104] tg3: DEBUG: RDMAC_STATUS[ffffffff] WDMAC_STATUS[ffffffff]
> [784063.706035] tg3: tg3_stop_block timed out, ofs=2c00 enable_bit=2
> [784063.875340] tg3: tg3_stop_block timed out, ofs=2000 enable_bit=2
> [784064.044372] tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
> [784064.213191] tg3: tg3_stop_block timed out, ofs=2800 enable_bit=2
> [784064.382454] tg3: tg3_stop_block timed out, ofs=3000 enable_bit=2
> [784064.551295] tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> [784064.720269] tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
> [784064.889183] tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> [784065.057321] tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
> [784065.226318] tg3: tg3_stop_block timed out, ofs=1000 enable_bit=2
> [784065.395423] tg3: tg3_stop_block timed out, ofs=1c00 enable_bit=2
> [784065.564199] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not
> clear MAC_TX_MODE=ffffffff
> [784065.769278] tg3: tg3_stop_block timed out, ofs=3c00 enable_bit=2
> [784065.938319] tg3: tg3_stop_block timed out, ofs=4c00 enable_bit=2
> [784067.283239] tg3: eth0: No firmware running.
> [784068.533652] tg3: tg3_abort_hw timed out for eth0, TX_MODE_ENABLE will not
> clear MAC_TX_MODE=ffffffff
> [784081.605984] tg3: eth0: Link is down.
> 
> When it happens I either have to reboot the system or rmmod/modprobe tg3 to get
> it working again. The interface affected is the routed upstream port of the
> system, the system doesn't do much more than to route/firewall to an internal
> bridge where several KVM VMs are connected to. eth0 has a shared physical port
> with the on-board iLO2, which is still reachable when the problem happens. The
> switchport bounces a couple of times though.
> 
> Steps to reproduce:
> 

