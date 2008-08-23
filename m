From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 15:12:25 +1000
Message-ID: <E1KWlQH-0001Ge-00@gondolin.me.apana.org.au>
References: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
Cc: davem@davemloft.net, jarkao2@gmail.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com (Alexander Duyck)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40189 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751233AbYHWFMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 01:12:40 -0400
In-Reply-To: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck <alexander.duyck@gmail.com> wrote:
> 
> That issue led me to the thought of creating a redirect action that
> would take the packet from one qdisc to the correct qdisc for the
> transmit queue.  That setup has two issues.  First, all traffic would
> need to go to one queue by default to avoid a possible deadlock
> condition in the event that two queues try to enqueue packets on one
> another at the same time.  That combined with the fact that one packet

That looks like a problem but it isn't.  When you're overriding
the default queue selection you're breaking CPU affinity.  As such
cache-line bouncing is clearly not a concern or you wouldn't be
doing this (that is, you're doing this for QOS rather than CPU
scalability).  So having everything go through a single qdisc
shouldn't be a problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
