From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 10:08:46 -0800
Message-ID: <20080131100846.00934e25@extreme>
References: <20080131124632.GA25299@basil.nowhere.org>
	<20080131092327.75b9c369@extreme>
	<20080131183322.GA4671@one.firstfloor.org>
	<47A20CDC.5090104@trash.net>
	<20080131183735.GC4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49415 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754078AbYAaSJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:09:04 -0500
In-Reply-To: <20080131183735.GC4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jan 2008 19:37:35 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Thu, Jan 31, 2008 at 07:01:00PM +0100, Patrick McHardy wrote:
> > Andi Kleen wrote:
> > >>Fix the broken qdisc instead.
> > >
> > >What do you mean? I don't think the qdiscs are broken.
> > >I cannot think of any way how e.g. TBF can do anything useful
> > >with large TSO packets.
> > 
> > 
> > Someone posted a patch some time ago to calculate the amount
> > of tokens needed in max_size portions and use that, but IMO
> > people should just configure TBF with the proper MTU for TSO.
> 
> TBF with 64k atomic units will always be chunky and uneven. I don't
> think that's a useful goal. 
> 
> -Andi

Then change TBF to use skb_gso_segment?  Be careful, the fact that
one skb ends up queueing multiple skb's would cause issues to parent
qdisc (ie work generating qdisc).

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
