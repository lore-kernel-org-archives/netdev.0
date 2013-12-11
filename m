From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Thu, 12 Dec 2013 00:12:36 +0100
Message-ID: <20131211231236.GA8953@lion.mk-sys.cz>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lion.mk-sys.cz ([213.168.178.121]:48133 "EHLO lion.mk-sys.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873Ab3LKXMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 18:12:39 -0500
Content-Disposition: inline
In-Reply-To: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 01:48:20PM +0100, Jiri Benc wrote:
> RFC 4191 states in 3.5:
> 
>    When a host avoids using any non-reachable router X and instead sends
>    a data packet to another router Y, and the host would have used
>    router X if router X were reachable, then the host SHOULD probe each
>    such router X's reachability by sending a single Neighbor
>    Solicitation to that router's address.  A host MUST NOT probe a
>    router's reachability in the absence of useful traffic that the host
>    would have sent to the router if it were reachable.  In any case,
>    these probes MUST be rate-limited to no more than one per minute per
>    router.
> 
> Currently, when the neighbour corresponding to a router falls into
> NUD_FAILED, it's never considered again.

Is it really the case in current mainline kernels? In my tests, this
behaviour in 3.0 kernel (SLES 11 SP3) was caused by the reference held
by struct dst_entry which caused that in neigh_periodic_work(),
n->refcnt was always bigger than one so that the neighbour entry was
never cleaned up.  But when I tested with 3.11.6 (OpenSuSE 13.1) where
neighbour is no longer cached in struct dst_entry, the neighbour was
cleaned up eventually and new lookup was performed.

I believe the patch would be useful anyway as it would speed up the
detection that the router is reachable again, I just want to make sure
my analysis wasn't completely wrong.

                                                        Michal Kubecek
