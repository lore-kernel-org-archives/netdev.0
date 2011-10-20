From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: validate HWTSTAMP ioctl parameters
Date: Thu, 20 Oct 2011 18:35:17 +0200
Message-ID: <20111020163516.GA1951@netboy.at.omicron.at>
References: <cover.1318584677.git.richard.cochran@omicron.at>
 <eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
 <1319059016.2829.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47700 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab1JTQfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 12:35:12 -0400
Received: by gyb13 with SMTP id 13so2968610gyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 09:35:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1319059016.2829.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 10:16:56PM +0100, Ben Hutchings wrote:
> On Fri, 2011-10-14 at 11:37 +0200, Richard Cochran wrote:
> > This patch adds a sanity check on the values provided by user space for
> > the hardware time stamping configuration. If the values lie outside of
> > the absolute limits, then the ioctl request will be denied.
> [...]
> 
> What does this validation buy us?  The driver still has to copy the
> values into kernel space again, at which point they may have been
> changed to be invalid.  Depending on how the driver uses them (perhaps
> as array indices), it may have to validate them again to avoid a
> security vulnerability.

Oops, you are right.

The drivers will really need to check the configuration again in any
case, since no driver will support every option.

I understood David's request as simply a sanity check on the absolute
limits.

> I think that either SIOCHWTSTAMP should be handled through a discrete
> device operation (not ndo_ioctl) which receives a pointer to the
> validated structure in kernel memory,

Okay, I'll take a stab at this.

> or a validation function should be
> exported to drivers so that they can call it from their ndo_ioctl
> implementations after copying the structure into kernel memory.

I think it better to do the sanity check in one place, to guard
against lazy or sloppy drivers.

Thanks,
Richard
