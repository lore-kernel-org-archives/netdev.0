From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Wed, 21 May 2008 10:57:47 -0700
Message-ID: <20080521105747.215be17d.akpm@linux-foundation.org>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, brian.vowell@gmail.com,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37080 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759130AbYEUR57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 13:57:59 -0400
In-Reply-To: <bug-10767-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 21 May 2008 02:45:59 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10767
> 
>            Summary: Seg Fault Instead of Swapping

Strange description?

>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.25.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: brian.vowell@gmail.com
> 
> 
> May 20 13:11:00 ishtar kernel: ------------[ cut here ]------------
> May 20 13:11:00 ishtar kernel: WARNING: at net/ipv4/tcp_input.c:2539
> tcp_ack+0xd2b/0x191f()

In 2.6.25 this is

	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
		tp->fackets_out = 0;

> May 20 13:11:00 ishtar kernel: Modules linked in: fuse dm_mirror dm_multipath
> dm_mod cfi_cmdset_0002 cfi_util jedec_probe button cfi_probe gen_probe k8temp
> ck804xrom hwmon mtd usb_storage chipreg serio_raw map_funcs i2c_nforce2 pcspkr
> i2c_core sg pata_amd cciss ata_generic pata_acpi sata_nv libata sd_mod scsi_mod
> raid456 async_xor async_memcpy async_tx xor raid1 uhci_hcd ohci_hcd ssb
> ehci_hcd [last unloaded: scsi_wait_scan]
> May 20 13:11:00 ishtar kernel: Pid: 0, comm: swapper Not tainted 2.6.25.4 #1
> May 20 13:11:00 ishtar kernel:
> May 20 13:11:00 ishtar kernel: Call Trace:
> May 20 13:11:00 ishtar kernel:  <IRQ>  [<ffffffff81034481>]
> warn_on_slowpath+0x51/0x63
> May 20 13:11:00 ishtar kernel:  [<ffffffff81023577>] kernel_map_pages+0xe8/0xed
> May 20 13:11:00 ishtar kernel:  [<ffffffff8103ca36>] lock_timer_base+0x26/0x4c
> May 20 13:11:00 ishtar kernel:  [<ffffffff812baa38>] tcp_snd_test+0x17/0xdf
> May 20 13:11:00 ishtar kernel:  [<ffffffff812bab4d>] tcp_may_send_now+0x4d/0x5a
> May 20 13:11:00 ishtar kernel:  [<ffffffff812b68ce>] tcp_ack+0xd2b/0x191f
> May 20 13:11:00 ishtar kernel:  [<ffffffff812b9dbc>]
> tcp_rcv_established+0xe2/0x8ce
> May 20 13:11:00 ishtar kernel:  [<ffffffff812bffba>] tcp_v4_do_rcv+0x2c2/0x48b
> May 20 13:11:00 ishtar kernel:  [<ffffffff8129a07a>] __qdisc_run+0xf6/0x1c8
> May 20 13:11:00 ishtar kernel:  [<ffffffff812ae376>]
> __inet_lookup_established+0xdf/0x17b
> May 20 13:11:00 ishtar kernel:  [<ffffffff812c1d10>] tcp_v4_rcv+0x6a3/0x700
> May 20 13:11:00 ishtar kernel:  [<ffffffff812a7558>]
> ip_local_deliver+0xd4/0x18e
> May 20 13:11:00 ishtar kernel:  [<ffffffff812a7b0d>] ip_rcv+0x4fb/0x53a
> May 20 13:11:00 ishtar kernel:  [<ffffffff8128a2b7>]
> netif_receive_skb+0x351/0x372
> May 20 13:11:00 ishtar kernel:  [<ffffffff8124150d>] tg3_poll+0x588/0x7df
> May 20 13:11:00 ishtar kernel:  [<ffffffff8128c2ce>] net_rx_action+0xb6/0x1bf
> May 20 13:11:00 ishtar kernel:  [<ffffffff8103919b>] __do_softirq+0x65/0xce
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100ce9c>] call_softirq+0x1c/0x28
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100e544>] do_softirq+0x2c/0x68
> May 20 13:11:00 ishtar kernel:  [<ffffffff810390f2>] irq_exit+0x3f/0x83
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100e813>] do_IRQ+0x13e/0x15f
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100c221>] ret_from_intr+0x0/0xa
> May 20 13:11:00 ishtar kernel:  <EOI>  [<ffffffff8100adc8>]
> default_idle+0x0/0x55
> May 20 13:11:00 ishtar kernel:  [<ffffffff8101c138>] lapic_next_event+0x0/0xa
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100adc8>] default_idle+0x0/0x55
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100adf9>] default_idle+0x31/0x55
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100adf4>] default_idle+0x2c/0x55
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100adc8>] default_idle+0x0/0x55
> May 20 13:11:00 ishtar kernel:  [<ffffffff8100ae94>] cpu_idle+0x77/0x9a
> May 20 13:11:00 ishtar kernel:
> May 20 13:11:00 ishtar kernel: ---[ end trace f970ab335f443aca ]---

