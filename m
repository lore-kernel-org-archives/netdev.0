From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/7] DSA refactoring: set 1
Date: Mon, 11 Apr 2016 23:16:46 -0400
Message-ID: <87k2k3ikip.fsf@ketchup.mtl.sfl>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54569 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbcDLDQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 23:16:55 -0400
In-Reply-To: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> There has been a long running effort to refractor DSA probing to make
> the switches true linux devices. Here are a small collection of
> patches moving in this direction. Most have been seen before.
>
> We take a little step forward by passing the dsa device point to the
> driver, thus allowing it to perform resource allocations using the
> normal mechanisms. This device structure will later be replaced by the
> devices own device structure.
>
> Future patches will add a true driver probe function, so we rename the
> current probe function, cleaning up the namespace.
>
> phys_port_mask continually confuses me, thinking it is about PHYs. But
> it is actually about ports to the outside world, user ports. So rename
> it.
>
> Lots more patches yet to follow, this is just doing some ground work.
>
> Andrew Lunn (7):
>   net: dsa: Pass the dsa device to the switch drivers
>   net: dsa: Have the switch driver allocate there own private memory
>   net: dsa: Remove allocation of driver private memory
>   net: dsa: Keep the mii bus and address in the private structure
>   net: dsa: Rename DSA probe function.
>   dsa: Rename phys_port_mask to user_port_mask
>   dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
>
>  drivers/net/dsa/bcm_sf2.c   | 24 +++++++++++++-------
>  drivers/net/dsa/mv88e6060.c | 47 +++++++++++++++++++++++---------------
>  drivers/net/dsa/mv88e6060.h | 11 +++++++++
>  drivers/net/dsa/mv88e6123.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6131.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6171.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6352.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6xxx.c | 55 +++++++++++++++++++++++++++++++--------------
>  drivers/net/dsa/mv88e6xxx.h | 17 +++++++++++---
>  include/net/dsa.h           | 16 ++++++++-----
>  net/dsa/dsa.c               | 19 +++++++++-------
>  11 files changed, 166 insertions(+), 79 deletions(-)

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
