From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v2] net: fec: cache statistics while device is down
Date: Wed, 30 Nov 2016 12:44:57 -0500 (EST)
Message-ID: <20161130.124457.1899469473708436247.davem@davemloft.net>
References: <1480401891-19333-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        andrew@lunn.ch, eric@nelint.com, tremyfr@gmail.com,
        johannes@sipsolutions.net, netdev@vger.kernel.org,
        cphealy@gmail.com, fabio.estevam@nxp.com,
        linux-kernel@vger.kernel.org
To: nikita.yoush@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757638AbcK3RpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:45:10 -0500
In-Reply-To: <1480401891-19333-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Tue, 29 Nov 2016 09:44:51 +0300

> Execution 'ethtool -S' on fec device that is down causes OOPS on Vybrid
> board:
> 
> Unhandled fault: external abort on non-linefetch (0x1008) at 0xe0898200
> pgd = ddecc000
> [e0898200] *pgd=9e406811, *pte=400d1653, *ppte=400d1453
> Internal error: : 1008 [#1] SMP ARM
> ...
> 
> Reason of OOPS is that fec_enet_get_ethtool_stats() accesses fec
> registers while IPG clock is stopped by PM.
> 
> Fix that by caching statistics in fec_enet_private. Cache is initialized
> at device probe time, and updated at statistics request time if device
> is up, and also just before turning device off on down path.
> 
> Additional locking is not needed, since cached statistics is accessed
> either before device is registered, or under rtnl_lock().
> 
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>

Applied, thanks.
