From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 19:37:10 +0200
Message-ID: <20120921173709.GB6129@netboy.at.omicron.at>
References: <cover.1348245523.git.richardcochran@gmail.com>
 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43681 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070Ab2IURhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:37:21 -0400
Received: by wgbdr13 with SMTP id dr13so1615246wgb.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 10:37:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 06:19:25PM +0100, Ben Hutchings wrote:
> On Fri, 2012-09-21 at 19:00 +0200, Richard Cochran wrote:
> > PTP Hardware Clock device have a name that appears under sysfs that should
> > identify the underlying device. Instead of leaving it up to the driver to
> > invent a name, this patch changes the registration to automatically use
> > the name from the parent device.
> 
> I thought you wanted the driver name and not the parent device name?

Yes, I originally wanted the driver name, because it gives the user
information about the expected performance. But here I am bowing to
Jacob's suggestion that we really need to identify the device. Intel
cards with two ports have *two* clocks. Sad but true.

> > +       ptp->name = parent ? dev_name(parent) : dev_name(ptp->dev);
> > +
> 
> The fallback of using dev_name(ptp->dev) is a bit sad, as that's the
> same name userland already has when it reads this attribute.

This fallback only exists for the ixp46x, since that driver has no
proper platform or device tree device.

> > -	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps);
> > +	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps, NULL);
> [...]
> 
> I think this should really register a platform driver and a platform
> device to be the parent of the clock device.  And then you don't need
> the fallback for parent == NULL.

That chip is long past EOL, and its PTP capabilities are pretty poor,
and so it is not worth the trouble of fixing it up.

All other (and future) drivers must provide the pointer.
 
> Since David has pulled the addition of PTP/PHC support to sfc, that will
> need to be adjusted as well.

Okay, I will add that to the series.

Thanks,
Richard
