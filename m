From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 14:05:49 -0700
Message-ID: <20140506210549.GR19657@tassilo.jf.intel.com>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <20140506191447.GB4137@netboy>
 <20140506195049.GO19657@tassilo.jf.intel.com>
 <20140506200738.GA17813@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, David Miller <davem@davemloft.net>,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61384 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755023AbaEFVGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 17:06:11 -0400
Content-Disposition: inline
In-Reply-To: <20140506200738.GA17813@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 10:07:38PM +0200, Richard Cochran wrote:
> On Tue, May 06, 2014 at 12:50:49PM -0700, Andi Kleen wrote:
> > 
> > > So I think Dave is right
> > > in rejecting anything that compromises the _quality_ of the stack.
> > 
> > I don't think anything I removed compromised quality (modulo bugs)
> > It's still a more-features-than-your-typical-BSD TCP/IP stack
> 
> But Dave seems to think so.

Appeal to authority?

The vast majority of the patches only remove optional user interfaces.
If the single program running on the embedded system does not use these
interfaces it's simply dead code.

The patches that change non interface parts:

- Make FASTOPEN optional. FASTOPEN is a very expensive feature
because it pulls in the complete crypto subsystem.  It's also
a feature that needs to be explicitely enabled by the user program,
and I doubt is widely deployed
(my work station did exactly zero fast opens ever)
- Make TCP_METRICS optional, so connections don't share state.
- Simplify the routing table for the client < 10 routes case.
Works exactly the same as before with a small number of routes.
- Make GRO optional.
This is purely a performance feature for high bandwidth.

-Andi
