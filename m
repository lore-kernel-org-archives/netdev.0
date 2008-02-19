From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: Linux 2.6.24.1 - kernel does not boot; IRQ trouble?
Date: Tue, 19 Feb 2008 09:47:23 +0100
Message-ID: <3ae72650802190047l5a1f07d9u5fc2031ac92608b6@mail.gmail.com>
References: <20080218085333.3d32b626@extreme>
	 <395400.45093.qm@web52907.mail.re2.yahoo.com>
	 <20080218120636.00451d46@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Chris Rankin" <rankincj@yahoo.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:53974 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbYBSIrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 03:47:24 -0500
Received: by wa-out-1112.google.com with SMTP id v27so3335883wah.23
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 00:47:23 -0800 (PST)
In-Reply-To: <20080218120636.00451d46@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 18, 2008 9:06 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> On Mon, 18 Feb 2008 19:42:25 +0000 (GMT)
> Chris Rankin <rankincj@yahoo.com> wrote:
>
> > --- Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > > > > sysfs: duplicate filename 'bridge' can not be created
> > > > > WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> > > > > Pid: 1, comm: swapper Not tainted 2.6.24.1 #1
> > > > >  [<c0105020>] show_trace_log_lvl+0x1a/0x2f
> > > > >  [<c0105990>] show_trace+0x12/0x14
> > > > >  [<c010613d>] dump_stack+0x6c/0x72
> > > > >  [<c01991bf>] sysfs_add_one+0x57/0xbc
> > > > >  [<c0199e41>] sysfs_create_link+0xc2/0x10d
> > > > >  [<c01bae9a>] pci_bus_add_devices+0xbd/0x103
> > > > >  [<c034016c>] pci_legacy_init+0x56/0xe3
> > > > >  [<c03274e1>] kernel_init+0x157/0x2c3
> > > > >  [<c0104c83>] kernel_thread_helper+0x7/0x10
> > > > >  =======================
> > > > > pci 0000:00:01.0: Error creating sysfs bridge symlink, continuing...
> > > > > sysfs: duplicate filename 'bridge' can not be created
> > > > > WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> > > > > Pid: 1, comm: swapper Not tainted 2.6.24.1 #1
> > > > >  [<c0105020>] show_trace_log_lvl+0x1a/0x2f
> > > > >  [<c0105990>] show_trace+0x12/0x14
> > > > >  [<c010613d>] dump_stack+0x6c/0x72
> > > > >  [<c01991bf>] sysfs_add_one+0x57/0xbc
> > > > >  [<c0199e41>] sysfs_create_link+0xc2/0x10d
> > > > >  [<c01bae9a>] pci_bus_add_devices+0xbd/0x103
> > > > >  [<c01bae82>] pci_bus_add_devices+0xa5/0x103
> > > > >  [<c034016c>] pci_legacy_init+0x56/0xe3
> > > > >  [<c03274e1>] kernel_init+0x157/0x2c3
> > > > >  [<c0104c83>] kernel_thread_helper+0x7/0x10
> > > > >  =======================
> > > >
> > > > I have a vague feeling that this was fixed, perhaps in 2.6.24.x?
> > >
> > > Never heard of this, what is the initialization script that causes this?
> > > Also do you have the SYSFS_DEPRECATED option configured? that caused issues
> > > with regular network drivers.
> >
> > Yes, SYSFS_DEPRECATED is enabled. And the init scripts are from Fedora 8.
>
> There was a bug (fixed in 2.6.24) that had to do with sysfs_create_link
> and SYSFS_DEPRECATED probably there is a similar problem with directories.

Chris, could you enable CONFIG_DEBUG_KOBJECT=y, it might show what
objects try to claim the same name.

Thanks,
Kay
