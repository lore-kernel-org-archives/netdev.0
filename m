From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 09 Mar 2005 07:39:22 -0500
Message-ID: <1110371962.1088.90.camel@jzny.localdomain>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
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
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
        Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
        Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
        Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Zdenek - This includes a response to your email as well.

On Wed, 2005-03-09 at 04:09, Henrik Nordstrom wrote:
> On Tue, 8 Mar 2005, jamal wrote:
> 
> > Henrik, so what is the difference between this and using any random
> > block of addresses?;-> If the packets never leave the box i can use
> > IBM's block of addresses if i wanted - no need to sweat this far (with
> > hacking the kernel).
> 
> Not if you want to maintain sane routing tables within the box and still 
> be able for IBM to connect the box to their network. Some components of 
> the box will need to sit both in the external and internal environments.
> 

For the record i have built or helped build many many such boxes... 

I am afraid this 127.x panacea is begining to sound like the tale of
some insane emperor who was naked but people around him sucking up to
him telling him how fine his clothes looked. I am having a very hard
time seeing the rationale - infact its driving me nuts, so please bear
with me.

Lets list the options and assume there are two sets of addresses those
for inside the chasis and those for outside:

1) Addresses for intra-chasis communication.
The addresses used by the blades are intrachasis relevant only and the
packets never leave the box. The blades are interconnected via some
L2/VLAN/bridge within the chasis. 

Conclusion:
If these packets never leave the box - no ARP will ever see them and no
dynamic routing protocol will ever advertise them - therefore no IP
address collision. You can use _whatever_ address you want, private
public, IBMs, intels etc. Do we agree on this? In other words hack not
needed here.

2) The addresses for chasis-outside world communication. You have one or
more dedicated gateways to connect between the outside of the chasis to
inside.
There are many tricks you could use to somehow get the packets to/from
the internal blades: NAT, forward, have aliases inside the chasis which
get forwarded etc. Lets not discuss about how the the packets finaly
make it outside, rather just assume these packets make it outside the
chasis then lets explore using either 127.x or RFC1918 addresses.

a) using private addresses implies possibility of conflict of addresses
within customer's  network. To quote Zdenek: 
You couldn't walk in the NOC and tell them: "You can't use the 10.x
net to manage your equipment - my box is already using that net".
Conclusion:
You walk into the NOC and say "can i use 10.0.0.x/22 subnet" they say "no
thats going to collide use 10.0.0.0/28"
Summary: You may need to go to your box and reconfigure its external looking
addresses.

a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet" 
they say either "sorry, our routers cant route 127.x" or "no Zdenek 
was here before you, thats going to collide use 127.0.0.0/28"

Same conclusion as 2a)

Do you see the problem? I dont see the difference between 2a) and 2a')
I also dont see the reason you need 127.x for 1) since you could have 
used any address for the intra-chasis (I have seen people use many differrent
addresses). 

So tell me what i am missing!

cheers,
jamal
