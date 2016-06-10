From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Add VLAN support
Date: Fri, 10 Jun 2016 20:53:51 +0200
Message-ID: <20160610185351.GG2338@lunn.ch>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
 <1465519328-14249-5-git-send-email-f.fainelli@gmail.com>
 <20160610120046.GB2338@lunn.ch>
 <575B0B54.7030305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41793 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbcFJSxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 14:53:54 -0400
Content-Disposition: inline
In-Reply-To: <575B0B54.7030305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 11:47:48AM -0700, Florian Fainelli wrote:
> On 06/10/2016 05:00 AM, Andrew Lunn wrote:
> >> @@ -148,6 +155,9 @@ struct bcm_sf2_priv {
> >>  	struct device_node		*master_mii_dn;
> >>  	struct mii_bus			*slave_mii_bus;
> >>  	struct mii_bus			*master_mii_bus;
> >> +
> >> +	/* Cache of programmed VLANs */
> >> +	struct bcm_sf2_vlan		vlans[VLAN_N_VID];
> > 
> > Hi Florian
> > 
> > This is a 16Kbyte array. So i assume the whole priv structure needs 5
> > pages. Have you had any trouble allocating this much memory,
> > particularly once it has been used for a while and fragmented?
> 
> Well, since this is using the old binding, we can't unload the driver,
> it's built into the kernel, so initializes early enough we have got
> plenty of memory.

Don't you want to use the new binding at some point?

> > I just wondered if it might be better to use vmalloc() for the
> > vlans.
> 
> That's a very good point, I can't really see a drawback to doing this,
> will submit a patch moving this to a dynamic allocation.
> 
> Another possible approach would have been to allocate the vlan structure
> upong port_vlan_prepare() though that would typically result in more
> fragmentation over time once se start using more VLANs.

It is a trade off, code complexity vs saved memory. I don't think such
a table is too bad, assuming your not trying to run the whole system
in 32Mbyes of RAM.

   Andrew
