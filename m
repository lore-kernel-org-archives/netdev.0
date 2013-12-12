From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Thu, 12 Dec 2013 02:26:36 +0100
Message-ID: <20131212012636.GF4675@order.stressinduktion.org>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com> <20131211231236.GA8953@lion.mk-sys.cz> <20131211.195651.959794720995269703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mkubecek@suse.cz, jbenc@redhat.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49690 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab3LLB0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:26:37 -0500
Content-Disposition: inline
In-Reply-To: <20131211.195651.959794720995269703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 07:56:51PM -0500, David Miller wrote:
> From: Michal Kubecek <mkubecek@suse.cz>
> Date: Thu, 12 Dec 2013 00:12:36 +0100
> 
> > Is it really the case in current mainline kernels? In my tests, this
> > behaviour in 3.0 kernel (SLES 11 SP3) was caused by the reference held
> > by struct dst_entry which caused that in neigh_periodic_work(),
> > n->refcnt was always bigger than one so that the neighbour entry was
> > never cleaned up.  But when I tested with 3.11.6 (OpenSuSE 13.1) where
> > neighbour is no longer cached in struct dst_entry, the neighbour was
> > cleaned up eventually and new lookup was performed.
> 
> The detachment of neighbours from route entires has had many consequences,
> both desirable and undesirable.  This happens to be one of the former,
> fortunately :-)

In the end it was worth it. It fixed some very annoying bugs.

But while I wrote the previouss answer I noticed that we should actually
move the state of the probes from neigh->update to the rt6_info structure
as we cannot guarantee it will survive the 60 seconds in failed state. :/
