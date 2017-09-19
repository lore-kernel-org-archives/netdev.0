From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit statistics dependency
Date: Mon, 18 Sep 2017 20:59:09 -0700 (PDT)
Message-ID: <20170918.205909.830536173892414747.davem@davemloft.net>
References: <20170918233130.5740-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jqiaoulk@gmail.com,
        kiki-good@hotmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38092 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdISD7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 23:59:09 -0400
In-Reply-To: <20170918233130.5740-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 18 Sep 2017 16:31:30 -0700

> There are several problems with commit 10377ba7673d ("net: systemport:
> Support 64bit statistics", first one got fixed in 7095c973453e ("net:
> systemport: Fix 64-bit stats deadlock").
> 
> The second problem is that this specific code updates the
> stats64.tx_{packets,bytes} from ndo_get_stats64() and that is what we
> are returning to ethtool -S. If we are not running a tool that involves
> calling ndo_get_stats64(), then we won't get updated ethtool stats.
> 
> The solution to this is to update the stats from both call sites,
> factoring that into a specific function, While at it, don't just check
> the sizeof() but also the type of the statistics in order to use the
> 64-bit stats seqlock.
> 
> Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics"
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
