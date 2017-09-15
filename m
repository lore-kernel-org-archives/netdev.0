From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit stats deadlock
Date: Fri, 15 Sep 2017 14:25:11 -0700 (PDT)
Message-ID: <20170915.142511.221689318302073484.davem@davemloft.net>
References: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jqiaoulk@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdIOVZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:25:12 -0400
In-Reply-To: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 12 Sep 2017 13:14:26 -0700

> We can enter a deadlock situation because there is no sufficient protection
> when ndo_get_stats64() runs in process context to guard against RX or TX NAPI
> contexts running in softirq, this can lead to the following lockdep splat and
> actual deadlock was experienced as well with an iperf session in the background
> and a while loop doing ifconfig + ethtool.
 ...
> So just remove the u64_stats_update_begin()/end() pair in ndo_get_stats64()
> since it does not appear to be useful for anything. No inconsistency was
> observed with either ifconfig or ethtool, global TX counts equal the sum of
> per-queue TX counts on a 32-bit architecture.
> 
> Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
