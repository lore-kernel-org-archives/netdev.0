From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: 02 Sep 2003 23:43:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m38yp6uar3.fsf@defiant.pm.waw.pl>
References: <200308301504.03241.bdschuym@pandora.be>
	<200309021932.37224.bdschuym@pandora.be>
	<m3ptijt5ek.fsf@defiant.pm.waw.pl>
	<200309022202.52044.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309022202.52044.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer <bdschuym@pandora.be> writes:

> Let me compare eth1.15 with br0.15, eth0 is a port of br0, eth1 is not, 
> eth0.xx doesn't exist.
> 
> Vlan tagged packet arrives on eth1: the vlan code gets to deal with the
> packet 
> thanks to dev_add_pack(&vlan_packet_type). If the vlan tag differs from 15, 
> the packet is dropped. To outsiders, the indev is eth0.15.

Right.
 
> Vlan tagged packet arrives on eth0: the bridge code gets to deal with the 
> packet. So, to (most) outsiders the indev is br0. The bridge code happily 
> forwards the packet, no matter what the vlan tag might be.

Right. The bridge just bridges the packet based on dest MAC.

> I would find it logical if the indev would be br0.15 for vlan traffic over a 
> bridge br0 when br0.15 exists, and that only vlan15 traffic gets forwarded.
> So, basically, I'd expect br0.15 to act like a bridge, since br0 is a bridge.

I would rather expect that br0 bridges all ethernet frames. br0.15 should
behave like a "static VLAN" port on VLAN-aware switch. This is basically
what VLAN-aware switches do with trunk and single VLAN ports (let alone
VLAN filtering which isn't implemented here).

If you have just one trunk port, don't add it (eth0) to the bridge.
Add eth0.15 to the bridge instead.
-- 
Krzysztof Halasa, B*FH
