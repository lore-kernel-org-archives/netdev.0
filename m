From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 23:34:43 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0503091730280.16557@filer.marasystems.com>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>  <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>  <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>  <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>  <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
  <1110290300.1050.190.camel@jzny.localdomain>  <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
  <1110291470.1043.211.camel@jzny.localdomain>
 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
 <1110316631.1084.57.camel@jzny.localdomain>  <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com>
 <1110371962.1088.90.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
        Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
        Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
        Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1110371962.1088.90.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2005, jamal wrote:

> I am afraid this 127.x panacea is begining to sound like the tale of
> some insane emperor who was naked but people around him sucking up to
> him telling him how fine his clothes looked. I am having a very hard
> time seeing the rationale - infact its driving me nuts, so please bear
> with me.

yes, if it wasn't for routing conflicts when a node is in both the 
external and the chassis network.

If Linux could manage different IP stacks per interface this would not be 
a problem, but as it is today the same IP stack is used for all interfaces 
making dual homing (not routing) a bit troublesome when the same addresses 
may be in both networks..

> within customer's  network. To quote Zdenek:
> You couldn't walk in the NOC and tell them: "You can't use the 10.x
> net to manage your equipment - my box is already using that net".
> Conclusion:
> You walk into the NOC and say "can i use 10.0.0.x/22 subnet" they say "no
> thats going to collide use 10.0.0.0/28"
> Summary: You may need to go to your box and reconfigure its external looking
> addresses.

Yes.

But also it's internal in order to maintain any sanity in the nodes 
connected to both worlds.

> a') Using 127.x addresses. You -> NOC "can i use 127.0.0.x/22 subnet"
> they say either "sorry, our routers cant route 127.x" or "no Zdenek
> was here before you, thats going to collide use 127.0.0.0/28"

This has never been a topic. The use of the 127.X addresses is purely for 
inter-chassis communication, never visible outside of the chassis.

By using the 127.X addresses for intra-chassis communication you are 
guaranteed that there is never conflicts with addresses used on the LAN, 
and the routing tables of the chassis nodes which needs to speak to both 
worlds can be maintained sane without requiring configuration of the 
chassis-internal network not even visible to the administrator.


The available choices are in reality (not exlusive, pick any number)

a) Ask IANA for an address block for intra-chassis communication and hope 
the local LAN is not abusing these addresses.

b) use the IPv4 link-local address block already registered, with the 
condition that this is not used on the local LAN to avoid collisions.

c) Use 127.X. Ensures that no matter what the local LAN looks like 
behaviour of the externally connected nodes will be what is expected (can 
handle any valid IP, except for 127.X which they are not expected to 
handle)

d) Use a configureable address block.

e) Reimplement the IP stack in Linux to have separate IP stacks per 
interface, and modify all applications to not only specify the destination 
IP but also which interface to use when talking to either the internal 
network or external world.

f) Not use IPv4 for the intra-chassis communication.

Regards
Henrik
