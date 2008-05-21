From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Wed, 21 May 2008 11:53:46 -0700
Message-ID: <20080521115346.21bf74f3.akpm@linux-foundation.org>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
	<20080521105747.215be17d.akpm@linux-foundation.org>
	<cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	=?ISO-8859-1?Q? "Ilpo_J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
To: "Brian Vowell" <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39061 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936602AbYEUSx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 14:53:56 -0400
In-Reply-To: <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008 11:40:43 -0700 "Brian Vowell" <brian.vowell@gmail.com> wrote:

> Please forgive my lack of technical skills-- I am not a developer.

Thank you for reporting this kernel bug!

> The bug report referenced below recently occurred on a pretty busy file
> server of mine running Fedora 8 with a custom 2.6.25.4 kernel.  The attached
> hardware RAID controller presents 12 LUNs, which were striped using the
> Linux mdadm tools, and then the Linux LVM was used to create a single
> logical volume.  The filesystem used is XFS.
> 
> Since upgrading from 2.6.25.3 to 2.6.25.4, my log has shown a large number
> of errors that I don't possess the skills to diagnose which component is
> actually causing the errors.  I can verify however, that the hardware is
> good.  I have run memtest86 and the vendor's diagnostic tools and verified
> that everything is running well.
> 
> The errors in /var/log/messages look like this:
> May 19 06:30:30 ishtar kernel: Call Trace:
> May 19 06:30:30 ishtar kernel:  <IRQ>  [<ffffffff81075d35>]
> __alloc_pages+0x33f/0x35a
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100e813>] do_IRQ+0x13e/0x15f
> May 19 06:30:30 ishtar kernel:  [<ffffffff810934a4>] new_slab+0x3f/0x242
> May 19 06:30:30 ishtar kernel:  [<ffffffff81093bba>]
> __slab_alloc+0x212/0x43b
> May 19 06:30:30 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 19 06:30:30 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 19 06:30:30 ishtar kernel:  [<ffffffff81094bd6>]
> __kmalloc_node_track_caller+0x75/0xab
> May 19 06:30:30 ishtar kernel:  [<ffffffff8128584a>] __alloc_skb+0x6a/0x133
> May 19 06:30:30 ishtar kernel:  [<ffffffff8128654c>]
> __netdev_alloc_skb+0x29/0x43
> May 19 06:30:30 ishtar kernel:  [<ffffffff8123a405>]
> tg3_alloc_rx_skb+0xc4/0x153
> May 19 06:30:30 ishtar kernel:  [<ffffffff81241343>] tg3_poll+0x3be/0x7df
> May 19 06:30:30 ishtar kernel:  [<ffffffff8128c2ce>]
> net_rx_action+0xb6/0x1bf
> May 19 06:30:30 ishtar kernel:  [<ffffffff8103919b>] __do_softirq+0x65/0xce
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100ce9c>] call_softirq+0x1c/0x28
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100e544>] do_softirq+0x2c/0x68
> May 19 06:30:30 ishtar kernel:  [<ffffffff810390f2>] irq_exit+0x3f/0x83
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100e813>] do_IRQ+0x13e/0x15f
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100c221>] ret_from_intr+0x0/0xa
> May 19 06:30:30 ishtar kernel:  <EOI>  [<ffffffff8100adc8>]
> default_idle+0x0/0x55
> May 19 06:30:30 ishtar kernel:  [<ffffffff8101c138>]
> lapic_next_event+0x0/0xa
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100adc8>] default_idle+0x0/0x55
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100adf9>] default_idle+0x31/0x55
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100adf4>] default_idle+0x2c/0x55
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100adc8>] default_idle+0x0/0x55
> May 19 06:30:30 ishtar kernel:  [<ffffffff8100ae94>] cpu_idle+0x77/0x9a
> 
> The hardware is an HP Proliant DL145G2, Dual Core Opteron 275 processor, 4GB
> of RAM, dual Broadcom GigE NICs bonded with Linux bonding driver, dual
> software RAID SATA disks for boot and swap.
> 
> The call trace included with the bug report is the only one that appears in
> the log with the "cut here" lines.
> 

OK, that is the TCP code performing self-checks and finding an
unexpected state.  

I was just a bit concerned about the "segfault" part of the
description.  Because often when the kernel crashes this appears to the
operator as a userspace segfault.  But the above trace isn't a kernel
crash - it's just a warning and the kernel does attept to fix things up
in this case.

If however you were really seeing unexpected segfaults then it could be
the case that the kernel is crashing.  But I assume this is not the
case, and that the text "Oops" does not appear in the logs.
