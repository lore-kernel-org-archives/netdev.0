From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 09 Mar 2005 09:18:10 -0500
Message-ID: <1110377889.1090.124.camel@jzny.localdomain>
References: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
	 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
	 <1110288879.1050.167.camel@jzny.localdomain>
	 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
	 <1110290300.1050.190.camel@jzny.localdomain>
	 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
	 <1110291470.1043.211.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
	 <1110316631.1084.57.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
	 <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Henrik Nordstrom <hno@marasystems.com>, Martin Mares <mj@ucw.cz>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-09 at 08:39, Zdenek Radouch wrote:
> At 07:39 AM 3/9/05 -0500, jamal wrote:

[..]
> Imagine a simple gateway, connecting two parts of your company
>  - the east
> interface connects to a corporate net with a default gateway, the west net
> is the software dept. net.  Now imagine that you give your internal line card
> in this simple gateway a "_whatever_" address, say 18.7.22.69.
> Your gateway now has a route 18.7.22.69/32 -> dev linecard
> Now please tell me what happens when a guy on the west net tries
> to check his MIT evening class schedule.

Are we still talking about the same problem? The linecards addresses and
interconnect interfaces are "internal". They are never advertised/seen
outside of the chasis. So if you choose 18.7.22.69/32 to use internally
you make sure it is never advertised to the outside world as belonging
to you. If you have to advertise it or actually know it is used, then
you must deal with the conflict.
Of course, there are "externally" visible addresses which are seen
outside the chasis; How you end up connecting internal 
inter-line card is your problem - lets say there are more than one ways
and infact you may never even need to use IP.

> >a) using private addresses implies possibility of conflict of addresses
> >within customer's  network. To quote Zdenek: 
> >You couldn't walk in the NOC and tell them: "You can't use the 10.x
> >net to manage your equipment - my box is already using that net".
> >Conclusion:
> >You walk into the NOC and say "can i use 10.0.0.x/22 subnet" they say "no
> >thats going to collide use 10.0.0.0/28"
> 
> In real world, where you pay for addresses and for people's time, no one
> will give you *their* address for *your* interconnect. Not a public address,
> and not a RFC1918 address.  Your interconnect is your problem,
> they are neither interested nor paid to deal with your design issues.
> 

I dont think i was saying anything different. 

> 
> >a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet"
> 
> I know I can use it.  I own it as per RFC 3330.
> 

RFC 3300 does not give you any rights to use it the way you are.

To quote RFC 3300:
--
A datagram sent by a higher level protocol to an
   address anywhere within this block should loop back inside the host.
---


> >So tell me what i am missing!
> 
> Experience of having built a router.  Sorry to be so blunt.
> 

Youd be the first person to ever accuse me of that.  Lets say
I have never needed this hack; the key is to be able to clearly
demarcate what are _internal and external interfaces as well as what are
internal and external IP addresses_. Yes, you can do it with Linux.
What you seem to be counting on is you being the only person ever
using the hack. In other words, survival via obscurity.
If the router upstream from you used the same hack you end up being in
trouble.

You seem to be getting angry, it may be time to end the discussion. 

cheers,
jamal

