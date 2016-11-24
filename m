From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: bump genid when the IFA_F_TENTATIVE flag is
 clear
Date: Thu, 24 Nov 2016 12:04:55 -0500 (EST)
Message-ID: <20161124.120455.1449935896058022891.davem@davemloft.net>
References: <f91712a692016619312fdb480ff4ef290bd961db.1479830136.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hideaki.yoshifuji@miraclelinux.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756858AbcKXRE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 12:04:58 -0500
In-Reply-To: <f91712a692016619312fdb480ff4ef290bd961db.1479830136.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 22 Nov 2016 16:57:40 +0100

> When an ipv6 address has the tentative flag set, it can't be
> used as source for egress traffic, while the associated route,
> if any, can be looked up and even stored into some dst_cache.
> 
> In the latter scenario, the source ipv6 address selected and
> stored in the cache is most probably wrong (e.g. with
> link-local scope) and the entity using the dst_cache will
> experience lack of ipv6 connectivity until said cache is
> cleared or invalidated.
> 
> Overall this may cause lack of connectivity over most IPv6 tunnels
> (comprising geneve and vxlan), if the first egress packet reaches
> the tunnel before the DaD is completed for the used ipv6
> address.
> 
> This patch bumps a new genid after that the IFA_F_TENTATIVE flag
> is cleared, so that dst_cache will be invalidated on
> next lookup and ipv6 connectivity restored.
> 
> Fixes: 0c1d70af924b ("net: use dst_cache for vxlan device")
> Fixes: 468dfffcd762 ("geneve: add dst caching support")
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thanks.
