From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 10767] New: Seg Fault Instead of Swapping
Date: Wed, 21 May 2008 23:18:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805212310050.7747@wrl-59.cs.helsinki.fi>
References: <bug-10767-10286@http.bugzilla.kernel.org/>
 <20080521105747.215be17d.akpm@linux-foundation.org>
 <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Brian Vowell <brian.vowell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53472 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757257AbYEUUSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 16:18:07 -0400
In-Reply-To: <cf4145200805211140o3b2287dcsc57f8a78aa48a99d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008, Brian Vowell wrote:

> Please forgive my lack of technical skills-- I am not a developer.

And I'm having problem in figuring out what is actually being reported 
here... so pleasy forgive my possibly stupid comments... :-)

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

At least the TCP thing is known to be in core TCP but it's just hard to 
debug and that's why it hasn't yet been closed, no hw is suspect due to 
it. But this other stacktrace seems to be something unrelated to TCP...:

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
> 
> 
> 
> On 5/21/08, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> >
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > On Wed, 21 May 2008 02:45:59 -0700 (PDT) bugme-daemon@bugzilla.kernel.orgwrote:
> >
> > > http://bugzilla.kernel.org/show_bug.cgi?id=10767
> > >
> > >            Summary: Seg Fault Instead of Swapping
> >
> > Strange description?
> >
> > >            Product: Networking
> > >            Version: 2.5
> > >      KernelVersion: 2.6.25.4
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: IPV4
> > >         AssignedTo: shemminger@linux-foundation.org
> > >         ReportedBy: brian.vowell@gmail.com
> > >
> > >
> > > May 20 13:11:00 ishtar kernel: ------------[ cut here ]------------
> > > May 20 13:11:00 ishtar kernel: WARNING: at net/ipv4/tcp_input.c:2539
> > > tcp_ack+0xd2b/0x191f()
> >
> > In 2.6.25 this is
> >
> >         if (WARN_ON(!tp->sacked_out && tp->fackets_out))
> >                 tp->fackets_out = 0;

...This TCP warning isn't sign of a problem that would cause corruption of 
any kind (and the state inconsistency gets repaired there as well!), we're 
debugging this already with couple of other people, so unless you have 
some very good reproducer case you'll just have to wait a bit.

-- 
 i.
