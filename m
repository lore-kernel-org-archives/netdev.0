From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: RX lockup fix
Date: Fri, 14 Dec 2007 15:26:59 -0500
Message-ID: <4762E713.1070605@pobox.com>
References: <1196880663.2816.149.camel@localhost.localdomain>	<20071205164058.157275a9@shemminger-laptop>	<1196900326.21996.1.camel@localhost.localdomain>	<20071205225249.0f46672c@shemminger-laptop>	<1196957697.24978.24.camel@localhost.localdomain> <20071207152215.0267c407@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Tyser <ptyser@xes-inc.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42985 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177AbXLNU1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 15:27:20 -0500
In-Reply-To: <20071207152215.0267c407@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> I'm using a Marvell 88E8062 on a custom PPC64 blade and ran into RX
> lockups while validating the sky2 driver.  The receive MAC FIFO would
> become stuck during testing with high traffic.  One port of the 88E8062
> would lockup, while the other port remained functional.  Re-inserting
> the sky2 module would not fix the problem - only a power cycle would.
> 
> I looked over Marvell's most recent sk98lin driver and it looks like
> they had a "workaround" for the Yukon XL that the sky2 doesn't have yet.
> The sk98lin driver disables the RX MAC FIFO flush feature for all
> revisions of the Yukon XL.
> 
> According to skgeinit.c of the sk98lin driver, "Flushing must be enabled
> (needed for ASF see dev. #4.29), but the flushing mask should be
> disabled (see dev. #4.115)".  Nice. I implemented this same change in
> the sky2 driver and verified that the RX lockup I was seeing was
> resolved.
> 
> Signed-off-by: Peter Tyser <ptyser@xes-inc.com>
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
> Original patch reformatted to remove line wrap.

applied #upstream-fixes


