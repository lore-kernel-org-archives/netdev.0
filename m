From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 21:48:03 +0300
Message-ID: <20160310184803.GD21154@uranus.lan>
References: <20160310102018.GA21154@uranus.lan>
 <20160310110324.GB21154@uranus.lan>
 <20160310150920.GC21154@uranus.lan>
 <20160310.130138.1302349043066531127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160310.130138.1302349043066531127.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 01:01:38PM -0500, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Thu, 10 Mar 2016 18:09:20 +0300
> 
> > On Thu, Mar 10, 2016 at 02:03:24PM +0300, Cyrill Gorcunov wrote:
> >> On Thu, Mar 10, 2016 at 01:20:18PM +0300, Cyrill Gorcunov wrote:
> >> > On Thu, Mar 10, 2016 at 12:16:29AM +0300, Cyrill Gorcunov wrote:
> >> > > 
> >> > > Thanks for explanation, Dave! I'll continue on this task tomorrow
> >> > > tryin to implement optimization you proposed.
> >> > 
> >> > OK, here are the results for the preliminary patch with conntrack running
> >> ...
> >> >  net/ipv4/devinet.c |   13 ++++++++++++-
> >> >  1 file changed, 12 insertions(+), 1 deletion(-)
> >> > 
> >> > Index: linux-ml.git/net/ipv4/devinet.c
> >> > ===================================================================
> >> > --- linux-ml.git.orig/net/ipv4/devinet.c
> >> > +++ linux-ml.git/net/ipv4/devinet.c
> >> > @@ -403,7 +403,18 @@ no_promotions:
> >> >  	   So that, this order is correct.
> >> >  	 */
> >> 
> >> This patch is wrong, so drop it please. I'll do another.
> > 
> > Here I think is a better variant. The resulst are good
> > enough -- 1 sec for cleanup. Does the patch look sane?
> 
> I'm tempted to say that we should provide these notifier handlers with
> the information they need, explicitly, to handle this case.
> 
> Most intdev notifiers actually want to know the individual addresses
> that get removed, one by one.  That's handled by the existing
> NETDEV_DOWN event and the ifa we pass to that.
> 
> But some, like this netfilter masq case, would be satisfied with a
> single event that tells them the whole inetdev instance is being torn
> down.  Which is the case we care about here.
> 
> We currently don't use NETDEV_UNREGISTER for inetdev notifiers, so
> maybe we could use that.
> 
> And that is consistent with the core netdev notifier that triggers
> this call chain in the first place.
> 
> Roughly, something like this:

I see. Dave, gimme some time to test but I'm sure it'll work.
I don't have some strong opinion here, so your patch looks
pretty fine to me. But maybe people from netdev camp have
some other ideas.

