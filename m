From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 00:26:15 +0200
Message-ID: <20160614222615.GK12832@lunn.ch>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <5760701F.6000204@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46305 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbcFNW0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 18:26:17 -0400
Content-Disposition: inline
In-Reply-To: <5760701F.6000204@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 	This was DT as well with a recent fedora/NetworkManager. It
> actually seems to be timing related to how fast the device gets
> configured after the initial phy probe. There is something like a 1
> second window or so where it will work, but if network manager takes
> longer than that, the link state drops and cannot be brought back up
> unless the cable is pulled, replugged while the netdevice is being
> restarted.

Ah!

There is another bug in the driver. The phy is connected to the netdev
after calling register_netdev(). You are supposed to do it before,
because the interface is usable, and can be used, directly after the
register.

Move the call to smsc911x_mii_init() before the register_netdev().

     Andrew
