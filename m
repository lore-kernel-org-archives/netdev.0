From: jamal <hadi@cyberus.ca>
Subject: Re: primary and secondary ip addresses
Date: 19 Dec 2004 15:18:37 -0500
Message-ID: <1103487517.1047.181.camel@jzny.localdomain>
References: <41912F7A.6000408@redhat.com>
	 <200412161153.51251.hasso@estpak.ee>
	 <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com>
	 <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu>
	 <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com>
	 <41C30212.6000906@cs.columbia.edu>
	 <20041217112025.27688eb6.davem@davemloft.net>
	 <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrea G Forte <andreaf@cs.columbia.edu>, hasso@estpak.ee,
	laforge@gnumonks.org, nhorman@redhat.com,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-17 at 14:48, Henrik Nordstrom wrote:
> On Fri, 17 Dec 2004, David S. Miller wrote:
> 
> > By definition, a secondary IP address on an interface is not to be used 
> > as a source.
> 
> But you can, but adding a route with such address as source or 
> applications excplicitly binding to this source address.

Even when not bound, a secondary address could be used as src if within
a fitting scope+mask.

>  And it is 
> highly useful to be able to use different source addresses in the same 
> subnet for different purposes.

You can.
You can also have multiple primary addresses each on different subnets
and scope. And each primary can have multiple secondary addresses.

> > It is the whole reason for the distinction between primary and secondary 
> > IP addresses, and it is why all secondaries are deleted once the primary 
> > is removed (because there are no valid source addresses to choose from 
> > any longer, therefore IP valid communications are no longer possible).
> 
> Which is a false assumption in very many situations.

The operative term is "IP valid communications are no longer possible".
When you attach an IP address for the first time on a port/interface
thats a signal "IP communication using this device is now Valid".
Its like ifconfiging up a device - but only for IP processing purposes. 
When you delete that IP address that created that signal i.e the primary
address/first address attached, you are signaling "IP communication
using this device is now no longer Valid". Thats why those secondary
addresses are deleted. Someone please take note of this somewhere in
some FAQ since it has been an issue of contention for a long time. A
routing protocol implementation
MUST take the above into consideration.

Having said the above, I think it would make sense to have a "promotion"
scheme so that in the case a primary address is deleted, one could
promote the next secondary address in line. But that should be optional.
Now where is the fireman who wants to do this? I could help cheering
since i know the code.

cheers,
jamal






