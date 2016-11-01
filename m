From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: ensure coalesce settings survive
 read-modify-write
Date: Tue, 01 Nov 2016 12:18:11 -0400 (EDT)
Message-ID: <20161101.121811.1188428674232100128.davem@davemloft.net>
References: <E1c1Wdl-0000tO-Ql@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org
To: rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47392 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbcKAQSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:18:13 -0400
In-Reply-To: <E1c1Wdl-0000tO-Ql@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Tue, 01 Nov 2016 10:50:01 +0000

> The coalesce settings behave badly when changing just one value:
> 
> ... # ethtool -c eth0
> rx-usecs: 249
> ... # ethtool -C eth0 tx-usecs 250
> ... # ethtool -c eth0
> rx-usecs: 248
> 
> This occurs due to rounding errors when calculating the microseconds
> value - the divisons round down.  This causes (eg) the rx-usecs to
> decrease by one every time the tx-usecs value is set as per the above.
> 
> Fix this by making the divison round-to-nearest.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied, thanks.
