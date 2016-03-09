From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 2/2] net: dsa: support
 SWITCHDEV_ATTR_ID_PORT_BRIDGE_IF
Date: Wed, 9 Mar 2016 21:07:43 +0100
Message-ID: <20160309200743.GB18196@lunn.ch>
References: <1457545368-20647-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457545368-20647-3-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160309183213.GA18196@lunn.ch>
 <87h9gfo3be.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	nikolay@cumulusnetworks.com, Elad Raz <eladr@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87h9gfo3be.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2016 at 02:32:05PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> -static bool dsa_slave_dev_check(struct net_device *dev)
> >> -{
> >> -	return dev->netdev_ops == &dsa_slave_netdev_ops;
> >> -}
> >
> > Where is the equivalent of this happening? Where do we check that the
> > interface added to the bridge is part of the switch?
> 
> Why should we check that? In this RFC, br_if.c tries to set the new
> attribute to the net_device, when creating and deleting the net bridge
> port. If it supports attr_set and this attribute, then we're good. Or am
> I missing something?

One of us is missing something...

What happens if i have two dsa clusters? We probably want to limit the
object to only being passed to the DSA cluster which contains the
port, or once we receive the object, we verify it belongs to the
cluster processing it.

What happens with a team/bind interface is added to the bridge. In the
future we need to know about this, so we can add the trunk in Marvells
terms to the bridge.

> > How about team/bonding? We are not ready to implement it yet with the
> > Marvell devices, but at some point we probably will. Won't we need the
> > events then? We need to know when a switch port has been added to a
> > team?
> >
> > Or do you think a switchdev object will be added for this case?
> > Mellanox already have the ability to add switch interfaces to a team,
> > and then add the team to a bridge. So we need to ensure your solution
> > works for such stacked systems.
> 
> Indeed these features can be propagated through new switchdev attributes
> or objects.
> 
> I think it'd be preferable to factorize the switch related operations
> into the switchdev API, instead of having every single switchdev user
> implement its custom (but similar) listeners and checks for global
> netdev events. What do you think?

Centralizing the code would be good. But DSA is way behind what
Mellanox can do, so you need to look at how your changes fit into
their driver.

During a netdev 1.1 BOF there was a conversation about the stack of
interfaces, teams/bonds, bridges, etc. If the video is available, you
might find it interesting.

      Andrew
