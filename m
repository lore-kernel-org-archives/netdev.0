From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it to
 another host
Date: Tue, 8 Mar 2005 11:57:34 +1030
Message-ID: <20050308115734.544fcaca.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20050306153108.20430b58.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<1110199198.1094.1282.camel@jzny.localdomain>
	<20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<20050307213211.GA25323@outpost.ds9a.nl>
	<1110238406.1043.57.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110238406.1043.57.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal, Bert,

On 07 Mar 2005 18:33:26 -0500
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2005-03-07 at 16:32, bert hubert wrote:
> > On Tue, Mar 08, 2005 at 12:26:43AM +1030, Mark Smith wrote:
> 
> I think i got it finally ..
> 
> > Indeed, we are in full agreement. The idea is to have the ability to fully
> > firewall and monitor a machine that absolutely needs to have a real
> > routable IP address, without wasting an IP address for the router (or trying
> > to get an ISP to assign you multiple addresses, which can be a major chore
> > these days).
> > 
> > I'd settle for a 'dirty' solution. Remco van Mook of Virtu.nl suggested
> > abusing iptables -j QUEUE combind with tun/tap to inject the packets on the
> > ethernet side, where userspace does the PPP -> ethernet conversion by making
> > up the required headers.
> >

A while back I was playing a bit with policy forwarding/routing,
specifically trying to get traffic for a local address to travel
"outside" the machine that it was assigned to, rather than short
circuiting internal to the host.

All I did was move the default rule for matching local addresses from
0 within the 64K priority list to the middle of it, ie 16383. This
allowed me to insert policy forwarding rules for local addresses before
the local address match. I was then able to push traffic for local
addresses out the ethernet interface. When it returned, I then had a
policy rule that matched incoming traffic against the local address
table.

It seems to me that the biggest issue with this "transparent firewall /
ppp proxy" scenario is getting the Linux box to ignore what thinks to be
is a local IP adress, and throw it at its forwarding table instead. What
I did allows this to be overridden using policy forwarding. I'm not sure
about how layer 3 firewalling would work, however I'd guess that since
the packet is being forwarded, it would be matched against any iptables
FORWARD rules.

I went into some detail as to how it worked and how I set it up in the
following post. :

http://oss.sgi.com/archives/netdev/2004-06/msg00536.html

Alexey gave some feedback suggesting that doing what I was doing would
cause some inconsistencies in other areas of the kernel networking stack
sadly. Maybe if there is a more common use for this sort of ability, eg
this scenario, worth putting the effort into "fixing" those other areas.
Unfortunately I don't know enough about kernel programming, and I'm a
bit rusty on C, such that I couldn't pursue these other areas myself.

Regards,
Mark.

-- 

    The Internet's nature is peer to peer.
