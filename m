From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12086] New: NETDEV WATCHDOG: eth0 (atl1):
 transmit timed out
Date: Sat, 22 Nov 2008 20:58:03 -0800
Message-ID: <20081122205803.517ad692.akpm@linux-foundation.org>
References: <bug-12086-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, bharattharee@gmail.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48126 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754199AbYKWE6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 23:58:36 -0500
In-Reply-To: <bug-12086-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 22 Nov 2008 19:04:26 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12086
> 
>            Summary: NETDEV WATCHDOG: eth0 (atl1): transmit timed out
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27.5-41.fc9.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: bharattharee@gmail.com
> 
> 
> Latest working kernel version: 2.6.27.5-41.fc9.x86_64
> 
> Earliest failing kernel version: 2.6.27.5-41.fc9.x86_64

This doesn't make sense - the same kernel version failed and didn't fail?

We're trying to find out if this is a regression.

> Distribution: FEDORA 9 x86_64
> 
> Hardware Environment: AMD +4400, Dual-core, RAM=2GB, HDD=(250+40)GB
> 
> Software Environment: FEDORA 9 x86_64
> 
> Problem Description: Today morning got the following "kernel failure" message
> from "kernel-loops".
> 
> -----------------------------------------------------------------------------
> WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x15d()
> NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> NETDEV WATCHDOG: eth0 (atl1): transmit timed out
> Modules linked in: xt_state ipt_REJECT xt_tcpudp nfsd lockd nfs_acl auth_rpcgss
> exportfs bridge stp bnep rfcomm l2cap bluetooth ib_iser rdma_cm ib_cm iw_cm
> ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi scsi_transport_iscsi autofs4
> sunrpc iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
> nf_conntrack ip_tables x_tables cpufreq_ondemand powernow_k8 freq_table ipv6
> fuse dm_multipath scsi_dh kvm_amd kvm snd_hda_intel snd_seq_dummy ppdev
> snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss
> snd_pcm snd_timer snd_page_alloc snd_hwdep atl1 sc92031 snd sr_mod nvidia(P)
> parport_pc i2c_nforce2 floppy pcspkr k8temp cdrom parport pata_amd mii i2c_core
> soundcore hwmon sg dm_snapshot dm_zero dm_mirror dm_log dm_mod sata_nv
> pata_acpi ata_generic libata sd_mod scsi_mod crc_t10dif ext3 jbd mbcache
> uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
> Pid: 0, comm: swapper Tainted: P          2.6.27.5-41.fc9.x86_64 #1
> 
> Call Trace:
>  <IRQ>  [<ffffffff8103bb01>] warn_slowpath+0xae/0xd7
>  [<ffffffff810b3522>] ? virt_to_head_page+0x31/0x41
>  [<ffffffff810b4df2>] ? kmem_cache_free+0x99/0xb8
>  [<ffffffff810b3522>] ? virt_to_head_page+0x31/0x41
>  [<ffffffff81138b0b>] ? blk_remove_plug+0x71/0xa5
>  [<ffffffff81135d3f>] ? elv_queue_empty+0x22/0x24
>  [<ffffffff81138dc2>] ? blk_run_queue+0x30/0x35
>  [<ffffffffa005c4fa>] ? scsi_run_queue+0x29f/0x2d2 [scsi_mod]
>  [<ffffffff81053d42>] ? sched_clock_cpu+0x10f/0x120
>  [<ffffffffa005d190>] ? scsi_next_command+0x3e/0x46 [scsi_mod]
>  [<ffffffff812b665a>] ? _spin_lock+0x9/0xc
>  [<ffffffff81247521>] ? netif_tx_lock+0x64/0x7e
>  [<ffffffff81053d42>] ? sched_clock_cpu+0x10f/0x120
>  [<ffffffff8124769b>] dev_watchdog+0xfe/0x15d
>  [<ffffffff8124759d>] ? dev_watchdog+0x0/0x15d
>  [<ffffffff81045212>] run_timer_softirq+0x19c/0x222
>  [<ffffffff810570a2>] ? clockevents_program_event+0x73/0x7c
>  [<ffffffff8104102e>] __do_softirq+0x7e/0x10c
>  [<ffffffff8100dbcc>] call_softirq+0x1c/0x28
>  [<ffffffff8100edd6>] do_softirq+0x4d/0xb0
>  [<ffffffff81040c03>] irq_exit+0x4e/0x9d
>  [<ffffffff8101ca3a>] smp_apic_timer_interrupt+0x8f/0xa8
>  [<ffffffff8100d3d8>] apic_timer_interrupt+0x88/0x90
>  <EOI>  [<ffffffff8102172a>] ? native_safe_halt+0x6/0x8
>  [<ffffffff810132cf>] ? need_resched+0x1e/0x28
>  [<ffffffff810133b4>] ? default_idle+0x2a/0x4c
>  [<ffffffff81013504>] ? c1e_idle+0x120/0x127
>  [<ffffffff812b963a>] ? atomic_notifier_call_chain+0x13/0x15
>  [<ffffffff8100b279>] ? cpu_idle+0xb2/0x10b
>  [<ffffffff812a49dd>] ? rest_init+0x61/0x63
> 
> ---[ end trace 9d3a40971e1bbe78 ]---
> 
> Steps to reproduce: Not quite aware on how to reproduce the error.
> 
> When did it happen: 
> ---------------------
> ---> This is the first time I am seeing this "kernel failure" message.
> ---> Did not experience this problem in earlier kernel versions of FEDORA 9
> x86_64
> 
> ---> Why in this kernel got this message? 
> Do not know the reason. But this kernel was compiled.
> 
> ---> Why the kernel was compiled?
> This kernel version had in-build "XEN" enabled, which was restricting me from
> installing the NVIDIA driver.
> Therefore removed the latest kernel version, downloaded the source code of the
> latest version, compiled it without "XEN" and converted into "rpm package" to
> install it.
> 
> ---> Any fruitful result after installing the compiled version?
> YES, was able to install the latest NVIDIA driver.
> 
> ---> Status of the machine?
> It is currently working fine. Graphics are working as expected.
> 
> The "network card" eth0 is working fine. Kindly let me know if it is a serious
> bug or not to be worried of.
> Kindly advise on the steps if this "kernel failure" message can be solved.
> 
> ----------------------------------------------------------------------
> Since in the "trace" I saw this error, logged this bug in "NETWORKING".
> If I have placed the bug in wrong section, kindly advise on the appropriate
> section where this bug can be logged.
> 
