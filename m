From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Fri, 28 Sep 2012 14:33:07 +0800
Message-ID: <1348813987.7264.41.camel@cr0>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
	 <20120927142334.GA3194@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995Ab2I1GeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 02:34:07 -0400
In-Reply-To: <20120927142334.GA3194@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 10:23 -0400, Neil Horman wrote:
> On Thu, Sep 27, 2012 at 04:41:01PM +0800, Cong Wang wrote:
> > Some customer requests this feature, as they stated:
> > 
> > 	"This parameter is necessary, especially for software that continually 
> >         creates many ephemeral processes which open sockets, to avoid socket 
> >         exhaustion. In many cases, the risk of the exhaustion can be reduced by 
> >         tuning reuse interval to allow sockets to be reusable earlier.
> > 
> >         In commercial Unix systems, this kind of parameters, such as 
> >         tcp_timewait in AIX and tcp_time_wait_interval in HP-UX, have 
> >         already been available. Their implementations allow users to tune 
> >         how long they keep TCP connection as TIME-WAIT state on the 
> >         millisecond time scale."
> > 
> > We indeed have "tcp_tw_reuse" and "tcp_tw_recycle", but these tunings
> > are not equivalent in that they cannot be tuned directly on the time
> > scale nor in a safe way, as some combinations of tunings could still
> > cause some problem in NAT. And, I think second scale is enough, we don't
> > have to make it in millisecond time scale.
> > 
> I think I have a little difficultly seeing how this does anything other than
> pay lip service to actually having sockets spend time in TIME_WAIT state.  That
> is to say, while I see users using this to just make the pain stop.  If we wait
> less time than it takes to be sure that a connection isn't being reused (either
> by waiting two segment lifetimes, or by checking timestamps), then you might as
> well not wait at all.  I see how its tempting to be able to say "Just don't wait
> as long", but it seems that theres no difference between waiting half as long as
> the RFC mandates, and waiting no time at all.  Neither is a good idea.

I don't think reducing TIME_WAIT is a good idea either, but there must
be some reason behind as several UNIX provides a microsecond-scale
tuning interface, or maybe in non-recycle mode, their RTO is much less
than 2*MSL?

> 
> Given the problem you're trying to solve here, I'll ask the standard question in
> response: How does using SO_REUSEADDR not solve the problem?  Alternatively, in
> a pinch, why not reduce the tcp_max_tw_buckets sufficiently to start forcing
> TIME_WAIT sockets back into CLOSED state?
> 
> The code looks fine, but the idea really doesn't seem like a good plan to me.
> I'm sure HPUX/Solaris/AIX/etc have done this in response to customer demand, but
> that doesn't make it the right solution.
> 

*I think* the customer doesn't want to modify their applications, so
that is why they don't use SO_REUSERADDR.

I didn't know tcp_max_tw_buckets can do the trick, nor the customer, so
this is a side effect of tcp_max_tw_buckets? Is it documented?

Thanks.
