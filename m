From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 8 Apr 2008 18:32:52 +0200
Message-ID: <20080408163252.GS16647@one.firstfloor.org>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org> <7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55525 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649AbYDHQ22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 12:28:28 -0400
Content-Disposition: inline
In-Reply-To: <7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2008 at 05:38:47PM +0200, Juliusz Chroboczek wrote:
> > I think we have multiple qdiscs now doing very similar such hashes.
> > Any chance this could be factored out into a common library function 
> > first?
> 
> I'll be glad to do so.  Where shall I put it?

See Patrick's suggestion.

> > But in any case it is likely better you only get the
> > get_random_bytes() entropy once and then use that to init some kind
> > of RNG (either a secure one if it's for security or some random fast
> > one if it's not) and then use that output for rehashing.
> 
> Could do, but in that case the RNG should be shared between sfq and
> sfb.  Shall I simply use net_random (which calls random32) ?

no net_random/srandom32 is per CPU and likely does the wrong thing for you.

There was a new RND being scheduled to be merged with perfmon,
either use that or add a simple own (I assume your needs are not great)

-Andi

