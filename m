From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Thu, 14 Jul 2011 15:14:25 -0700
Message-ID: <20110714151425.844b7738.akpm@linux-foundation.org>
References: <bug-39372-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lucas.bocchi@gmail.com,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53009 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932217Ab1GNWPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 18:15:10 -0400
In-Reply-To: <bug-39372-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 14 Jul 2011 13:07:59 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=39372
> 
>            Summary: Problems with HFSC Scheduler
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: lucas.bocchi@gmail.com
>         Regression: No
> 
> 
> We have a problem with HFSC scheduler. When use it with my configuration, in
> aleatory times the kernel hang and the network device with attached scheduler
> hangs and kernel stops to work for a long time.
> 
> Above I'll attach the files with the scheduler used by me
> 
> Additional Information
> 
> Linux optimus 2.6.39.3 #1 SMP Wed Jul 13 09:40:20 BRT 2011 x86_64 GNU/Linux
> 
> Gnu C                  4.6.1
> Gnu make               3.81
> binutils               2.21.52.20110606
> util-linux             2.17.2
> mount                  support
> module-init-tools      3.16
> e2fsprogs              1.42-WIP
> xfsprogs               3.1.5
> PPP                    2.4.5
> Linux C Library        2.13
> Dynamic linker (ldd)   2.13
> Procps                 3.2.8
> Net-tools              1.60
> Console-tools          0.2.3
> Sh-utils               8.5
> Modules Loaded         cls_u32 sch_sfq sch_hfsc sch_prio pppoe pppox nf_nat_sip
> nf_conntrack_sip nf_nat_ftp nf_conntrack_ftp xt_owner ipt_LOG xt_recent
> xt_hashlimit xt_TCPMSS xt_tcpmss xt_mark xt_connmark xt_state ipt_MASQUERADE
> ipt_REDIRECT ipt_REJECT xt_tcpudp iptable_mangle iptable_nat nf_nat
> nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 iptable_filter ip_tables x_tables
> tun fuse nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc sit tunnel4
> ppp_generic slhc ext4 jbd2 crc16 sbs sbshc it87 hwmon_vid coretemp loop
> kvm_intel kvm snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_pcm
> snd_timer snd soundcore snd_page_alloc psmouse serio_raw parport_pc parport
> processor pcspkr evdev asus_atk0110 rng_core button thermal_sys ext3 jbd
> mbcache btrfs zlib_deflate crc32c libcrc32c usbhid hid ide_gd_mod sd_mod
> crc_t10dif ata_generic pata_acpi uhci_hcd ata_piix libata scsi_mod floppy
> ehci_hcd ide_pci_generic r8169 8139too 8139cp mii piix ide_core usbcore
> 

It's a warning storm, not really an oops:

Jul 13 18:00:22 optimus kernel: [28933.952120] ------------[ cut here ]------------
Jul 13 18:00:22 optimus kernel: [28933.952171] WARNING: at net/sched/sch_hfsc.c:1427 hfsc_dequeue+0x12c/0x275 [sch_hfsc]()
Jul 13 18:00:22 optimus kernel: [28933.952234] Hardware name: System Product Name
Jul 13 18:00:22 optimus kernel: [28933.952265] Modules linked in: cls_u32 sch_sfq sch_hfsc sch_prio xfs nf_nat_sip nf_conntrack_sip nf_nat_ftp nf_conntrack_ftp xt_owner ipt_LOG xt_recent xt_hashlimit xt_TCPMSS xt_tcpmss xt_mark xt_connmark xt_state ipt_MASQUERADE ipt_REDIRECT ipt_REJECT xt_tcpudp iptable_mangle tun iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables pppoe pppox fuse nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc sit tunnel4 ppp_generic slhc ext4 jbd2 crc16 sbs sbshc it87 hwmon_vid coretemp loop kvm_intel kvm snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd asus_atk0110 soundcore evdev snd_page_alloc rng_core processor parport_pc parport thermal_sys button pcspkr psmouse serio_raw ext3 jbd mbcach
 e btrfs zlib_deflate crc32c libcrc32c sd_mod ide_gd_mod crc_t10dif ata_generic pata_acpi ata_piix libata scsi_mod piix floppy uhci_hcd ide_pci_generic ehci_hcd 8139too 8139cp ide_core r8169!
  mii usbcore [last unloaded: scsi_wait_
Jul 13 18:00:22 optimus kernel: scan]
Jul 13 18:00:22 optimus kernel: [28933.952811] Pid: 0, comm: swapper Tainted: G        W   2.6.39.3 #1
Jul 13 18:00:22 optimus kernel: [28933.952843] Call Trace:
Jul 13 18:00:22 optimus kernel: [28933.952866]  <IRQ>  [<ffffffff81031aae>] ? warn_slowpath_common+0x78/0x8c
Jul 13 18:00:22 optimus kernel: [28933.952906]  [<ffffffffa00fb9ec>] ? hfsc_dequeue+0x12c/0x275 [sch_hfsc]
Jul 13 18:00:22 optimus kernel: [28933.952940]  [<ffffffffa000704d>] ? prio_dequeue+0x1c/0x6e [sch_prio]
Jul 13 18:00:22 optimus kernel: [28933.952977]  [<ffffffffa0112920>] ? rtl8139_start_xmit+0x6a/0xf7 [8139too]
Jul 13 18:00:22 optimus kernel: [28933.953012]  [<ffffffff8123408e>] ? __qdisc_run+0x8e/0x115
Jul 13 18:00:22 optimus kernel: [28933.953044]  [<ffffffff8121ae48>] ? net_tx_action+0xef/0x124
Jul 13 18:00:22 optimus kernel: [28933.953075]  [<ffffffff81036bbb>] ? __do_softirq+0xc7/0x192
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff812d5fdc>] ? call_softirq+0x1c/0x26
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff810037ba>] ? do_softirq+0x3c/0x7a
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff81036e4c>] ? irq_exit+0x4a/0x94
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff810156fb>] ? smp_apic_timer_interrupt+0x75/0x82
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff812d578e>] ? apic_timer_interrupt+0xe/0x20
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff812d5793>] ? apic_timer_interrupt+0x13/0x20
Jul 13 18:00:22 optimus kernel: [28933.953105]  <EOI>  [<ffffffff81007be7>] ? mwait_idle+0x8b/0xb7
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff81007bda>] ? mwait_idle+0x7e/0xb7
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff810011e2>] ? cpu_idle+0x9d/0xd7
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff81b91b16>] ? start_kernel+0x3b4/0x3bf
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff81b91140>] ? early_idt_handlers+0x140/0x140
Jul 13 18:00:22 optimus kernel: [28933.953105]  [<ffffffff81b913a8>] ? x86_64_start_kernel+0x104/0x111
Jul 13 18:00:22 optimus kernel: [28933.953105] ---[ end trace 05058983c1ade13b ]---
Jul 13 18:00:22 optimus kernel: [28933.953105] ------------[ cut here ]------------


Here:
	WARN_ON(next_time == 0);

There's some more info in the bugzilla report.
