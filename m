From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: Tue, 2 Sep 2003 22:02:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309022202.52044.bdschuym@pandora.be>
References: <200308301504.03241.bdschuym@pandora.be> <200309021932.37224.bdschuym@pandora.be> <m3ptijt5ek.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3ptijt5ek.fsf@defiant.pm.waw.pl>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 02 September 2003 20:24, Krzysztof Halasa wrote:
> Actually I think non-VLAN15 traffic shouldn't make it to br0.15 in the
> first place, the same with physical ethernet and anything like that.

Obviously. The point is, vlan traffic with tag differing from 15 would be 
dropped if br0 were a physical device and not a logical bridge device.

> > The vlan code only sees tagged packets if the
> > packets are destined for the bridge box itself, so bridged traffic is
> > unaffected.
>
> Sure. Do you mean packets received from ethernet interface (br0 port)?
> They go to br0, of course. I don't see anything special here.
> I understand you don't need VLAN support for trunk bridging. You need
> it for locally accessing VLANs (trunk members) only.

Umm, I probably should stop wasting people's time.
Let me compare eth1.15 with br0.15, eth0 is a port of br0, eth1 is not, 
eth0.xx doesn't exist.

Vlan tagged packet arrives on eth1: the vlan code gets to deal with the packet 
thanks to dev_add_pack(&vlan_packet_type). If the vlan tag differs from 15, 
the packet is dropped. To outsiders, the indev is eth0.15.

Vlan tagged packet arrives on eth0: the bridge code gets to deal with the 
packet. So, to (most) outsiders the indev is br0. The bridge code happily 
forwards the packet, no matter what the vlan tag might be.
I would find it logical if the indev would be br0.15 for vlan traffic over a 
bridge br0 when br0.15 exists, and that only vlan15 traffic gets forwarded.
So, basically, I'd expect br0.15 to act like a bridge, since br0 is a bridge.

cheers,
Bart
