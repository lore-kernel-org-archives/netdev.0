From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Fri, 6 Mar 2015 20:23:59 +0100
Message-ID: <20150306192359.GA582@lunn.ch>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
 <1424429473-4601-3-git-send-email-jonasj76@gmail.com>
 <20150220152644.GD13797@lunn.ch>
 <54F9DEAA.50606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54578 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684AbbCFT1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 14:27:15 -0500
Content-Disposition: inline
In-Reply-To: <54F9DEAA.50606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 06, 2015 at 09:06:50AM -0800, Florian Fainelli wrote:
> On 20/02/15 07:26, Andrew Lunn wrote:
> > On Fri, Feb 20, 2015 at 11:51:13AM +0100, Jonas Johansson wrote:
> > 
> > Please could you look at all your functions and see what is specific
> > to the 6131 and what is generic. Place the generic code into mv88e6xxx
> > please so we can all use it.
> 
> Out of curiosity, how many bonding/trunking groups are supported on the
> switches models currently in tree?
> 
> Let's say there is a limitation: like no more than 2 different bonding
> groups on a given physical switch, where would we put this limitation,
> down to the switch driver?

Hi Florian

It is limited, but it seems to be quite a high limit. I don't have
exact numbers for the devices currently in tree, but i've used an 10
port switch which had a limit something like 8 trunk groups, and a
maximum of 8 ports per trunk.

I suspect we would put the resource tracking in the shared mv88e6xxx
code, and configure it with the limitations from the specific chip
driver.

However, does SF2 have similar trunking capabilities, and limits? Does
it make sense to have this at a higher level so it can be used by all
drivers?

	Andrew
