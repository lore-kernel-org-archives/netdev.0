From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Prevent GPHY shutdown for
 kexec'd kernels
Date: Thu, 20 Oct 2016 14:44:31 -0400 (EDT)
Message-ID: <20161020.144431.1484493400918018326.davem@davemloft.net>
References: <1476981139-28889-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753428AbcJTSod (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:44:33 -0400
In-Reply-To: <1476981139-28889-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 20 Oct 2016 09:32:19 -0700

> For a kernel that is being kexec'd we re-enable the integrated GPHY in
> order for the subsequent MDIO bus scan to succeed and properly bind to
> the bcm7xxx PHY driver. If we did not do that, the GPHY would be shut
> down by the time the MDIO driver is probing the bus, and it would fail
> to read the correct PHY OUI and therefore bind to an appropriate PHY
> driver. Later on, this would cause DSA not to be able to successfully
> attach to the PHY, and the interface would not be created at all.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, but I have to wonder...

If enabling the GPHY is necessary for proper probing, why isn't the
kexec kernel enabling it properly?
