From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Tue, 2 Jul 2013 16:24:20 +0200
Message-ID: <20130702142420.GC14630@netboy>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:58977 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab3GBOYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 10:24:25 -0400
Received: by mail-ea0-f179.google.com with SMTP id b15so2840236eae.10
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 07:24:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

I really don't understand what the use case is...

On Mon, Jul 01, 2013 at 05:56:08PM +0100, Ben Hutchings wrote:
> Future Solarflare NICs may allow multiple PCI functions to make use of a
> PTP hardware clock, but without a separate clock per function (probably
> only one per controller).
> 
> I understand that shared PTP hardware clocks already exist, but they
> usually have an independent existence as a separate PCI or platform
> device.  In this case the clock would be accessible through any of the
> PCI functions that also have a net device.
> 
> Options I see are:
> 
> 1. Instantiate a clock only for the first function.  But that would
> preclude making the clock available within multiple VMs and their host.

So, I guess PCI functions on one card may be divided up among the
guests in a VM environment?

Even if you did make your one clock visible to mutiple guests, still
only one would be able to adjust the clock, right?

And if so, then how will the mutiple, read-only MAC clocks help other
guests? Seems kinda useless to me.
 
> 3. Keep track of controllers in the driver, instantiate a 'platform
> device' for each of them, and instantiate a clock for each of them.
> This is a little weird, as it wouldn't have any obvious association to
> the PCI device hierarchy.  But it would let us control the lifetime of
> the clock devices independently of any one function.

I think clock and MAC must go hand in hand. Does one card appear as a
MAC in more than one VM?

> I prefer option 3 as I dislike introducing special cases, but I would be
> interested to hear your (or other people's) opinion on this.

Sorry, my brain just isn't letting any of this in.

Thanks,
Richard
