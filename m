From: Eran Mann <emann@mrv.com>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge
 device
Date: Wed, 03 Sep 2003 01:05:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F552256.7000008@mrv.com>
References: <200308301504.03241.bdschuym@pandora.be> <20030830203043.0eb1a660.davem@redhat.com> <20030902082807.0e18fe76.shemminger@osdl.org> <200309021932.37224.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: emann@opticalaccess.com
In-Reply-To: <200309021932.37224.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer wrote:

> 
> OK. But isn't br0.15 supposed to work like this: all vlan tagged traffic with 
> tag different from 15 is discarded, all non-tagged traffic is given to br0. 
> This is how it works with a vlan on top of physical devices like eth0 if I 
> read the code correctly, but it doesn't currently work like that for vlan on 
> top of a logical bridge device. The vlan code only sees tagged packets if the 
> packets are destined for the bridge box itself, so bridged traffic is 
> unaffected.
> This is why I think a vlan device on top of br0 in Linux is currently useless.
> 
> cheers,
> Bart
> 
Actually this behavior (bridge all VLANs for non-local traffic, allow 
incoming traffic only from configured VLANs) is exactly what you 
typicaly want in a bridged VLAN-aware LAN. Assume for instance that an 
enterprise has N departments and a VLAN (or a few) for each dept. You 
want only guys from the MIS or IT department to be able to manage the 
bridges, not all the departments. being able to configure br0.x in such 
a setup would save you a lot of configuration. Otherwise you'd have to
- configure all the N VLANs on all the physical ports.
- define ebtable rules on each non MIS VLAN, on each physical port, to 
block access to the bridge management.
- define bridging between all the devices.

Also if you want to run spanning-tree than you have a slight problem, 
since the STP code is not VLAN aware, and would send BPDUs on the VLAN 
devices as if they were normal ports, so you need to setup a br

Regards,
	Eran.
