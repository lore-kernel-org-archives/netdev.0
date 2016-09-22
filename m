From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: explicitly whitelist sysctls for unpriv namespaces
Date: Thu, 22 Sep 2016 01:31:18 -0400 (EDT)
Message-ID: <20160922.013118.694533431543433612.davem@davemloft.net>
References: <1474232300-8423-1-git-send-email-jann@thejh.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: jann@thejh.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754574AbcIVFbW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:31:22 -0400
In-Reply-To: <1474232300-8423-1-git-send-email-jann@thejh.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jann Horn <jann@thejh.net>
Date: Sun, 18 Sep 2016 22:58:20 +0200

> There were two net sysctls that could be written from unprivileged net
> namespaces, but weren't actually namespaced.
> 
> To fix the existing issues and prevent stuff this from happening again in
> the future, explicitly whitelist permitted sysctls.
> 
> Note: The current whitelist is "allow everything that was previously
> accessible and that doesn't obviously modify global state".
> 
> On my system, this patch just removes the write permissions for
> ipv4/netfilter/ip_conntrack_max, which would have been usable for a local
> DoS. With a different config, the ipv4/vs/debug_level sysctl would also be
> affected.
> 
> Maximum impact of this seems to be local DoS, and it's a fairly large
> commit, so I'm sending this publicly directly.
> 
> An alternative (and much smaller) fix would be to just change the
> permissions of the two files in question to be 0444 in non-privileged
> namespaces, but I believe that this solution is slightly less error-prone.
> If you think I should switch to the simple fix, let me know.
> 
> Signed-off-by: Jann Horn <jann@thejh.net>

And actually this patch dosn't apply cleanly to net-next, please
respin.

Thanks.
