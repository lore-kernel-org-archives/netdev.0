From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 20:01:25 +0100
Message-ID: <20080131190125.GE4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44696 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764075AbYAaS07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:26:59 -0500
Content-Disposition: inline
In-Reply-To: <47A211A0.1040502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 07:21:20PM +0100, Patrick McHardy wrote:
> Andi Kleen wrote:
> >>Then change TBF to use skb_gso_segment?  Be careful, the fact that
> >
> >That doesn't help because it wants to interleave packets
> >from different streams to get everything fair and smooth. The only 
> >good way to handle that is to split it up and the simplest way to do 
> >this is to just tell TCP to not do GSO in the first place.
> 
> 
> Thats not correct, TBF keeps packets strictly ordered unless

My point was that without TSO different submitters will interleave
their streams (because they compete about the qdisc submission) 
and then you end up with a smooth rate over time for all of them.

If you submit in large chunks only (as TSO does) it will always 
be more bursty and that works against the TBF goal.

For a single submitter you would be correct.

-Andi
