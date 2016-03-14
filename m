From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Mon, 14 Mar 2016 21:51:36 +0100
Message-ID: <20160314205136.GA4964@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <56D88757.7050803@gmail.com>
 <20160303202716.GQ15541@lunn.ch>
 <56E357C7.7090309@gmail.com>
 <20160312170827.GA2186@lunn.ch>
 <56E712B2.9010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47511 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbcCNUvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 16:51:38 -0400
Content-Disposition: inline
In-Reply-To: <56E712B2.9010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 12:36:18PM -0700, Florian Fainelli wrote:
> On 12/03/16 09:08, Andrew Lunn wrote:
> >> [snip]
> >>
> >>>
> >>> The third switch is as you would expect, dsa,member = <0 2>;
> >>
> >> I like that representation.
> >>
> > 
> > ...
> > 
> >> So does that mean you agree we do not need the DSA platform device
> >> anymore :)?
> > 
> > It looks like it can be	done without the DSA platform device.
> > 
> > My previous approach was to keep the new binding as similar as
> > possible to the current one. If however, we decide we are going for
> > something totally new, we can remove this platform device.
> 
> The old binding can and should remain available

Agreed. "marvell,dsa" will remain and will invoke a platform device,
as is today. That is the old binding.

I'm currently thinking that switch drivers will probe, and then call
something like

int dsa_switch_register(struct dsa_switch *ds, struct device_node *np);

The code behind that will be responsible for allocating the dst,
parsing the binding pointed to by np. It will also evaluate if all the
dsa links are available, and if so, call the setup() method in
ds->drv, etc.

> The new binding looks very similar to the previous one and this is
> certainly a good thing to do. With that in mind the new binding should
> probably be keeping the per-port Device Tree node representation and
> properties, because that one seems correct.

There are some changes. A cpu node will have the phandle to the
ethernet device. I really would like to only have a phandle to a phy,
but we will see, and i want to remove the limit of one cpu node. The
driver can then return -EINVAL during setup() if it cannot handle it.

> the parts that had gone
> wrong were definitively the "reg" property and the dsa,mii-bus property
> if not the dsa,ethernet as well, but code will talk.

reg at the switch level. Yes. We still need reg at the port level.
dsa,mii-bus is gone, and dsa,ethernet moved into the cpu port.

	    Andrew
