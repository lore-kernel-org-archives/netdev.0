From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 09 Mar 2005 08:39:10 -0500
Message-ID: <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net>
References: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>
 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
 <1110290300.1050.190.camel@jzny.localdomain>
 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
 <1110291470.1043.211.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
 <1110316631.1084.57.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com> <1110371962.1088.90.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Martin Mares <mj@ucw.cz>, Eran Mann <emann@mrv.com>,
	Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: hadi@cyberus.ca, Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <1110371962.1088.90.camel@jzny.localdomain>
References: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>
 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
 <1110290300.1050.190.camel@jzny.localdomain>
 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
 <1110291470.1043.211.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
 <1110316631.1084.57.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 07:39 AM 3/9/05 -0500, jamal wrote:
>...
>Lets list the options and assume there are two sets of addresses those
>for inside the chasis and those for outside:
>
>1) Addresses for intra-chasis communication.
>The addresses used by the blades are intrachasis relevant only and the
>packets never leave the box. The blades are interconnected via some
>L2/VLAN/bridge within the chasis. 
>
>Conclusion:
>If these packets never leave the box - no ARP will ever see them and no
>dynamic routing protocol will ever advertise them - therefore no IP
>address collision. You can use _whatever_ address you want, private
>public, IBMs, intels etc. Do we agree on this? In other words hack not
>needed here.

No, I do not agree - you really need to re-read my last post carefully,
making sure you understand what I am saying.  Other people have
illustrated the problem as well.

Imagine a simple gateway, connecting two parts of your company - the east
interface connects to a corporate net with a default gateway, the west net
is the software dept. net.  Now imagine that you give your internal line card
in this simple gateway a "_whatever_" address, say 18.7.22.69.
Your gateway now has a route 18.7.22.69/32 -> dev linecard
Now please tell me what happens when a guy on the west net tries
to check his MIT evening class schedule.


>a) using private addresses implies possibility of conflict of addresses
>within customer's  network. To quote Zdenek: 
>You couldn't walk in the NOC and tell them: "You can't use the 10.x
>net to manage your equipment - my box is already using that net".
>Conclusion:
>You walk into the NOC and say "can i use 10.0.0.x/22 subnet" they say "no
>thats going to collide use 10.0.0.0/28"

In real world, where you pay for addresses and for people's time, no one
will give you *their* address for *your* interconnect. Not a public address,
and not a RFC1918 address.  Your interconnect is your problem,
they are neither interested nor paid to deal with your design issues.


>a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet"

I know I can use it.  I own it as per RFC 3330.

>So tell me what i am missing!

Experience of having built a router.  Sorry to be so blunt.


-Zdenek
