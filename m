From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Thu, 21 Oct 2004 11:01:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021090101.GD31265@xi.wantstofly.org>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net> <20041020223547.GJ29583@xi.wantstofly.org> <20041020155352.1c9b70f6.davem@davemloft.net> <20041020230405.GE995@wotan.suse.de> <20041020234423.GB31265@xi.wantstofly.org> <20041020164451.7746b595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020164451.7746b595.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 04:44:51PM -0700, David S. Miller wrote:

> > My application is a large-ish streaming video and file download service,
> > where I want to be able to automatically report on netblocks that are
> > seeing unusual packet loss, and then use that data to alert our NOC
> > and subsequently kick my transit providers with.
> 
> Isn't this what RSVP is for?  I realize that you may not be in
> a position to use RSVP end-to-end as necessary, but watching for
> retransmits by hand seems like simply a hackish way to do RSVP.

I'm approaching this from the other side.  There is no such thing as
an honest internet transit provider, and an often-seen trick is to
give ICMP packets a higher loss priority so that when you ping it all
looks okay even though say 0.5% of all non-ICMP traffic is actually
not making it to the other side because they're trying to stuff >10gbps
of traffic down a 10gbps pipe and don't want to invest more money in
their infrastructure to keep margins low.  They can then claim that
their 99.9% or 99.99% or 99.999% (depending on the crappiness level
of the provider) packet arrival guarantee is met because "ping from
my workstation doesn't show anything wrong" (actual words of someone
we've done business with.)

Regarding RSVP, at least in Europe people seem to prefer the
'lots of bandwidth'-approach.  In edge networks, people'd rather throw
an extra gig at the problem than to implement QoS.  And transit providers
will never implement it if it will allow people to find out that their
network really is underprovisioned.  I don't know of any provider that
uses or advertises QoS-related stuff such as RSVP.

RSVP is nice for stuff like research networks (Internet2, etc), but in
the actual internet you typically have to cross two or three other
providers to get to your destination and I really don't see each and
every one of those cooperating to provide RSVP end-to-end.  I don't see
end-to-end RSVP happening in the actual internet any time soon to be
honest.  If it ever will, I'm sure someone will find a way to make their
RSVP implementation lie to other providers about the true capacity of
their network (and then say "Sorry, we misconfigured it." if you find
out), at which point it becomes totally useless.


> Furthermore, non-timeout based retransmits are actually normal even
> on local subnets when a gigabit switch drops a packet to prevent
> internal deadlocks and stuff like that.  I've seen this quite a bit.

My crappy gigabit switch at home does this as well, but I've yet to
see this happen on the more 'serious' network gear.

A typical Amsterdam->LA single stream TCP test sees less than one in a
million lost packets over a good provider, and anywhere between ~100
and ~3000 per million over a crappy one.  The corresponding difference
in price is a factor of about 5-10.  (For example, $30-$40 per mbps per
month versus $5 assuming a reasonable traffic volume.)


--L
