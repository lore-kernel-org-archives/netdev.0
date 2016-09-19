From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Requesting guidance on how to expose (new/exotic) PHY features
 to user-space
Date: Mon, 19 Sep 2016 16:20:58 +0200
Message-ID: <20160919142058.GC8651@lunn.ch>
References: <66E0C71AC771CF4297D4A99D55E55AB84EA675CA@avsrvexchmbx2.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: Allan Nielsen <Allan.Nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52129 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752303AbcISOVB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 10:21:01 -0400
Content-Disposition: inline
In-Reply-To: <66E0C71AC771CF4297D4A99D55E55AB84EA675CA@avsrvexchmbx2.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In the current SW model, most SW runs in user-space and is proprietary. But we
> are working more and more in the direction of Open Sourcing certain part of the
> SW, and the company is becoming more and more aware of the advantage of doing
> open-source SW and getting it accepted upstream. In recent events we have
> released the API (driver layer) for the user-space application under the MIT
> license (covering a large range of PHYs and Switches).

Great it is open source. However, as a general rule of thumb, user
space drivers will not be accepted. You need to push this into the
kernel. DSA or switchdev for the switches, and phylib for the PHYs.

> The project Raju is working on is about getting support for some of
> the PHYs accepted upstream.

Which is great, and we are here to help.
 
> But we also have a hand-full of features that is hard to fit in, and we are
> seeking some advice on how to handle those.

Good that you are asking. It should stop you going off in the wrong
direction. Often it is "show us the code", but if you have little
experience with the linux architecture and how things are doing,
getting guidance early will be useful.

> It typically boils down to finding a good way of exposing such a
> feature to a given user-space application.

We need to be precises here. You need to expose an API to control the
feature or report on the result. The driver code is in the kernel.

> A good example of this could be a feature that internally is being
> called VeriPHY. The idea of this is that the PHY can run some
> diagnostic and figure out if there is a damage to the cable, and it
> can estimate where the damage is.

O.K, nothing unique or exotic. Marvell and Intel PHYs also have these
sort of features, and i'm sure others do too. They have just not yet
been exposed in a sensible way.

> What is the preferred way of exposing such a feature??

You need to define an API for exposing the results of the cable test
to userspace. This API needs to work for all vendors. i.e, you
probably want to get hold of some Marvell and Intel datasheets, look
at the Marvell DSDT, the in kernel Intel code. Work out what is
similar and different. Look around at the current
infrastructure. Could ethtool --test be extended? Something similar
added but for the PHY level?

This is going to be made harder in that there is a call to stop adding
new features to ethtool. It should be re-written using netlink. So you
might want to follow that discussion, get involved in it, see if
others think netlink is the right way to go, and what will the
replacement for ethtool look like?

Just to repeat again, the cable test code itself goes in the kernel,
in the phy driver. The user space code should work for all PHY
vendors.

I've interest in seeing the Marvell PHYs support these features, so
you can expect me to implement the Marvell version.

This is another part of being in the community. You cannot focus
purely on your own chips, when it comes to features others have. You
need to work on the shared infrastructure. It can be hard for
Management to get this, if they are new to open source. Why should i
help my competitor by implementing something they can use. Yet it
probably was your competitors which implemented the basic PHY
infrastructure, and you are benefiting from that. So it is your turn
to help, for the benefit of all.

	   Andrew
