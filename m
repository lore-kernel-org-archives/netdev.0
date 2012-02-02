From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 02 Feb 2012 21:37:37 +0100
Message-ID: <1328215057.2480.20.camel@edumazet-laptop>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61890 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775Ab2BBUhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 15:37:41 -0500
Received: by werb13 with SMTP id b13so2175748wer.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 12:37:40 -0800 (PST)
In-Reply-To: <1328214866.2480.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 21:34 +0100, Eric Dumazet a =C3=A9=
crit :

> That sounds a right fix.
>=20
> Why do think its not reasonable that I ask a bug fix ?
>=20
> Next time, dont bother send patches for review if you dont want
> reviewers.

=46YI, here the trace you can get right now with this bug :

[ 1180.114682] WARNING: at arch/x86/kernel/smp.c:120 native_smp_send_re=
schedule+0x5b/0x60()
[ 1180.114685] Hardware name: ProLiant BL460c G6
[ 1180.114686] Modules linked in: ipmi_devintf nfsd exportfs ipmi_si hp=
ilo bnx2x crc32c libcrc32c mdio [last unloaded: scsi_wait_scan]
[ 1180.114697] Pid: 7, comm: migration/1 Not tainted 3.3.0-rc2+ #609
[ 1180.114699] Call Trace:
[ 1180.114701]  <IRQ>  [<ffffffff81037adf>] warn_slowpath_common+0x7f/0=
xc0
[ 1180.114708]  [<ffffffff81037b3a>] warn_slowpath_null+0x1a/0x20
[ 1180.114711]  [<ffffffff8101ecfb>] native_smp_send_reschedule+0x5b/0x=
60
[ 1180.114715]  [<ffffffff810744ec>] trigger_load_balance+0x28c/0x370
[ 1180.114720]  [<ffffffff8106be14>] scheduler_tick+0x114/0x160
[ 1180.114724]  [<ffffffff8104956e>] update_process_times+0x6e/0x90
[ 1180.114729]  [<ffffffff8108c614>] tick_sched_timer+0x64/0xc0
[ 1180.114733]  [<ffffffff8105fe54>] __run_hrtimer+0x84/0x1f0
[ 1180.114736]  [<ffffffff8108c5b0>] ? tick_nohz_handler+0xf0/0xf0
[ 1180.114739]  [<ffffffff8103f271>] ? __do_softirq+0x101/0x240
[ 1180.114742]  [<ffffffff81060783>] hrtimer_interrupt+0xf3/0x220
[ 1180.114747]  [<ffffffff810a90b0>] ? queue_stop_cpus_work+0x100/0x100
[ 1180.114751]  [<ffffffff8171ee09>] smp_apic_timer_interrupt+0x69/0x99
[ 1180.114754]  [<ffffffff8171dd4b>] apic_timer_interrupt+0x6b/0x70
[ 1180.114756]  <EOI>  [<ffffffff810a9143>] ? stop_machine_cpu_stop+0x9=
3/0xc0
[ 1180.114761]  [<ffffffff810a8da7>] cpu_stopper_thread+0xd7/0x1a0
[ 1180.114766]  [<ffffffff81713dc7>] ? __schedule+0x3a7/0x7e0
[ 1180.114768]  [<ffffffff81064058>] ? __wake_up_common+0x58/0x90
[ 1180.114771]  [<ffffffff810a8cd0>] ? cpu_stop_signal_done+0x40/0x40
[ 1180.114773]  [<ffffffff8105b5c3>] kthread+0x93/0xa0
[ 1180.114776]  [<ffffffff8171e594>] kernel_thread_helper+0x4/0x10
[ 1180.114779]  [<ffffffff8105b530>] ? kthread_freezable_should_stop+0x=
80/0x80
[ 1180.114781]  [<ffffffff8171e590>] ? gs_change+0xb/0xb
