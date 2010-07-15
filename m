From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Thu, 15 Jul 2010 12:18:32 +0300
Message-ID: <1279185512.2943.71.camel@powerslave>
References: <20100713001115.GA3751@sortiz-mobl>
	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>
	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper>
	 <4C3C9671.5090503@netfilter.org>  <4C3DA3F4.1060807@trash.net>
	 <1279110169.20985.41.camel@chilepepper> <4C3DE715.8070502@netfilter.org>
	 <4C3ECF6D.50409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C3ECF6D.50409@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-15 at 11:05 +0200, ext Patrick McHardy wrote:
> Am 14.07.2010 18:34, schrieb Pablo Neira Ayuso:
> >> It seems that there are lots of possibilities to get this to work, but
> >> this is starting to get quite complex.  I would still prefer having the
> >> NFNOTIF module included, since we would be able to do what we want in a
> >> very simple way.  It's also probably much more efficient that using
> >> several rules, which would increase the CPU usage considerably (in our
> >> device we are already reaching the limit of a reasonable CPU resource
> >> usage with high throughput WLAN connections).
> 
> Its hard to believe that a connmark match filtering out notifications
> would require more CPU time than doing the same in a new target module.

Okay, you have convinced me. :) I studied connmark a bit more and now I
realize that it won't take more CPU.  In the solution with connmark that
you proposed the packets coming from a connection that is already marked
will be quickly returned to normal processing, so it will be fairly
efficient and certainly not more CPU hungry than the NFNOTIF.


> >> While I agree that it is possible to achieve the NFNOTIF functionality
> >> with existing modules, I still think there is a "niche" for such module,
> >> because it is very simple, has a very clear purpose and would make the
> >> ruleset simpler and more efficient.
> >>
> >> Does this make any sense?
> > 
> > I don't think that the NFNOTIF infrastructure fulfill the policy for
> > inclusion. It seems to me like something quite specific for your needs.
> > It is simple, yes, but we already have this feature into the kernel. I
> > don't think that this will reduce CPU usage considerably with regards to
> > the NFLOG way.
> > 
> > I would still prefer adding the once-per-matching notification feature
> > to NFLOG than these extra lines in the kernel, Patrick?
> 
> I agree with Pablo.

I have to admit that you're right here again.  I think that it will not
be necessary to make this change in the NFLOG, since the connmark
solution is actually pretty clear too.  If needed, I'll make this simple
change in the NFLOG module and submit.

Thanks for your help.


-- 
Cheers,
Luca.

