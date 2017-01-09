From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: Ensure validity of dst->ds[0]
Date: Mon, 9 Jan 2017 22:01:37 +0100
Message-ID: <20170109210137.GD13949@lunn.ch>
References: <20170109195834.11697-1-f.fainelli@gmail.com>
 <8737gsc5zm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53463 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932946AbdAIVBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 16:01:40 -0500
Content-Disposition: inline
In-Reply-To: <8737gsc5zm.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 03:50:53PM -0500, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
> > It is perfectly possible to have non zero indexed switches being present
> > in a DSA switch tree, in such a case, we will be deferencing a NULL
> > pointer while dsa_cpu_port_ethtool_{setup,restore}. Be more defensive
> > and ensure that dst->ds[0] is valid before doing anything with it.
> >
> > Fixes: 0c73c523cf73 ("net: dsa: Initialize CPU port ethtool ops per tree")
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> The patch is correct since we are already using dst->ds[0] here.
> 
> But we should stop using that and use dst->cpu_switch instead, because
> the switch with ID 0 won't necessary be the CPU switch. Now that the
> Ethernet switch chips are true Linux devices, they are registered in
> order depending on their bus/address. So in a setup like this:
> 
>        ,--MDIO--@4--------@2--
>       |         |         |
>     [CPU] <-> [swA] <-> [swB]

> 
> swB will have index 0 and swA will have index 1. Please correct me if
> I'm wrong.

Correct, which DS has the CPU port is arbitrary.

It also gets messier when Johns finishes reworking my PoC patchset for
multiple CPU ports. You ideally want the correct CPU port for this
host interface.

     Andrew
