From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next] bridge: try switchdev op first in
 __vlan_vid_add/del
Date: Sat, 10 Oct 2015 12:03:54 -0400
Message-ID: <20151010160354.GB14572@ketchup>
References: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
 <20151009224405.GA25393@ketchup.mtl.sfl>
 <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54463 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbbJJQD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 12:03:57 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bB-X_GekWgRTcdOJGa+JTwaxtHmttsFz0f19ae-t+d-Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Friday 09 (41) 08:20 PM, Scott Feldman wrote:
> On Fri, Oct 9, 2015 at 3:44 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
> > Hi Jiri,
> >
> > On Oct. Friday 09 (41) 01:54 PM, Jiri Pirko wrote:
> >> From: Jiri Pirko <jiri@mellanox.com>
> >>
> >> Some drivers need to implement both switchdev vlan ops and
> >> vid_add/kill ndos. For that to work in bridge code, we need to try
> >> switchdev op first when adding/deleting vlan id.
> >
> > Just curious, when would a driver need to have both operations?
> 
> Ya, I was kind of curious of that myself. Is this because the driver
> wants to support standalone VLANs using 802.1q module and vconfig, as
> well as bridge vlans?  With the vlan support built into the bridge,
> I've been working under the assumption that 802.1q module (and
> vconfig) aren't needed, and vlans for a bridged and non-bridge port
> can be managed using the "bridge" iproute2 cmd.
> 
> > I kinda have the same question regarding ndo_fdb_{add,del} and the
> > bridge_{get,set}link equivalent, which is a bit confusing to me.
> 
> I had to look back at my commit 7f109539 to remind myself about the
> vid_add/kill ndos and bridge_{get,set}link usage.   Maybe that
> write-up helps?  I'm not following you on the ndo_fdb_add/del part of
> your question.

Sorry I wasn't clear. What is confusing to me for FDB ops is that we
define net_device_ops like:

        .ndo_fdb_add            = switchdev_port_fdb_add,                           
        .ndo_fdb_del            = switchdev_port_fdb_del,
        .ndo_fdb_dump           = switchdev_port_fdb_dump,

But if I'm not mistaken, "bridge fdb" commands use the
.ndo_bridge_{get,set,del}link ops, isn't it?

Thanks,
-v
