From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13791] New: tg3 transmit timeout kills
 interface
Date: Thu, 23 Jul 2009 13:50:00 -0700
Message-ID: <20090723135000.42126643.akpm@linux-foundation.org>
References: <bug-13791-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mcarlson@broadcom.com,
	mchan@broadcom.com, kernel@mattgillen.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54084 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752276AbZGWUuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 16:50:05 -0400
In-Reply-To: <bug-13791-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 17 Jul 2009 13:49:15 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13791
> 
>            Summary: tg3 transmit timeout kills interface
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29.5-191.fc11.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: kernel@mattgillen.net
>         Regression: No
> 
> 
> Created an attachment (id=22389)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=22389)
> Kernel messages dumped to /var/log/messages
> 
> Overview:
> Starting with Fedora 10, and continuing in Fedora 11, I started getting the
> kernel dump in /var/log/messages (see attachment) at least once a day,
> regardless of network load on the machine.  After this message, the network
> interface no longer works, and I have to reboot.  I don't recall ever having
> this issue with Fedora 8/9 (I ran each of those for roughly 7 months).
> 
> It looks like Fedora 10 shipped with kernel 2.6.27, so that's roughly when I
> started seeing this issue.
> 
> Steps to Reproduce: Leave my laptop up and plugged into a wired network for 12
> hours or so.
> 
> Additional Information:
> I have a Dell Latitude D630 with a Broadcom ethernet card; as reported by
> lspci:
> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M Gigabit
> Ethernet PCI Express (rev 02)
> 

Thanks, I'll mark this as a regression.

The nvidia driver tainted the kernel.  People might want to know
whether the problem can be reproduced in a kernel which never had the
nvidia driver loaded.


Here's the log:

Jul 15 14:38:58 localhost kernel: ------------[ cut here ]------------
Jul 15 14:38:58 localhost kernel: WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0xcf/0x12c() (Tainted: P          )
Jul 15 14:38:58 localhost kernel: Hardware name: Latitude D630
Jul 15 14:38:58 localhost kernel: NETDEV WATCHDOG: eth0 (tg3): transmit timed out
Jul 15 14:38:58 localhost kernel: Modules linked in: ipt_MASQUERADE iptable_nat nf_nat bridge stp llc bnep sco l2cap bluetooth autofs4 sunrpc ip6t_REJECT ip6t_ipv6header nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 cpufreq_ondemand acpi_cpufreq freq_table fuse dm_multipath kvm_intel kvm uinput nvidia(P) arc4 ecb snd_hda_codec_idt iwlagn snd_hda_intel snd_hda_codec iwlcore snd_hwdep firewire_ohci snd_pcm lib80211 video dell_laptop mac80211 firewire_core iTCO_wdt tg3 yenta_socket snd_timer i2c_i801 wmi iTCO_vendor_support i2c_core rsrc_nonstatic snd soundcore cfg80211 snd_page_alloc crc_itu_t output dcdbas pcspkr joydev [last unloaded: microcode]
Jul 15 14:38:58 localhost kernel: Pid: 0, comm: swapper Tainted: P           2.6.29.5-191.fc11.x86_64 #1
Jul 15 14:38:58 localhost kernel: Call Trace:
Jul 15 14:38:58 localhost kernel: <IRQ>  [<ffffffff8104883f>] warn_slowpath+0xbc/0xf0
Jul 15 14:38:58 localhost kernel: [<ffffffff813abe44>] ? _spin_unlock_irqrestore+0x2c/0x42
Jul 15 14:38:58 localhost kernel: [<ffffffff81039604>] ? task_rq_unlock+0x11/0x13
Jul 15 14:38:58 localhost kernel: [<ffffffff8104056b>] ? try_to_wake_up+0x25b/0x26d
Jul 15 14:38:58 localhost kernel: [<ffffffff8104058f>] ? default_wake_function+0x12/0x14
Jul 15 14:38:58 localhost kernel: [<ffffffff8105c8ed>] ? autoremove_wake_function+0x16/0x39
Jul 15 14:38:58 localhost kernel: [<ffffffff810379ac>] ? __wake_up_common+0x4e/0x84
Jul 15 14:38:58 localhost kernel: [<ffffffff813abe44>] ? _spin_unlock_irqrestore+0x2c/0x42
Jul 15 14:38:58 localhost kernel: [<ffffffff813abbfa>] ? _spin_lock+0xe/0x11
Jul 15 14:38:58 localhost kernel: [<ffffffff8132196d>] dev_watchdog+0xcf/0x12c
Jul 15 14:38:58 localhost kernel: [<ffffffff810596a7>] ? __queue_work+0x3a/0x42
Jul 15 14:38:58 localhost kernel: [<ffffffff813abf5f>] ? _spin_lock_irq+0x27/0x2a
Jul 15 14:38:58 localhost kernel: [<ffffffff81051e67>] run_timer_softirq+0x19e/0x224
Jul 15 14:38:58 localhost kernel: [<ffffffff81063094>] ? getnstimeofday+0x5f/0xb3
Jul 15 14:38:58 localhost kernel: [<ffffffff8104df6f>] __do_softirq+0x94/0x155
Jul 15 14:38:58 localhost kernel: [<ffffffff8101274c>] call_softirq+0x1c/0x30
Jul 15 14:38:58 localhost kernel: [<ffffffff810138ce>] do_softirq+0x52/0xb9
Jul 15 14:38:58 localhost kernel: [<ffffffff8104db92>] irq_exit+0x53/0x90
Jul 15 14:38:58 localhost kernel: [<ffffffff81022464>] smp_apic_timer_interrupt+0x8e/0xa7
Jul 15 14:38:58 localhost kernel: [<ffffffff81012123>] apic_timer_interrupt+0x13/0x20
Jul 15 14:38:58 localhost kernel: <EOI>  [<ffffffff812ed312>] ? menu_reflect+0x2a/0x6e
Jul 15 14:38:58 localhost kernel: [<ffffffff812ec73f>] ? cpuidle_idle_call+0xbd/0xc2
Jul 15 14:38:58 localhost kernel: [<ffffffff810102a1>] ? cpu_idle+0x68/0xb3
Jul 15 14:38:58 localhost kernel: [<ffffffff813a5e3c>] ? start_secondary+0x199/0x19e
Jul 15 14:38:58 localhost kernel: ---[ end trace ed7f6377ede4163b ]---
Jul 15 14:38:58 localhost kernel: tg3: eth0: transmit timed out, resetting
Jul 15 14:38:58 localhost kernel: tg3: DEBUG: MAC_TX_STATUS[0000000b] MAC_RX_STATUS[00000000]
Jul 15 14:38:58 localhost kernel: tg3: DEBUG: RDMAC_STATUS[00000010] WDMAC_STATUS[00000000]
Jul 15 14:38:58 localhost kernel: tg3: tg3_stop_block timed out, ofs=2c00 enable_bit=2
Jul 15 14:38:58 localhost kernel: tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
Jul 15 14:38:58 localhost kernel: tg3: eth0: Link is down.
Jul 15 14:38:58 localhost NetworkManager: <info>  (eth0): carrier now OFF (device state 8)
Jul 15 14:38:58 localhost NetworkManager: <info>  (eth0): device state change: 8 -> 2
Jul 15 14:38:58 localhost NetworkManager: <info>  (eth0): deactivating device (reason: 40).

