From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 09 Feb 2004 17:50:38 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076367038.1037.15.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	 <1076338874.1026.36.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-02-09 at 17:23, Julian Anastasov wrote:
> 	Hello,
> 
> On Mon, 9 Feb 2004, jamal wrote:
> 
> > It should probably be a sysctl example proxy_arp_validate_neigh.
> > I am happy with the way it is right now in the situation i use it in.
> 
> 	I assume you need to probe with ARP request whether for some
> IP we have:
> 
> - proxy entry
> 
> or
> 
> - we can respond for this target IP due to indev/proxy_arp set to 1
> 
> 	Then where is better such flag to exist, for indev or
> for outdev?

parse error. Are you agreeing it should be a sysctl?
what i meant was i am happy with the slight delay in some cases i get
now; example host we are parping for sends a unicast probe - we would
immediately respond. Host sends a resolved IP packet - we attempt to
route and worst case we find that we dont have the target entry in our
cache; we arp at that point.
In your case, you will amortize that cost at arp time. In the case of
unicast probes (assuming a sane arp implementation on the other side)
you will actually be adding cost since mostly that entry will be in the
cache.
In the case of broadcasts you could achieve the same effect by setting
the proxy_delay in /proc to zero.

> > Could the neighbor be removed while we have the packet in the proxy
> > queue?
> > It doesnt seem like theres any harm done in redoing the neigh_event_ns
> > twice.
> 
> 	You are right, if proxy_delay is large the requestor can
> disappear from our cache but it is not fatal for us to send reply,
> we do not need cache entry for this. I'm not sure what is better, is
> it right to confirm the requestor without receiving recent event
> from it? If will be visible for too large proxy_delay values.

I guess you could look at one view as possibly doing 2 neigh_event_ns()
and correct whereas the other is doing 1 but with the above side effect.

cheers,
jamal
