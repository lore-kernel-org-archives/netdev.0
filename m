From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] sysfs: Don't allow the creation of symlinks we can't
 remove
Date: Mon, 19 Jul 2010 13:34:51 -0700
Message-ID: <20100719133451.0862ca62.akpm@linux-foundation.org>
References: <20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org>
	<20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org>
	<20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org>
	<20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com>
	<m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58972 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936465Ab0GSUgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 16:36:37 -0400
In-Reply-To: <20100708230601.GB17002@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jul 2010 16:06:01 -0700
Greg KH <greg@kroah.com> wrote:

> On Thu, Jul 08, 2010 at 03:28:53PM -0700, Eric W. Biederman wrote:
> > Greg KH <greg@kroah.com> writes:
> > 
> > > With this patch, how does the existing code fail as the drivers aren't
> > > fixed up?
> > >
> > > I like this change, just worried it will cause problems if it gets into
> > > .35, without your RFC patch.  Will it?
> > 
> > It don't expect this patch to be worse than where we are current at.
> > Network devices are renamed, and come and go enough that both the
> > mac80211_hwsim and the bnep driver are currently unusable with a
> > failure only the rename and remove.
> > 
> > This patch simply moves the failure into creation where we are a little more
> > prepared to deal with problems, and this patch is limited to mac80211_hwsim,
> > bnep, and any hypothetically undiscovered other network devices that
> > have the same problem.
> > 
> > mac80211_hwsim with just this patch becomes somewhat usable as it's primary
> > network device gets registered and the module can be loaded and unloaded.  It
> > just doesn't create the wlan0 and wlan1 interfaces for the wifi interfaces.
> 
> Fair enough, I've commited it now, let's see what happens :)

geethanks!

On the FC6 test box I have no networking.

akpm2:/usr/src/25> grep E1000 .config 
CONFIG_E1000=y
CONFIG_E1000E=y


calling  e1000_init_module+0x0/0x84 @ 1
e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k6-NAPI
e1000: Copyright (c) 1999-2006 Intel Corporation.
initcall e1000_init_module+0x0/0x84 returned 0 after 252 usecs
calling  e1000_init_module+0x0/0x3e @ 1
e1000e: Intel(R) PRO/1000 Network Driver - 1.2.7-k2
e1000e: Copyright (c) 1999 - 2010 Intel Corporation.
e1000e 0000:05:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
e1000e 0000:05:00.0: setting latency timer to 64
e1000e 0000:05:00.0: irq 74 for MSI/MSI-X
------------[ cut here ]------------
WARNING: at fs/sysfs/symlink.c:82 sysfs_do_create_link+0x140/0x19a()
sysfs: symlink across ns_types 0000:05:00.0/net:eth0 -> net/eth0
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.35-rc5 #1
Call Trace:
[<ffffffff81111b21>] ? sysfs_do_create_link+0x140/0x19a
[<ffffffff81036283>] warn_slowpath_common+0x7e/0x97
[<ffffffff8103631c>] warn_slowpath_fmt+0x69/0x6b
[<ffffffff81055ffb>] ? debug_mutex_free_waiter+0x4c/0x50
[<ffffffff811107f3>] ? sysfs_addrm_start+0x25/0x27
[<ffffffff811107f3>] ? sysfs_addrm_start+0x25/0x27
[<ffffffff81111b21>] sysfs_do_create_link+0x140/0x19a
[<ffffffff810595b2>] ? trace_hardirqs_on+0xd/0xf
[<ffffffff81111b96>] sysfs_create_link+0xe/0x10
[<ffffffff8121451d>] device_add+0x299/0x5b2
[<ffffffff812195f4>] ? device_pm_init+0x30/0x3f
[<ffffffff812edea0>] netdev_register_kobject+0x79/0x159
[<ffffffff812dfd00>] register_netdevice+0x272/0x31a
[<ffffffff812dfde2>] register_netdev+0x3a/0x48
[<ffffffff813677a8>] e1000_probe+0x956/0xb05
[<ffffffff81375267>] ? _raw_spin_unlock+0x23/0x28
[<ffffffff8119916c>] local_pci_probe+0x12/0x16
[<ffffffff811995bc>] pci_device_probe+0xca/0xf4
[<ffffffff8121662e>] ? driver_sysfs_add+0x4a/0x70
[<ffffffff81216879>] driver_probe_device+0xa1/0x137
[<ffffffff81216968>] __driver_attach+0x59/0x7d
[<ffffffff8121690f>] ? __driver_attach+0x0/0x7d
[<ffffffff8121560c>] bus_for_each_dev+0x4f/0x80
[<ffffffff81216449>] driver_attach+0x1c/0x1e
[<ffffffff81216190>] bus_add_driver+0xb4/0x206
[<ffffffff81216d87>] driver_register+0x92/0xff
[<ffffffff81198cea>] __pci_register_driver+0x60/0xbd
[<ffffffff81a159c8>] ? e1000_init_module+0x0/0x3e
[<ffffffff81a15a04>] e1000_init_module+0x3c/0x3e
[<ffffffff810002cb>] do_one_initcall+0x52/0x13f
[<ffffffff819edcc6>] kernel_init+0x140/0x1c9
[<ffffffff81003814>] kernel_thread_helper+0x4/0x10
[<ffffffff81375cfc>] ? restore_args+0x0/0x30
[<ffffffff819edb86>] ? kernel_init+0x0/0x1c9
[<ffffffff81003810>] ? kernel_thread_helper+0x0/0x10
---[ end trace 948c9041178f15c8 ]---


