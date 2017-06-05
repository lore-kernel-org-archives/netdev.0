From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: Fix stale cpu_switch reference after
 unbind then bind
Date: Sun, 04 Jun 2017 22:57:40 -0400 (EDT)
Message-ID: <20170604.225740.1710058828586611741.davem@davemloft.net>
References: <20170603050523.27014-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751212AbdFEC5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 22:57:47 -0400
In-Reply-To: <20170603050523.27014-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  2 Jun 2017 22:05:23 -0700

> Commit 9520ed8fb841 ("net: dsa: use cpu_switch instead of ds[0]")
> replaced the use of dst->ds[0] with dst->cpu_switch since that is
> functionally equivalent, however, we can now run into an use after free
> scenario after unbinding then rebinding the switch driver.
> 
> The use after free happens because we do correctly initialize
> dst->cpu_switch the first time we probe in dsa_cpu_parse(), then we
> unbind the driver: dsa_dst_unapply() is called, and we rebind again.
> dst->cpu_switch now points to a freed "ds" structure, and so when we
> finally dereference it in dsa_cpu_port_ethtool_setup(), we oops.
> 
> To fix this, simply set dst->cpu_switch to NULL in dsa_dst_unapply()
> which guarantees that we always correctly re-assign dst->cpu_switch in
> dsa_cpu_parse().
> 
> Fixes: 9520ed8fb841 ("net: dsa: use cpu_switch instead of ds[0]")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
