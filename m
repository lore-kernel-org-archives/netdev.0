From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Thu, 24 Apr 2008 22:01:00 +0200
Message-ID: <20080424200100.GA2900@ami.dom.local>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com> <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net> <20080308175721.GA3582@ami.dom.local> <2DAAA71E-5F03-41CA-B7E0-5BE4073D14F5@solitudo.net> <20080309173122.GA3339@ami.dom.local> <20080424142559.GA25023@solitudo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tuomas Jormola <tj@solitudo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:8274 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758295AbYDXUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 16:01:39 -0400
Received: by ug-out-1314.google.com with SMTP id z38so841961ugc.16
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 13:01:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080424142559.GA25023@solitudo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 05:25:59PM +0300, Tuomas Jormola wrote:
> Hi again,
> 
> On Sun, Mar 09, 2008 at 06:31:22PM +0100, Jarek Poplawski wrote:
> > On Sun, Mar 09, 2008 at 06:58:47PM +0200, Tuomas Jormola wrote:
> > ...
> > > there be new oopses, I will replace the old card with a newer Intel 
> > > gigabit card that I have laying around, and put it in a different PCI 
> > > slot.
> > 
> > The link I gave you described similar problem just with e1000.
> > The next message after this thread looks alike (e1000 driver).
> > So, you shouldn't hurry with this change. Just set this affinity
> > for both cards and check if it's respected.
> I've now run my system about a month with the following configuration. I
> replaced the very old e100 card with a newer e1000 PCI card and set
> affinity so that interrupts for the IRQs of both e1000e and e1000 cards
> are handled by a single CPU, and this is working very well.
> 
> (17:15:13)(tj@shakti)(~)$ grep eth /proc/interrupts 
>  18:   88113407       3780   IO-APIC-fasteoi   uhci_hcd:usb1, uhci_hcd:usb6, eth0
> 217:    9710797       4297   PCI-MSI-edge      eth1
> 
> (This is after about a 8 days of uptime, the affinity was set
> automatically in a local init script)

BTW, you could also try if setting affinity to different processors
works for you, i.e. irq 18 to cpu1 and irq 217 to cpu 2 (like described
in the earlier mentioned link).

> And with this, I've gotten rid of the OOPSes I had earlier. But is this
> really a feasible long term solution to the problem? I.e. if you're
> getting networking related OOPSes with SMP kernel on a box with two or
> more CPUs, the first thing you should do is to switch off the interrupt
> handling load balacing between the CPUs by issuing some obscure statment
> on the command line? I don't think that's very friendly advice for so
> called regular users... There's no way to work around it on the kernel
> side?

I looks like there are still attempts to fix this issue. Here is a
link to an interesting thread on this subject:

http://groups.google.com/group/linux.kernel/browse_thread/thread/6079876757758daa/43d38042acd9fb73?lnk=raot

Probably regular users shouldn't have such problems if they use
friendly distros.

> Also after installing the e1000 card, I've gotten a few of these dumps
> (see attachments) from the e1000 driver (during about a month, a dozen
> incidents, sometimes there might be 3 incidents a day, sometimes it
> takes a week when everything's normal.

Alas I'm not e1000 expert (this balancing advice is rather a general
issue). I've seen similar Tx hang reports, but it seems there could be
various reasons. Probably some of these could be fixed in current
kernels - did you try 2.6.25 BTW? Here is a case when turning off TSO
helped with something similar: 

http://bugzilla.kernel.org/show_bug.cgi?id=9808

So, if you still have these problems with current kernels and you are
willing to help in debugging this you should probably report this in
bugzilla too.

Regards,
Jarek P.
