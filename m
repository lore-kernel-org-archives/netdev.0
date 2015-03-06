From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] mv88e6131: bonding: implement single device
 trunking
Date: Fri, 6 Mar 2015 22:47:23 +0100
Message-ID: <20150306214723.GB582@lunn.ch>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
 <1424429473-4601-3-git-send-email-jonasj76@gmail.com>
 <20150220152644.GD13797@lunn.ch>
 <54F9DEAA.50606@gmail.com>
 <20150306192359.GA582@lunn.ch>
 <54FA125E.6050605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54666 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754469AbbCFVui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 16:50:38 -0500
Content-Disposition: inline
In-Reply-To: <54FA125E.6050605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

> Most Broadcom switches, either SF2 or roboswitch (b53) have a limit of 2
> trunking groups, without limitations on the number of ports included in
> any of these two groups.

O.K, so maybe we want the basic resource management in the DSA layer,
not the switch drivers.
 
> The larger question is once we start advertising capabilities, where
> does that stop, right? It would probably be simpler for now to e.g:
> allow 2 trunking groups to be configured, and when trying to configure a
> 3rd one, return -ENOSPC and act upon that to either take the software
> slow path (which is probably not possible) or just return a hard error
> condition.

This is more than a DSA question. It applies to all the hardware
acceleration being discussed at the moment. As you hinted to above, i
suppose we have two different situations:

1) We can fall back to a software slow path.

2) There is no software fallback, we have to error out, and it would
   be nice to have a well defined error code for out of hardware
   resources.

We also should think about how we tell user space we have fallen back
to a slow path. I'm sure users want to know why it works, but works
much slower.

     Andrew
