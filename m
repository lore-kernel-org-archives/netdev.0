From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] fix MCA when shutting down tulip quad-NIC
Date: Tue, 10 Apr 2007 18:48:37 +0200
Message-ID: <20070410164837.GB508@aepfle.de>
References: <20070403211916.GA25570@aepfle.de> <20070405213415.GA22707@nifty>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: andrew.patterson@hp.com, netdev@vger.kernel.org
To: Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52543 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031102AbXDJQsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 12:48:00 -0400
Content-Disposition: inline
In-Reply-To: <20070405213415.GA22707@nifty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, Valerie Henson wrote:

> On Tue, Apr 03, 2007 at 11:19:16PM +0200, Olaf Hering wrote:
> > From: andrew.patterson@hp.com
> > 
> >  https://bugzilla.novell.com/show_bug.cgi?id=SUSE39204
> 
> Wow, registering for Novell's bugzilla is painful.  And in the end I
> get "Access denied" on that bug.  Can you give us this information
> some other way?

I did not see an easy way to make the bug public other than moving it to 
the openSuSE category.

> > Shutting down the network causes an MCA because of an IO TLB error when
> > a DEC quad 10/100 card is in any slot.  This problem was originally seen
> > on an HP rx4640.
> 
> I'm not clear on why pci_disable_device() would fix this bug.  Do you
> have an explanation (or can copy one out of the bug report)?  I'm
> hesitant to make even obviously correct changes to the tulip driver
> without good evidence, given the incredible variety of buggy hardware
> out there.

The comments in the bug do not have an detailed analysis.
One of the comments is:

...
Comment #1 From Andrew Patterson 2004-04-20 19:47:32 MST [reply]

1. ifdown the interfaces; then ifup them
2. do this in a loop from a script and it generally MCA's within 2 minutes.
...

The first version for 2.6.5 contained the pci_disable_device()
and a version which was commited to mainline:

http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=6379dd571265528f3911b9deafe2a29af2e71a2b

Later the patch contained just the pci_disable_device() call.

Andrew, does your testscript still fail in SLES10 or mainline?

> This looks to me like another iteration of the shutdown DMA/irq race
> at first glance.  Grant has a patch for it; I'm working on one I
> consider cleaner.

Thats likely the same issue.
http://www.linuxarkivet.se/mlists/linux-net/0409/msg00173.html
