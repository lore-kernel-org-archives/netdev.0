From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Thu, 24 Dec 2015 13:58:12 +0100
Message-ID: <20151224125812.GB29139@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com>
 <20151223223303.GD25485@lunn.ch>
 <567B2A89.7000803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49348 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbbLXM6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2015 07:58:16 -0500
Content-Disposition: inline
In-Reply-To: <567B2A89.7000803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I do not think you need the platform device because ultimately what the
> DSA platform device does is bind some data to the master network device
> the DSA switch tree is hanging off. Sure you need some piece of code
> that is resident in kernel or module space to be able to parse and
> allocate that data structure and bind multiple switch drivers together,
> but that could be a consequence of probing switch driver using their bus
> probe function.
> 
> The way I would imagine this in a cluster configuration is that you
> probe switches in the order in which they should appear in the final
> switch tree (if this order cannot be guaranteed, then defer until it
> is), and as you parse Device Tree for these switches you allocate their
> resources and update the dsa_switch_tree structure "live".

How do you get this ordering? You cannot control the probe order in
Linux.

> If we are using Device Tree this is relatively easy since we can lookup
> the entire Device Tree to know the switch tree topology whenever we
> probe a switch device driver. If we are using platform data, then, we
> should have a way to associate a given MDIO bus address with
> supplementary information, very much like what this patch does:

One of my aims is to abstract away the MDIO bus from DSA. How you talk
to the switch is a switch device property. SF2 has a different way to
talk to the switch, memory mapped IO, etc.

Anyway, who do you think the device tree binding will look? Maybe take
the .dts file in patches 2 and 20 to build an example?

	Andrew
