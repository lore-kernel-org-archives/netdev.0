From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Tue, 22 Nov 2016 19:37:33 +0100
Message-ID: <20161122183732.GD13973@gruene.netmodule.intranet>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
 <20161122150330.GE2691@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stefan Eichenberger <eichest@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:39505 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754732AbcKVSwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 13:52:43 -0500
Content-Disposition: inline
In-Reply-To: <20161122150330.GE2691@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew

On Tue, Nov 22, 2016 at 04:03:30PM +0100, Andrew Lunn wrote:
> On Tue, Nov 22, 2016 at 11:39:44AM +0100, Stefan Eichenberger wrote:
> > Egress multicast and egress unicast is only enabled for CPU/DSA ports
> > but for switching operation it seems it should be enabled for all ports.
> > Do I miss something here?
> > 
> > I did the following test:
> > brctl addbr br0
> > brctl addif br0 lan0
> > brctl addif br0 lan1
> > 
> > In this scenario the unicast and multicast packets were not forwarded,
> > therefore ARP requests were not resolved, and no connection could be
> > established.
> 
> Hi Stefan
> 
> This is probably specific to the 6097 family. It works fine without
> this on other devices. Creating a bridge like above and pinging across
> it is one of my standard tests. But i only test modern devices like
> the 6165, 6352, 6351, 6390 families.

Okay perfect, I wasn't 100% sure if I would have to configure something
additionally.

> 
> In fact, you might need to review all the code and look where
> mv88e6xxx_6095_family(chip) is used and consider if you need to add
> mv88e6xxx_6097_family(chip). e.g.
> 
>         if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
>                 /* Set the upstream port this port should use */
>                 reg |= dsa_upstream_port(ds);
>                 /* enable forwarding of unknown multicast addresses to
>                  * the upstream port
>                  */
>                 if (port == dsa_upstream_port(ds))
>                         reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
>         }
> 
> Maybe this is your problem?

I think I still don't understand exactly how the driver works.

My problem is that the multicast and broadcast frames are filtered and
the following counter is increasing in ethtool:
sw_in_filtered: 596

This makes sense because "Egress Floods" in the Port Control Register is
set to 0. What kind of mechanism should make sure that for example ARP
packets are sent trough all ports anyway?

Unfortunately I don't have any devices available with more modern
devices, so I can't double check the registers.

Regards,
Stefan
