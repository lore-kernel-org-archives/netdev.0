From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix mdio bus name when using
 devicetree
Date: Mon, 1 May 2017 17:20:54 +0200
Message-ID: <20170501152054.GD1285@lunn.ch>
References: <20170501145404.18581-1-slemieux.tyco@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: Sylvain Lemieux <slemieux.tyco@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46791 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S940314AbdEAPkA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 11:40:00 -0400
Content-Disposition: inline
In-Reply-To: <20170501145404.18581-1-slemieux.tyco@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 10:54:04AM -0400, Sylvain Lemieux wrote:
> From: Liam Beguin <lbeguin@tycoint.com>
> 
> mv88e6xxx_mdio_register automatically generates mdio buses for each switch
> discovered in the devicetree. When switch nodes are embedded in other nodes,
> this can cause sysfs naming collisions since full_name may be truncated.
> 
> Only use devicetree node name instead of the full devicetree path
> as the mdio bus name.

Hi Sylvain

I'm not sure this is a good idea. It probably breaks my boards:

:/sys/class/mdio_bus# ls
!mdio-mux!mdio@1!switch@0!mdio	0.1  0.4  400d0000.ethernet-1  fixed-0
!mdio-mux!mdio@2!switch@0!mdio	0.2  0.8  400d1000.ethernet-2  mv88e6xxx-0

np->name is not unique, where as np->full_name is unique.

However, i can understand your problem with truncation. Maybe a better
solution is to detect if truncation is going to happen. If so, use a
concatenation of a hash of np->full_name, and the right hand part of
np->full_name?

	Andrew
