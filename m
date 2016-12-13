From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Tue, 13 Dec 2016 05:30:27 +0200
Message-ID: <20161213051621-mutt-send-email-mst@kernel.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <20161213042057-mutt-send-email-mst@kernel.org>
 <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com,
        davem@davemloft.net
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932176AbcLMDa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 22:30:29 -0500
Content-Disposition: inline
In-Reply-To: <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 10:12:43PM -0500, Theodore Ts'o wrote:
> On Tue, Dec 13, 2016 at 04:28:17AM +0200, Michael S. Tsirkin wrote:
> > 
> > That's unfortunate, of course. It could be a hypervisor or
> > a guest kernel bug. ideas:
> > - does host have mq capability? how many queues?
> > - how about # of msix vectors?
> > - after you send something on tx queues,
> >   are interrupts arriving on rx queues?
> > - is problem rx or tx?
> >   set ip and arp manually and send a packet to known MAC,
> >   does it get there?
> 
> Sorry, I don't know how to debug virtio-net.  Given that it's in a
> cloud environment, I also can't set ip addresses manually, since ip
> addresses are set manually.

OK, but you can send raw ethernet frames preseumably?


> If you can send me a patch, I'm happy to apply it and send you back
> results.

Let's start with collecting stats from sysfs for this device.
pls get features bitmap from there,
pls get /proc/interrupts mappings,
and pls use lspci to dump pci config.


> I can say that I've had _zero_ problems using pretty much any kernel
> from 3.10 to 4.9 using Google Compute Engine.  The commit I referenced
> caused things to stop working.  So in terms of regression, this is
> definitely a regression, and it's definitely caused by commit
> 449000102901.  Even if it is a hypervisor "bug", I'm pretty sure I
> know what Linus will say if I ask him to revert it.  Linux kernels are
> expected to work around hardware bugs, and breaking users just because
> hardware is "broken" by some definition is generally not considered
> friendly, especially when has been working for years and years before
> some commit "fixed" things.

I'm open to limiting new features to virtio 1 mode just to
avoid the hassle of dealing with legacy hypervisors.
But let's not argue about it until we know the root cause.

> 
> I would very much like to work with you to fix it, but I will need
> your help, since virtio-net doesn't seem to print any informational
> during the boot sequence, and I don't know how the best way to debug
> it.
> 
> Cheers,
> 
> 						- Ted


Let's start with debugging it like any PCI NIC.


-- 
MST
