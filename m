From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12303] New: e1000e 82567LM Tx
	Unit Hang
Date: Fri, 26 Dec 2008 13:02:00 -0800
Message-ID: <20081226130200.1588c23f.akpm@linux-foundation.org>
References: <bug-12303-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wangbj@lzu.edu.cn, bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-12303-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 26 Dec 2008 02:50:52 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12303
> 
>            Summary: e1000e 82567LM Tx Unit Hang
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.28
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: wangbj@lzu.edu.cn
>                 CC: jesse.brandeburg@intel.com
> 
> 
> Latest working kernel version: 2.6.27-git2
> Earliest failing kernel version: unknown
> Distribution: gentoo amd64 (~amd64), 2008.0
> Hardware Environment: Thinkpad T400 with GM45 (ICH9)
>

An e1000e regression.

> ...
>
> 0000:00:19.0: eth0: 10/100 speed: disabling TSO
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> eth0: no IPv6 routers present
> DMAR:[DMA Read] Request device [00:19.0] fault addr fff03000 
> DMAR:[fault reason 06] PTE Read access is not set
> 0000:00:19.0: eth0: Detected Tx Unit Hang:
>   TDH                  <a3>
>   TDT                  <b2>
>   next_to_use          <b2>
>   next_to_clean        <a3>
> buffer_info[next_to_clean]:
>   time_stamp           <fffe286d>
>   next_to_watch        <a3>
>   jiffies              <fffe31e5>
>   next_to_watch.status <0>
> 0000:00:19.0: eth0: Detected Tx Unit Hang:
>   TDH                  <a3>
>   TDT                  <b2>
>   next_to_use          <b2>
>   next_to_clean        <a3>
> buffer_info[next_to_clean]:
>   time_stamp           <fffe286d>
>   next_to_watch        <a3>
>   jiffies              <fffe39b5>
>   next_to_watch.status <0>
> 0000:00:19.0: eth0: Detected Tx Unit Hang:
>   TDH                  <a3>
>   TDT                  <b2>
>   next_to_use          <b2>
>   next_to_clean        <a3>
> buffer_info[next_to_clean]:
>   time_stamp           <fffe286d>
>   next_to_watch        <a3>
>   jiffies              <fffe418a>
>   next_to_watch.status <0>
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0xf7/0x154()
> NETDEV WATCHDOG: eth0 (e1000e): transmit timed out
> Modules linked in: snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device
> snd_pcm_oss snd_mixer_oss uvcvideo compat_ioctl32 firewire_ohci videodev
> firewire_core v4l1_compat scsi_wait_scan
> Pid: 3956, comm: metacity Not tainted 2.6.28-gentoo #1
> Call Trace:
>  <IRQ>  [<ffffffff802361ae>] warn_slowpath+0xb4/0xda
>  [<ffffffff80490c73>] usb_hcd_submit_urb+0x733/0x7fd
>  [<ffffffff804b11f0>] input_pass_event+0x5a/0x7b
>  [<ffffffff804b2f5d>] input_event+0x5c/0x7f
>  [<ffffffff804d7938>] hidinput_report_event+0x25/0x37
>  [<ffffffff804d4f95>] hid_input_report+0x1da/0x1f0
>  [<ffffffff80454531>] scsi_run_queue+0x2f8/0x395
>  [<ffffffff80380bfb>] __next_cpu+0x19/0x26
>  [<ffffffff80513aab>] netif_tx_lock+0x3d/0x68
>  [<ffffffff80513c1c>] dev_watchdog+0xf7/0x154
>  [<ffffffff8022a227>] sched_slice+0x3b/0x47
>  [<ffffffff8022a51a>] task_tick_fair+0x49/0x78
>  [<ffffffff80513b25>] dev_watchdog+0x0/0x154
>  [<ffffffff8023e6d8>] run_timer_softirq+0x151/0x1bf
>  [<ffffffff8023aeec>] __do_softirq+0x7c/0x135
>  [<ffffffff8020d12c>] call_softirq+0x1c/0x28
>  [<ffffffff8020e5f4>] do_softirq+0x2c/0x68
>  [<ffffffff8023ac98>] irq_exit+0x3f/0x91
>  [<ffffffff8021b3f1>] smp_apic_timer_interrupt+0x92/0xab
>  [<ffffffff8020cc0b>] apic_timer_interrupt+0x6b/0x70
>  <EOI> <4>---[ end trace 15d0e5980221c96c ]---
> 0000:00:19.0: eth0: Link is Up 100 Mbps Full Duplex, Flow Control: None
> 0000:00:19.0: eth0: 10/100 speed: disabling TSO
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 0000:00:19.0: eth0: Detected Tx Unit Hang:
>   TDH                  <0>
>   TDT                  <3>
>   next_to_use          <3>
>   next_to_clean        <0>
> buffer_info[next_to_clean]:
>   time_stamp           <fffe4c85>
>   next_to_watch        <0>
>   jiffies              <fffe550d>
>   next_to_watch.status <0>
> 0000:00:19.0: eth0: Detected Tx Unit Hang:
>   TDH                  <0>
> 
> Steps to reproduce:
> 1) get a computer with Intel Corporation 82567LM Gigabit Ethernet controller
> 2) compile kernel 2.6.28 (amd64) with e1000e
> 3) try to do some network traffic


------------------------------------------------------------------------------
