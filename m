From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 09 Mar 2005 00:33:56 -0500
Message-ID: <3sp35g$850t0@smtp04.mrf.mail.rcn.net>
References: <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> <1110288879.1050.167.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: hadi@cyberus.ca
In-Reply-To: <1110288879.1050.167.camel@jzny.localdomain>
References: <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>
 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 08:34 AM 3/8/05 -0500, jamal wrote:
>PS:- anyone not copying me in the responses while addressing me - i
>didnt see your response.
>
>On Mon, 2005-03-07 at 22:15, Zdenek Radouch wrote:
>
>> RFC 1918 trivializes the IP addressing by boxing
>> all hosts into either a "private" or "public" category,
>> based on their need to access the Internet.
>> 
>
>sure. And the semantics are: dont route "private" addresses 
>if they stray on the "public network". In other words, it is left to the
>network setup to resolve this.
>
>> The major thing the RFC misses is the fact that internal
>> to one of these "public" or "private" hosts, you may have
>> another, "even more private" network, for example one
>> that connects the cards within the chassis.  
>
>But why is this more "even more private"?

Because the hosting device may be sitting on a "private" net,
with which you don't want to interfere.

>Surely you can use 10.x addresses just fine within a chasis.

Not if the admin's SNMP/CLI client machine  lives on a 10.x net.


>Nothing makes 127.x addresses not usable in NATs or not be routable
>once you start attching them to non-hostlocal interfaces. 

That's true (if I got the multiple negatives right ;-))
But what's the point you're trying to make?


>
>> Such network
>> must be (for obvious reasons) completely hidden
>> from the outside, and thus cannot come from the
>> "outside" address space.  This "outside" space is a union
>> of the "public" and "private" IP addresses.
>> Guess what's left?  How 'bout 127.0.0.0.
>> 
>
>Lets see, your requirements are:
>a) packets within a chasis subnet shall stay within a chasis subnet
>b) the outside (of the chasis) world shall never discover whats inside 
>the chasis (example ARPs will fail to resolve etc)
>
>Did i miss anything else?

Yes, a fundamental point.  The "outside" of the chassis is your
customer's network. The only thing you know about that
network is that it is *not* 127.x.  Consequently, if you don't
want to interfere with the outside you must use 127.x.

>
>Seems to me you are relying on obscurity of 127.x

As I said previously and shown above, 127 is the only one left,
it has not been randomly selected.


> to achieve goals which
>you could achieve just as easily with a 10.x address or even a public
>address. Is this correct?

No. 
 
> In otherwords it doesnt matter what addresses
>you use for internal chassis. What matters is how you set the route
>tables etc.
>I respect your desire to use whatever address range, but show me one
>think i couldnt do with a 10.x in the chasis that you can now achieve
>with a 127.x .. I think this will bring some clarity for me.
>

You couldn't walk in the NOC and tell them: "You can't use the 10.x
net to manage your equipment - my box is already using that net".

As a few people already pointed out, subnetting the 127 net
is a common practice if you are making multi-card communication
equipment, especially routers.  

Often, these systems must be able to communicate with the
external world, either as "public" hosts, or as "private", i.e.,
NAT'd hosts.  Because of this, the internal networks may not
ever have either public or RFC 1918 addresses.
For the same reason, the internal network cannot ever be
"configurable", since the configured address/net would
become inaccessible on the outside (it would be routed
to the internal network). Note that this has nothing to
do with the fact that the 127 address "never leaves the box".

Hope this clarifies the issue.

-Z
