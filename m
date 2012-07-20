From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 4/7] sfc: Add support for IEEE-1588 PTP
Date: Fri, 20 Jul 2012 08:11:32 +0200
Message-ID: <20120720061132.GA2330@netboy.at.omicron.at>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
 <1342635693.2617.56.camel@bwh-desktop.uk.solarflarecom.com>
 <20120719142558.GB24484@localhost.localdomain>
 <1342708653.2617.33.camel@bwh-desktop.uk.solarflarecom.com>
 <50083059.7070700@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Andrew Jackson <ajackson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:45346 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab2GTGLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 02:11:43 -0400
Received: by wgbfm10 with SMTP id fm10so189517wgb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 23:11:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <50083059.7070700@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 05:05:45PM +0100, Andrew Jackson wrote:
> On 19/07/2012 15:37, Ben Hutchings wrote:
> >On Thu, 2012-07-19 at 16:25 +0200, Richard Cochran wrote:
> >>
> >>I am trying to purge the whole SYS thing (only blackfin is left)
> >>because there is a much better way to go about this, namely
> >>synchronizing the system time to the PHC time via an internal PPS
> >>signal.
> >
> >Andrew, would that work for us?
> 
> I don't think so for the reason that Stu has pointed out (failed
> assumption).
> 
> The NIC's clock isn't directly accessible by the host from the PCIe
> bus and is "behind" the MC. Even when we process PPS events, we need
> a reliable way of determining the relationship between the two
> clocks (system <> NIC). We're trying to get that as accurately as we
> can but we know that some measurements will be incorrect/out of
> bounds because of loading on the system.

There is a better way to filter out bad measurements than to hard code
some black magic into the driver. Instead, just offer a PPS, and then
we can comfortably (and flexibly) filter using a user space program.

Thanks,
Richard
