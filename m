From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Sat, 13 Sep 2003 09:39:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063442392.4455.47.camel@imladris.demon.co.uk>
References: <Pine.LNX.4.44.0309130642490.779-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309130642490.779-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-09-13 at 06:57 +0300, Pekka Savola wrote:
> The bottom line for that is: there is no longer a clear distinction of
> "inside" and "outside". 

To clarify... there currently is; you are saying that there shall not
be, and appear to believe personally that there _should_ not be.

>  Any design which assumes all the internal nodes
> can communicate freely with each other seems very subject to abuse, and
> multiple points of failure (where one node can compromise all of them).  
> For such communication, globals are the best -- there has to be internal
> filtering -- and gives no false sense of security which would rely on 
> addressing.

Whether you firewall your inter-office traffic at the borders is an
orthogonal issue, surely? In practice, since most hosts run the same
software, if you own one you might as well own them all _directly_
rather than via the one you owned. And since most people will log into
the most important servers from their own workstations, if you trojan
ssh you'll soon get there too... regardless of internal firewalling,
which _can't_ block port 22.

Besides, if they own one host, they can already use the internal IPv4
network to attack the rest. That's not going to be taken down overnight.

> Note that this is slightly different wrt. RFC1918 addresses.  Deploying
> both globals and site-locals makes the problem of "compromise one node,
> use it as a stepping stone to compromise all the local nodes" slightly
> worse.

If there are no blocks in ingress to the global addresses. To be honest,
I'd settle for putting the internal hosts behind NAT. We do not want
ingress -- except by SSH only, via a limited set of trusted bastion
hosts.

> Therefore, the use of "internal addresses" does not help with that except
> for very small sites (e.g. home, using dial-up and getting a different
> prefix every time, but the internal communication should stay stable), it
> only propagates bad design from IPv4 to IPv6.

Its 'badness' is a matter of opinion. I think we can objectively say
that it is a widely deployed and understood design, the absence of which
causes significant conceptual barriers to those attempting to deploy
IPv6.

> Applications are not supposed to know the scope, or be able (or even WANT) 
> to take any stance on the properties of addresses they're using.

So you advocate the non-routeable 'fc00::/7' addressses so that
applications _cannot_ know the scope and make sane decisions; stuff just
breaks instead. I don't see that this is an improvement.

> > At first glance, it seems that a lot of the problems go away if you
> > don't allow 'multi-sited' nodes, and more go away when you realise
> > they're already known and easily-avoided pitfalls of RFC1918 

> True, to an extent.

To a very large extent.

> > use a sane domain like 'company.internal' for site-local addresses.
> 
> Right, but not everybody may be content with that kind of approach..

That is their problem. And it'll continue to cause the same kind of
problems with 'leakage' that it does today; the kind of problem you want
to stop. Only instead of site-local addresses 'leaking' it's site-local
_names_. Are they going to ban schizodns too? :)

But again, that's an orthogonal problem. It didn't really live in the
document to which you referred me. The authors really seemed to be
clutching at straws by that point.

> > I'll just have to trust that whatever the replacement is, it also solves
> > the address-selection issues which site-local scope solves _perfectly_
> > for internal networks.
> 
> I doubt that, because the address selection is something that caused a 
> number of problems in the first place.  However, longest prefix match 
> gives a working communication in most cases.

OK.... so we go from a solution which gives a working communication in
_all_ cases, including the current case where we engineers are using
site-local addresses internally _long_ before persuading IS to allow
global routing, and our connections to hosts with both IPv4 and
IPv6-global addresses works fine since we only have site-local
addresses... to a situation far far worse.

RFC1918 may be a 'flawed' design to some people but it's almost
universally understood and deployed. The abolition of site-local
addresses is seems to be a huge barrier to adoption of IPv6. 

I suppose we could work with the fc00::/7 non-routeable addresses, and
NAT. Are people as opposed to IPv6-NAT as I was told they are? I'd
discounted that as a solution before even starting...


-- 
dwmw2
