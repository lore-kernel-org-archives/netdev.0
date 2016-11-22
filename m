From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: egress all frames
Date: Tue, 22 Nov 2016 16:03:30 +0100
Message-ID: <20161122150330.GE2691@lunn.ch>
References: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48475 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755461AbcKVPDd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 10:03:33 -0500
Content-Disposition: inline
In-Reply-To: <20161122103944.31381-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 11:39:44AM +0100, Stefan Eichenberger wrote:
> Egress multicast and egress unicast is only enabled for CPU/DSA ports
> but for switching operation it seems it should be enabled for all ports.
> Do I miss something here?
> 
> I did the following test:
> brctl addbr br0
> brctl addif br0 lan0
> brctl addif br0 lan1
> 
> In this scenario the unicast and multicast packets were not forwarded,
> therefore ARP requests were not resolved, and no connection could be
> established.

Hi Stefan

This is probably specific to the 6097 family. It works fine without
this on other devices. Creating a bridge like above and pinging across
it is one of my standard tests. But i only test modern devices like
the 6165, 6352, 6351, 6390 families.

In fact, you might need to review all the code and look where
mv88e6xxx_6095_family(chip) is used and consider if you need to add
mv88e6xxx_6097_family(chip). e.g.

        if (mv88e6xxx_6095_family(chip) || mv88e6xxx_6185_family(chip)) {
                /* Set the upstream port this port should use */
                reg |= dsa_upstream_port(ds);
                /* enable forwarding of unknown multicast addresses to
                 * the upstream port
                 */
                if (port == dsa_upstream_port(ds))
                        reg |= PORT_CONTROL_2_FORWARD_UNKNOWN;
        }

Maybe this is your problem?

	Andrew
