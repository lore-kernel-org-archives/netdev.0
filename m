From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: update dst pmtu if dev mtu has been
 updated by toobig in __gre6_xmit
Date: Fri, 27 Oct 2017 23:47:44 +0900 (KST)
Message-ID: <20171027.234744.338890618506522684.davem@davemloft.net>
References: <a5c60f03402e5b0b257c5b4bb8f6a629d8a9ac38.1509017237.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751745AbdJ0Orv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:51 -0400
In-Reply-To: <a5c60f03402e5b0b257c5b4bb8f6a629d8a9ac38.1509017237.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 26 Oct 2017 19:27:17 +0800

> When receiving a Toobig icmpv6 packet, ip6gre_err would just set
> tunnel dev's mtu, that's not enough. For skb_dst(skb)'s pmtu may
> still be using the old value, it has no chance to be updated with
> tunnel dev's mtu.
> 
> Jianlin found this issue by reducing route's mtu while running
> netperf, the performance went to 0.
> 
> ip6ip6 and ip4ip6 tunnel can work well with this, as they lookup
> the upper dst and update_pmtu it's pmtu or icmpv6_send a Toobig
> to upper socket after setting tunnel dev's mtu.
> 
> We couldn't do that for ip6_gre, as gre's inner packet could be
> any protocol, it's difficult to handle them (like lookup upper
> dst) in a good way.
> 
> So this patch is to fix it by updating skb_dst(skb)'s pmtu when
> dev->mtu < skb_dst(skb)'s pmtu in tx path. It's safe to do this
> update there, as usually dev->mtu <= skb_dst(skb)'s pmtu and no
> performance regression can be caused by this.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.

Thanks.
