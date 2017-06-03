From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: Fix stale cpu_switch reference after unbind then bind
Date: Sat, 03 Jun 2017 13:50:01 -0400
Message-ID: <87r2z1c65y.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170603050523.27014-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56410 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdFCRwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 13:52:06 -0400
In-Reply-To: <20170603050523.27014-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

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

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks!

        Vivien
