From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/1] net: validate HWTSTAMP ioctl parameters
Date: Wed, 19 Oct 2011 22:16:56 +0100
Message-ID: <1319059016.2829.68.camel@bwh-desktop>
References: <cover.1318584677.git.richard.cochran@omicron.at>
	 <eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35442 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181Ab1JSVQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 17:16:59 -0400
In-Reply-To: <eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-14 at 11:37 +0200, Richard Cochran wrote:
> This patch adds a sanity check on the values provided by user space for
> the hardware time stamping configuration. If the values lie outside of
> the absolute limits, then the ioctl request will be denied.
[...]

What does this validation buy us?  The driver still has to copy the
values into kernel space again, at which point they may have been
changed to be invalid.  Depending on how the driver uses them (perhaps
as array indices), it may have to validate them again to avoid a
security vulnerability.

I think that either SIOCHWTSTAMP should be handled through a discrete
device operation (not ndo_ioctl) which receives a pointer to the
validated structure in kernel memory, or a validation function should be
exported to drivers so that they can call it from their ndo_ioctl
implementations after copying the structure into kernel memory.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
