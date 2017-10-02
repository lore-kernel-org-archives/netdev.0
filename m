From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 0/5] net: dsa: LAG support
Date: Mon, 2 Oct 2017 16:05:56 +0300
Message-ID: <20171002130556.GA20151@shredder.mtl.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
 <20171002065023.GA11832@shredder.mtl.com>
 <20171002125932.GB4765@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        idosch@mellanox.com, Woojung.Huh@microchip.com, john@phrozen.org,
        sean.wang@mediatek.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40851 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751255AbdJBNF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 09:05:58 -0400
Content-Disposition: inline
In-Reply-To: <20171002125932.GB4765@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Mon, Oct 02, 2017 at 02:59:32PM +0200, Andrew Lunn wrote:
> > > - not sure what to do with a switch fabric, naively, if adding two ports
> > >   of two distinct switches as a LAG group, we may have to propagate that
> > >   to "dsa" cross-chip interfaces as well
> > 
> > At least in mlxsw case, enslaving switch and non-switch ports to the
> > same LAG doesn't make sense. Any traffic routed by the switch will only
> > be load-balanced between the switch ports. One way to solve that is to
> > forbid such enslavements during NETDEV_PRECHANGEUPPER in case the lower
> > devices in the adjacency list of the LAG don't belong to the same
> > switch.
> > 
> > Note that such configurations are bound to fail anyway, as the
> > non-switch ports will not have `switchdev_ops` configured and thus fail
> > during __switchdev_port_obj_add() / __switchdev_port_attr_set().
> 
> Hi Ido
> 
> Here Florian is thinking about the D in DSA. Marvell switches have the
> capabilities of building a switch fabric out of multiple
> interconnected switches. To switchdev, they appear as a single switch.
> switchdev has no idea of the mapping of interfaces to switches, nor
> the routing of frames between switches. This all happens in the layers
> bellow. The hardware does support LAG members on different switches
> within the same fabric. But it requires some additional setup for the
> ports which link switches together. We have the same issues with MDB,
> where additional setup is required for group members spread over the
> switch fabric.

Yes, I understood that. I was simply referring to the more general
problem of any two net devices and how to solve it. Not currently
implemented in mlxsw, but should be necessary for DSA as well.

Agree with your previous mail about keeping it simple for the first
implementation.
