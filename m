From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [RESEND] [NET] fib_rules: Flush route cache after rule modifications
Date: Thu, 29 Mar 2007 12:03:26 +0200
Message-ID: <20070329100326.GA1772@ff.dom.local>
References: <20070327133845.GM521@postel.suug.ch> <20070328111921.GA2703@ff.dom.local> <20070328154903.GO521@postel.suug.ch> <20070328.112417.08322226.davem@davemloft.net> <20070328193436.GP521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	muli@il.ibm.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:45071 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750797AbXC2J6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 05:58:40 -0400
Content-Disposition: inline
In-Reply-To: <20070328193436.GP521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 09:34:36PM +0200, Thomas Graf wrote:
> * David Miller <davem@davemloft.net> 2007-03-28 11:24
> > Another idea Thomas and I tossed around was to have some kind of way
> > for the rule insertion to indicate that the flush should be deferred
> > and I kind of prefer that explicitness.
> 
> Right, although I believe the flag should not only defer it
> but not flush at all. This would be the optimal solution
> for scripts which can do a ip ro flush cache as they know
> what they're doing.
> 
> > By default it's better the flush immediately, because the old
> > behavior is totally unexpected.  "I insert a rule and it dosn't
> > show up?", nobody expects that.
> 
> It's a tough call, I'd favour immediate flush as well but I can
> see the point in delaying by ip_rt_min_delay which can be
> configured by the user. So people can choose to immediately flush
> by setting it to 0. It would also be consistent to the flush
> after route changes, the same delay is used there.
> 

Of course you both are right - but (...I've some doubts):

- there is a difference between tools: route or ip route
(as a successor) and ip rule; the latter is intended for
advanced things, so users have to expect... (or RTFM!).
 
- of course immediate flush seems to be more natural, but
it isn't like that and rules (other rules) are changed,
so maybe some transitory way is needed; these 2s look
like a good compromise, but after looking into
rt_cache_flush - it's not for all (I know - we don't like
multipath - but untill it's here...) and these locks and
timers aren't for free, too; so, IMHO, something like
-n[oflush] option is a mustbe.

- for consistency probably all ip "objects" should be
verified: "to flush or not to flush" by default.

Cheers,
Jarek P.
