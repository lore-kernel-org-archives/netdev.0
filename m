From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: RX lockup fix
Date: Wed, 5 Dec 2007 16:40:58 -0500
Message-ID: <20071205164058.157275a9@shemminger-laptop>
References: <1196880663.2816.149.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Tyser <ptyser@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35051 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbXLEVlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 16:41:50 -0500
In-Reply-To: <1196880663.2816.149.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Dec 2007 12:51:03 -0600
Peter Tyser <ptyser@xes-inc.com> wrote:

> Hello,
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
> disabled (see dev. #4.115)".  Nice.   I implemented this same change in
> the sky2 driver and verified that the RX lockup I was seeing was
> resolved.
> 


Without the flush, does flow control still work? My concern is that
integrating this would cause pause packets (and over/under length packets)
to not be handled correctly.
