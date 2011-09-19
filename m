From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 17:05:52 +0100
Message-ID: <1316448352.2764.27.camel@bwh-desktop>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316246677-8830-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316279044.14749.179.camel@deadeye>  <4E776441.9090602@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13107 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab1ISQFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 12:05:55 -0400
In-Reply-To: <4E776441.9090602@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-19 at 08:48 -0700, Alexander Duyck wrote:
> On 09/17/2011 10:04 AM, Ben Hutchings wrote:
> > On Sat, 2011-09-17 at 01:04 -0700, Jeff Kirsher wrote:
> >> From: Alexander Duyck<alexander.h.duyck@intel.com>
> >>
> >> This change is meant to make the NAPI budget limits for transmit
> >> adjustable.  By doing this it is possible to tune the value for optimal
> >> performance with applications such as routing.
> > [...]
> >> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> >> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> >> @@ -1989,6 +1989,9 @@ static int igb_set_coalesce(struct net_device *netdev,
> >>   	if ((adapter->flags&  IGB_FLAG_QUEUE_PAIRS)&&  ec->tx_coalesce_usecs)
> >>   		return -EINVAL;
> >>
> >> +	if (ec->tx_max_coalesced_frames_irq)
> >> +		adapter->tx_work_limit = ec->tx_max_coalesced_frames_irq;
> >> +
> > [...]
> >
> > I don't think it really makes sense to conflate NAPI and interrupt
> > moderation parameters.  This really ought to be added to NAPI itself.
> >
> > (NAPI contexts really ought to be exposed through sysfs somehow.  I
> > think we've discussed this before, and it's tricky due to the lack of a
> > consistent mapping between those contexts and net devices.)
> >
> > Ben.
> 
> All NAPI does is move things from a hard interrupt to a soft interrupt 
> in the case of TX cleanup.  If it wasn't for NAPI we would be calling 
> ixgbe_clean_tx_irq directly from the interrupt handler and would still 
> be using the same limiting value.  This is why placing it here makes sense.

But tx_max_coalesced_frames_irq is not supposed to be a work limit (and
such a work limit doesn't seem useful in the absence of NAPI).  As I
understand it, it is supposed to be an alternate moderation value for
the hardware to use if a frame is sent while the IRQ handler is running.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
