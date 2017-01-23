From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Check return value of
 phy_connect_direct()
Date: Mon, 23 Jan 2017 15:43:49 -0500 (EST)
Message-ID: <20170123.154349.1850757123800068825.davem@davemloft.net>
References: <20170121000505.15135-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWUnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 15:43:51 -0500
In-Reply-To: <20170121000505.15135-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Jan 2017 16:05:05 -0800

> We need to check the return value of phy_connect_direct() in
> dsa_slave_phy_connect() otherwise we may be continuing the
> initialization of a slave network device with a PHY that already
> attached somewhere else and which will soon be in error because the PHY
> device is in error.
> 
> The conditions for such an error to occur are that we have a port of our
> switch that is not disabled, and has the same port number as a PHY
> address (say both 5) that can be probed using the DSA slave MII bus. We
> end-up having this slave network device find a PHY at the same address
> as our port number, and we try to attach to it.
> 
> A slave network (e.g: port 0) has already attached to our PHY device,
> and we try to re-attach it with a different network device, but since we
> ignore the error we would end-up initializating incorrect device
> references by the time the slave network interface is opened.
> 
> The code has been (re)organized several times, making it hard to provide
> an exact Fixes tag, this is a bugfix nonetheless.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
