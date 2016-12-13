From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Mon, 12 Dec 2016 22:12:43 -0500
Message-ID: <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <20161213042057-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com,
        davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:46686 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751569AbcLMDMt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 22:12:49 -0500
Content-Disposition: inline
In-Reply-To: <20161213042057-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 04:28:17AM +0200, Michael S. Tsirkin wrote:
> 
> That's unfortunate, of course. It could be a hypervisor or
> a guest kernel bug. ideas:
> - does host have mq capability? how many queues?
> - how about # of msix vectors?
> - after you send something on tx queues,
>   are interrupts arriving on rx queues?
> - is problem rx or tx?
>   set ip and arp manually and send a packet to known MAC,
>   does it get there?

Sorry, I don't know how to debug virtio-net.  Given that it's in a
cloud environment, I also can't set ip addresses manually, since ip
addresses are set manually.

If you can send me a patch, I'm happy to apply it and send you back
results.

I can say that I've had _zero_ problems using pretty much any kernel
from 3.10 to 4.9 using Google Compute Engine.  The commit I referenced
caused things to stop working.  So in terms of regression, this is
definitely a regression, and it's definitely caused by commit
449000102901.  Even if it is a hypervisor "bug", I'm pretty sure I
know what Linus will say if I ask him to revert it.  Linux kernels are
expected to work around hardware bugs, and breaking users just because
hardware is "broken" by some definition is generally not considered
friendly, especially when has been working for years and years before
some commit "fixed" things.

I would very much like to work with you to fix it, but I will need
your help, since virtio-net doesn't seem to print any informational
during the boot sequence, and I don't know how the best way to debug
it.

Cheers,

						- Ted
