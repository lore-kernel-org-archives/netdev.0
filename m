From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: More understanding HFSC
Date: Mon, 05 Dec 2011 23:07:03 -0500 (EST)
Message-ID: <9d4db616-7a02-4bb9-85e0-332f05d1463d@jasiiieee>
References: <4EDD4332.7090109@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:64020 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756385Ab1LFDGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 22:06:42 -0500
In-Reply-To: <4EDD4332.7090109@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Michal Soltys" <soltys@ziu.info>
> To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
> Cc: netdev@vger.kernel.org
> Sent: Monday, December 5, 2011 5:18:26 PM
> Subject: Re: More understanding HFSC
> 
> On 11-12-04 07:12, John A. Sullivan III wrote:
><snip> 
> > Very important for my understanding, specifying rt and ls in the
> > same
> > class is NOT the mechanism used for decoupling latency guarantees
> > from
> > bandwidth allocations.  That is simply specifying that available
> > bandwidth will be obtained in a different proportion than the
> > guaranteed bandwidth.
> 
> yes
> 
> > The decoupling of latency from bandwidth happens by having a
> > dilinear
> > service curve, i.e., specifying either m1, d, and m2 or specifying
> > umax, dmax, and rate where umax/dmax != rate.  Is that correct?
> 
> yes
> 
> > So, it then seems like: virtual time is dependent upon ls
> 
> yes
> 
> > eligible time is dependent upon available bandwidth as determined
> > by
> > ul and ls
> 
> no, eligible curve is derived from RT curve. For linear and concave
> curves it's the same as RT curve. For convex RT - eligible curve is
> linear using RT's second slope. The time calculated from it is
> relative
> to packets' heads - essentially answering question: which packets
> should
> be in transit already by current time (and for convex - which should
> be
> sent earlier, so when the curve is violated later by some other
> class(es), everything remains fine with reference to the amount of
> service received by some time). RT ignores LS/UL.
> 
> > deadline time is dependent on the curve which is why a dilinear
> > curve
> > can be used to "jump the queue" so to speak or to drop back in the
> > queue.
> 
> deadline curve is also derived from RT curve, and it's always of the
> same parameters. But packets tails are used here - essentialy
> answering
> question: what packet should go first (as only 1 can be send at a
> time
> after all). No relevance to LS/UL in any way or form either.
> 
> So more correct way to say is: RT *is* deadline and eligible.

Ah, OK.  I think I'm starting to get it.  I had read that but had not put it all together.  It all makes great sense.  So eligible time is answering the question of what packets should we start sending (hence looking at the beginning of the packet) and deadline is answering by when must the packet be fully delivered (hence looking at the tail).

<snip>
> later, though you might want to update the questions first by now :)
<snip>
I don't think what I've learned changes anything that I outlined in the rest of the email but I think I understand it a whole lot better now.  Thanks - John
