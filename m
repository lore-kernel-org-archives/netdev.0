From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 09:33:52 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFE21C@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Henrik Nordstrom" <hno@marasystems.com>, "Martin Mares" <mj@ucw.cz>,
        "Zdenek Radouch" <zdenek@rcn.com>, "Eran Mann" <emann@mrv.com>,
        "Thomas Graf" <tgraf@suug.ch>, "Andi Kleen" <ak@muc.de>,
        <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


-> Your blades --> VLANX/SubnetX
->      --> [some L3 switch]

umm.. I have a L2 switch... not L3 switch.


-> Read what i wrote again and cross reference with the diagram. ARP is
-> only L2 switched. It would be wise to configure the blade IP
addresses
-> to be within the same subnet - in which case the only route you need
on
-> your blades is a link scope one and perhaps a default GW pointing to
-> your L3 device.
-> 

L2 device.

> 
-> Its just a matter of time before you say "oh, thats what i do now for
-> 127.x". This is the point i have been trying to make all along.
-> 
-> > -> So tell me what i am missing!
-> > ->
-> >
-> > Experience.
-> 
-> I think you are making some very big assumption ;-> Please dont go
this
-> path unless you wish to end this thread.
-> 

Ok.  I won't.


-> Btw, i do believe what you and Zdenek are trying to solve are _very_
-> different problems. He is trying to build a distributed router of
some
-> form; i.e his blades are infact line-cards where traffic comes in.
-> You on the other hand seem to have the blades doing computes (i.e
they
-> are not router line cards).

Nope.  I'm in a very similar situation.  I don't have "line-cards"
per-se.  Not like xDSL or the type of line cards I've worked on in the
past, but my boards **DO** have both mgmt traffic and network traffic
coming into them.  
I have signaling traffic, bearer traffic and network mgmt traffic.

Very much the same.  I have basically 5 VLANS setup.  4 of which get
tagged at the switch so that when the packets come inside the chassis, I
know how to handle them.  1 of the VLANS is for mgmt communication.
Like I said, it works great.  The 127.xx net I will NEVER need to talk
to outside of my chassis and when I do chassis to chassis redundancy I
use a different scheme.

So I will never run into the "gee, someone else is using the 127.xx net"
because as long as my applications know how to get to the 127.xx net the
traffic will be sent to the proper ports and get tagged with the proper
vlan ID.


I wish my setup was easy enough to just draw a quick picture.  But it
aint, sorry.


-> 
-> The point is this: Whatever you folks are doing, probably inherited
from
-> some other projects more than likely using some other OS is not
-> necessary in Linux. I respect your desire to use those addresses if
it
-> makes you comfortable - I just vehemently disagree it is needed.


Nope.  Wrote the project from scratch using Embedded Linux.

Again, if you can show me a way of doing this, I'm all ears, but so far,
you haven't shown me any other way around it.  Believe me.  I've tried
and tried to find another solution to this problem.  

And I can't emphasis enough that telling a customer, "Pick a network
address range that I can use" is NOT, I have to repeat, NOT a solution.
The will NEVER NEVER NEVER go for it.  Maybe your customers will but
mine wont.  My customers are RBOCs and the like.  Anyone dealing with
them knows what I am talking about.


-> So i hope you dont show up with the patch and ask for its inclusion.
-> 

Nope.  Never will.  I don't think the big boys (Alan Cox, Linus and the
like) would never let it happen because there is no RFC on it.  There
will be someday.  I do know that there are ideas floating around right
now that will soon become the beginnings of the RFC.  

-> cheers,
-> jamal
