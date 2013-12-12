From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Thu, 12 Dec 2013 02:21:15 +0100
Message-ID: <20131212012115.GE4675@order.stressinduktion.org>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com> <20131211231236.GA8953@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49674 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab3LLBVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:21:17 -0500
Content-Disposition: inline
In-Reply-To: <20131211231236.GA8953@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 12:12:36AM +0100, Michal Kubecek wrote:
> On Wed, Dec 11, 2013 at 01:48:20PM +0100, Jiri Benc wrote:
> > RFC 4191 states in 3.5:
> > 
> >    When a host avoids using any non-reachable router X and instead sends
> >    a data packet to another router Y, and the host would have used
> >    router X if router X were reachable, then the host SHOULD probe each
> >    such router X's reachability by sending a single Neighbor
> >    Solicitation to that router's address.  A host MUST NOT probe a
> >    router's reachability in the absence of useful traffic that the host
> >    would have sent to the router if it were reachable.  In any case,
> >    these probes MUST be rate-limited to no more than one per minute per
> >    router.
> > 
> > Currently, when the neighbour corresponding to a router falls into
> > NUD_FAILED, it's never considered again.
> 
> Is it really the case in current mainline kernels? In my tests, this
> behaviour in 3.0 kernel (SLES 11 SP3) was caused by the reference held
> by struct dst_entry which caused that in neigh_periodic_work(),
> n->refcnt was always bigger than one so that the neighbour entry was
> never cleaned up.  But when I tested with 3.11.6 (OpenSuSE 13.1) where
> neighbour is no longer cached in struct dst_entry, the neighbour was
> cleaned up eventually and new lookup was performed.

IMHO the wording is a big too strong. The *particular* neighbour is
never considered again as long as it survives in the NUD_FAILED state
(depending on the state of the reference counter this could be between
base_reachable_time and infinity in case of bugs ;) ).

But probing should happen at least every 60 seconds (or
router_probe_interval), which did not happen before this patch.

> I believe the patch would be useful anyway as it would speed up the
> detection that the router is reachable again, I just want to make sure
> my analysis wasn't completely wrong.

Yeah, I think your analysis is correct. Also you can see that (at least) I did
not considered this worth for -stable but only for net-next. ;)

Greetings,

  Hannes
