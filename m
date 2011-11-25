From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 06:34:22 -0500
Message-ID: <1322220862.1908.79.camel@mojatatu>
References: <1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<1322201883.2872.19.camel@edumazet-laptop>
	<20111125.012517.2221372383643417980.davem@davemloft.net>
	<1322203013.2872.28.camel@edumazet-laptop>
Reply-To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322203013.2872.28.camel@edumazet-laptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


Hrm. I forgot about the flow classifier - it may be what the openflow
folks need. It is more friendly for the well defined tuples than u32.

But what do you mean "refactor"? I can already use this classifier
and attach actions to set policy in the kernel.

cheers,
jamal

On Fri, 2011-11-25 at 07:36 +0100, Eric Dumazet wrote:

> > > 
> > > Maybe its time to factorize the thing, eventually use it in a third
> > > component (Open vSwitch...)
> > 
> > Yes.
> 
> A third reason to do that anyway is that net/sched/sch_sfb.c should use
> __skb_get_rxhash() providing the perturbation itself, and not use the
> standard (hashrnd) one ).
> 
> Right now, if two flows share same rxhash, the double SFB hash will also
> share the same final hash.
> 
> (This point was mentioned by Florian Westphal)
> 
> 
> 
