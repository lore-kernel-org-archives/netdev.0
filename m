From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Mon, 15 Sep 2003 08:16:47 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309150806210.26010-100000@netcore.fi>
References: <1063442392.4455.47.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063442392.4455.47.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Sep 2003, David Woodhouse wrote:
> On Sat, 2003-09-13 at 06:57 +0300, Pekka Savola wrote:
> > The bottom line for that is: there is no longer a clear distinction of
> > "inside" and "outside". 
> 
> To clarify... there currently is; you are saying that there shall not
> be, and appear to believe personally that there _should_ not be.

Yep, and I'm not alone with this :-)
 
> >  Any design which assumes all the internal nodes
> > can communicate freely with each other seems very subject to abuse, and
> > multiple points of failure (where one node can compromise all of them).  
> > For such communication, globals are the best -- there has to be internal
> > filtering -- and gives no false sense of security which would rely on 
> > addressing.
> 
> Whether you firewall your inter-office traffic at the borders is an
> orthogonal issue, surely? In practice, since most hosts run the same
> software, if you own one you might as well own them all _directly_
> rather than via the one you owned. And since most people will log into
> the most important servers from their own workstations, if you trojan
> ssh you'll soon get there too... regardless of internal firewalling,
> which _can't_ block port 22.
>
> Besides, if they own one host, they can already use the internal IPv4
> network to attack the rest. That's not going to be taken down overnight.

It depends on your threat model.  As far as I've seen, there is a vast 
difference in access controls you enable internally and externally.  There 
are still internal access controls; the more the sites, the more the 
controls.

Which is why security by private addressing doesn't really fly.

> > Note that this is slightly different wrt. RFC1918 addresses.  Deploying
> > both globals and site-locals makes the problem of "compromise one node,
> > use it as a stepping stone to compromise all the local nodes" slightly
> > worse.
> 
> If there are no blocks in ingress to the global addresses. To be honest,
> I'd settle for putting the internal hosts behind NAT. We do not want
> ingress -- except by SSH only, via a limited set of trusted bastion
> hosts.

NAT doesn't help you at all here.  It just limits the ingress visibility
of your nodes.  The identical external protection can be obtained by
blocking *all* traffic at the border to those nodes you'd put behind the 
NAT.
 
> > Therefore, the use of "internal addresses" does not help with that except
> > for very small sites (e.g. home, using dial-up and getting a different
> > prefix every time, but the internal communication should stay stable), it
> > only propagates bad design from IPv4 to IPv6.
> 
> Its 'badness' is a matter of opinion. I think we can objectively say
> that it is a widely deployed and understood design, the absence of which
> causes significant conceptual barriers to those attempting to deploy
> IPv6.

I certainly disagree with "understood" here.

> RFC1918 may be a 'flawed' design to some people but it's almost
> universally understood and deployed. The abolition of site-local
> addresses is seems to be a huge barrier to adoption of IPv6. 

Again, I really disagree with "understood" here.  If folks really
understood it, it wouldn't be so widely deployed.  About the only more or
less valid use for addresses like those are in the disconnected sites
scenarios, or in cases where site prefix(es) keep changing all the time.  
And even then, there are severe disadvantages to using RFC1918 and NAT.

I'm not sure if anyone has ever bothered to write up these things,
especially for RFC1918, but at least one aspect of it (NAT) is at:

http://www.cs.utk.edu/~moore/what-nats-break.html

> I suppose we could work with the fc00::/7 non-routeable addresses, and
> NAT. Are people as opposed to IPv6-NAT as I was told they are? I'd
> discounted that as a solution before even starting...

Yep, people are pretty much against NATv6 :-)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
