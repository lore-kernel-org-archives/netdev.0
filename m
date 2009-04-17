From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 23:27:24 +0200
Message-ID: <200904172327.25143.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <20090416.174145.225651742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	protasnb@gmail.com, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:43001 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306AbZDQV1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 17:27:35 -0400
In-Reply-To: <20090416.174145.225651742.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 17 April 2009, David Miller wrote:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Thu, 16 Apr 2009 23:42:31 +0200 (CEST)
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13099
> > Subject		: net, sky2: BUG: unable to handle kernel NULL pointer dereference, pci_vpd_truncate()
> > Submitter	: Ingo Molnar <mingo@elte.hu>
> > Date		: 2009-04-06 9:03 (11 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123900867611321&w=4
> > Handled-By	: Stephen Hemminger <shemminger@vyatta.com>
> 
> Fixed by:
> 
> commit d407e32efe060afa2b9a797a91376ebc65b4ce11
> Author: Anton Vorontsov <avorontsov@ru.mvista.com>
> Date:   Wed Apr 1 02:23:41 2009 +0400
> 
>     PCI: Fix oops in pci_vpd_truncate
>     
>     pci_vpd_truncate() should check for dev->vpd->attr, otherwise this might
>     happen:
>     
>       sky2 driver version 1.22
>       Unable to handle kernel paging request for data at address 0x0000000c
>       Faulting instruction address: 0xc01836fc
>       Oops: Kernel access of bad area, sig: 11 [#1]
>       [...]
>       NIP [c01836fc] pci_vpd_truncate+0x38/0x40
>       LR [c029be18] sky2_probe+0x14c/0x518
>       Call Trace:
>       [ef82bde0] [c029bda4] sky2_probe+0xd8/0x518 (unreliable)
>       [ef82be20] [c018a11c] local_pci_probe+0x24/0x34
>       [ef82be30] [c018a14c] pci_call_probe+0x20/0x30
>       [ef82be50] [c018a330] __pci_device_probe+0x64/0x78
>       [ef82be60] [c018a44c] pci_device_probe+0x30/0x58
>       [ef82be80] [c01aa270] really_probe+0x78/0x1a0
>       [ef82bea0] [c01aa460] __driver_attach+0xa4/0xa8
>       [ef82bec0] [c01a96ac] bus_for_each_dev+0x60/0x9c
>       [ef82bef0] [c01aa0b4] driver_attach+0x24/0x34
>       [ef82bf00] [c01a9e08] bus_add_driver+0x12c/0x1cc
>       [ef82bf20] [c01aa87c] driver_register+0x6c/0x110
>       [ef82bf30] [c018a770] __pci_register_driver+0x4c/0x9c
>       [ef82bf50] [c03782c8] sky2_init_module+0x30/0x40
>       [ef82bf60] [c0001dbc] do_one_initcall+0x34/0x1a0
>       [ef82bfd0] [c0362240] do_initcalls+0x38/0x58
>     
>     This happens with CONFIG_SKY2=y, and "ip=on" kernel command line, so
>     pci_vpd_truncate() is called before late_initcall(pci_sysfs_init),
>     therefore ->attr isn't yet initialized.
>     
>     Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>     Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
>     Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

Thanks, closed.

Rafael
