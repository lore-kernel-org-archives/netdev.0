From: jamal <hadi@cyberus.ca>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
	in case forwarded frame has VLAN-header]
Date: 08 Mar 2005 08:13:47 -0500
Message-ID: <1110287626.1043.146.camel@jzny.localdomain>
References: <20050305141225.GA5180@xi.wantstofly.org>
	 <4229D98F.9010008@trash.net> <422A0C21.3050709@candelatech.com>
	 <1110199696.1094.1299.camel@jzny.localdomain>
	 <Pine.LNX.4.62.0503072034340.5934@kaber.coreworks.de>
	 <1110238537.1043.62.camel@jzny.localdomain>  <422CE983.7060305@trash.net>
	 <1110241190.1043.100.camel@jzny.localdomain>  <422D1E26.1010902@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, leo@yuriev.ru,
        Lennert Buytenhek <buytenh@wantstofly.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422D1E26.1010902@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-07 at 22:38, Patrick McHardy wrote:
> jamal wrote:
> > Indeed that looks bad. But wouldnt have helped if we started at 0
> > either. You need monotonically increasing values to make proper
> > sense. So i suppose to do proper qos with L2, one must install the prio
> > qdisc and rewrite the priomap.
> 
> One reason more to move it to an optional ebtables target. Or leave it
> all to prio + u32. But I guess a CLASSIFY target similar to iptables
> could also be useful otherwise.

I think you still want (perhaps the vlan) driver to come up with some
sane defaults. From what i read from bgrear he has arbitrary values.

The only problem is we get conflicting goals with skb->priority between
IEEE/IETF so you cant have them both interworking; 
I dont know what CLASSIFY target but a meta action on ingress of a
device would easily set the skb->priority as well. So yes, if you want
to have both L2 and L3, you will need something that overwrites the
priority according to whatever the map is for one of them. Like i said
earlier though you need to have some sane value being set in the vlan
driver.

> Are there any changes required besides ip_tos2prio ? 

Theres also the user space->kernel setsockopt semantics; Unfortunately
just ridding of this is like killing an ABI interface, so it is
untouchable. However, it may be time to introudce a new setsockopt to
enable DSCP setting. 
ip_tos2prio is becoming less important if we are killing TOS routing
(which Dave may have done a while back - i have to look); however, we
can probably have a ip_dscp2prio or  ip_prec2prio map. 

> More importantly,
> it there a different meaningful mapping to priorities we can apply ?

Well, old 4 bit TOS is really obsoleted - Look at RFC 2474. 

Two schools of thoughts exist on mappings - we oughta support both.
One is the app controls these settings (MS is big on this approach).
The other is network providers control the network and dont give a squat
about what you set you values to be - we do that for example in qdiscs.
I would say the second is more prelevant.

cheers,
jamal
