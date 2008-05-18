From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 14:29:26 +0200
Message-ID: <200805181429.27686.rjw@sisk.pl>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <200805181332.13941.rjw@sisk.pl> <20080518122433.GA16663@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:58678 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763289AbYERM3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 08:29:12 -0400
In-Reply-To: <20080518122433.GA16663@yamamaya.is-a-geek.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> Rafael J. Wysocki wrote:
> > On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> > > Rafael J. Wysocki wrote:
> > > > On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> > > > > Tobias Diedrich wrote:
> > > > > > > > Shouldn't there be a 'prepare for poweroff'-callback, which gets
> > > > > > > > called
> > > > > > > > before the system is powered off for real?
> > > > > > > 
> > > > > > > Yes, it should and it's called in recent kernels.
> > > > > > 
> > > > > > For what values of 'recent'?
> > > > > > I'm running 2.6.26-rc2 here. :)
> > > > > > How do I hook into this callback?
> > > > > > (suspend_late maybe? Going to try that one next...)
> > > > > 
> > > > > Ok, this patch fixes the 'regression' introduced by the previous
> > > > > patch (at least for me ;)):
> > > > 
> > > > Well, what exactly do you do to hibernate the box?
> > > 
> > > |#!/bin/sh
> > > |
> > > |SYSPRINTK=/proc/sys/kernel/printk
> > > |OLDPRINTK=$(cat $SYSPRINTK)
> > > |chvt 1
> > > |# work around forcedeth wake-on-lan bug
> > > |#rmmod forcedeth
> > > |echo 9 > $SYSPRINTK
> > > |# shutdown/reboot/platform
> > > |echo shutdown > /sys/power/disk
> > 
> > You don't see the devices' suspend callbacks invoked before powering off
> > because of this.  Change that to 'platform' (unless that breaks things).
> 
> Hmm, I think someone recommended to use shutdown since that is
> supposed to be more reliable.
> Anyway, I think the shutdown hook is good anyway since I suspect
> that if I do a normal system shutdown with promiscous mode still on,
> then wake-on-lan would also not work?
> I haven't checked that though.
> At least I think the shutdown hook won't hurt. :)

No, it won't.

> > I'm unable to comment on the device-specific things, but apart from this the
> > patch looks okay to me except for one thing.
> > > +	if (np->wolenabled) 
> > > +		pci_set_power_state(pdev, PCI_D3hot);
> > > +	else pci_set_power_state(pdev, PCI_D3cold);
> > 
> > I'm not sure if it's possible to put the device into D3cold without actually
> > removing power from it.
> 
> Ok, I've cleaned it up a bit and split it up properly (I think):
> http://www.tdiedrich.de/~ranma/patches/forcedeth/2.6.26-rc2/
> series:

Can you send those patches as a series of messages, please?

> forcedeth.resume.promisc.patch
> forcedeth.hibernate.wol.patch
> forcedeth.swappedmac.patch
> forcedeth.reorder_suspend_resume.patch

Thanks,
Rafael
