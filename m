From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 08 Mar 2005 08:34:39 -0500
Message-ID: <1110288879.1050.167.camel@jzny.localdomain>
References: <422C0B50.20500@mrv.com> <m1y8d0mss2.fsf@muc.de>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
	 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, Martin Mares <mj@ucw.cz>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PS:- anyone not copying me in the responses while addressing me - i
didnt see your response.

On Mon, 2005-03-07 at 22:15, Zdenek Radouch wrote:

> RFC 1918 trivializes the IP addressing by boxing
> all hosts into either a "private" or "public" category,
> based on their need to access the Internet.
> 

sure. And the semantics are: dont route "private" addresses 
if they stray on the "public network". In other words, it is left to the
network setup to resolve this.

> The major thing the RFC misses is the fact that internal
> to one of these "public" or "private" hosts, you may have
> another, "even more private" network, for example one
> that connects the cards within the chassis.  

But why is this more "even more private"?
Surely you can use 10.x addresses just fine within a chasis.
Just make sure the packets dont leak out (if thats what you so desire).
i.e set your routing properly.
Nothing makes 127.x addresses not usable in NATs or not be routable
once you start attching them to non-hostlocal interfaces. 

> Such network
> must be (for obvious reasons) completely hidden
> from the outside, and thus cannot come from the
> "outside" address space.  This "outside" space is a union
> of the "public" and "private" IP addresses.
> Guess what's left?  How 'bout 127.0.0.0.
> 

Lets see, your requirements are:
a) packets within a chasis subnet shall stay within a chasis subnet
b) the outside (of the chasis) world shall never discover whats inside 
the chasis (example ARPs will fail to resolve etc)

Did i miss anything else?

Seems to me you are relying on obscurity of 127.x to achieve goals which
you could achieve just as easily with a 10.x address or even a public
address. Is this correct? In otherwords it doesnt matter what addresses
you use for internal chassis. What matters is how you set the route
tables etc.
I respect your desire to use whatever address range, but show me one
think i couldnt do with a 10.x in the chasis that you can now achieve
with a 127.x .. I think this will bring some clarity for me.


cheers,
jamal

