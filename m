From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller (try
 #7)
Date: Mon, 3 Mar 2008 12:39:37 -0800
Message-ID: <20080303123937.2d72d7e8@extreme>
References: <20080303185624.GC2988@solarflare.com>
	<20080303.110206.36977456.davem@davemloft.net>
	<1204572175.16248.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958AbYCCUjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:39:46 -0500
In-Reply-To: <1204572175.16248.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Mar 2008 14:22:55 -0500
Dan Williams <dcbw@redhat.com> wrote:

> On Mon, 2008-03-03 at 11:02 -0800, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Mon, 3 Mar 2008 18:56:24 +0000
> > 
> > > The patch (against netdev-2.6) is at:
> > >   https://support.solarflare.com/netdev/7/netdev-2.6-sfc-2.2.0106.patch
> > 
> > Nobody can properly review the driver if it's off on some external web
> > site instead of posted here.
> 
> The diff is 707K; I certainly thought that netdev had a message size
> limit.  What's the proper policy on splitting up _new_ drivers?  There
> may/may not be a good way of splitting up any given new driver for
> piecemeal in-line review.  If there's not, what's the alternative?

Part of the problem is that you put a lot of stuff all in one driver:
  * sensors support
  * large debugfs chunk
  * efx driver layer
  * event queue

You created a big monolith. No one likes reading big stuff, it requires
lots of time, as much as going over a whole subsystem. The fact that so
many callbacks and hooks are needed implies that the design got out of hand
for a simple device.

Maybe an alternative would be to make your device better match existing
infrastructure. The EFX code looks like a separate driver which should
show up as a bus in the driver model, not a network device. Other people
who don't just do network device could help as well.
