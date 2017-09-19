From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: avoid a full fib lookup when rp_filter is
 disabled.
Date: Tue, 19 Sep 2017 05:00:33 -0700
Message-ID: <1505822433.29839.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1967ebaa528c626ebd9682e927fd33770a396a0a.1505817863.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34065 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbdISMAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:00:39 -0400
Received: by mail-it0-f66.google.com with SMTP id o200so2262913itg.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 05:00:39 -0700 (PDT)
In-Reply-To: <1967ebaa528c626ebd9682e927fd33770a396a0a.1505817863.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 12:46 +0200, Paolo Abeni wrote:
..

> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

> +/* called under RCU lock */
> +struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr)
> +{
> +	u32 hash = inet_addr_hash(net, addr);
> +	struct in_ifaddr *ifa;
> +
> +	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash)
> +		if (ifa->ifa_local == addr &&
> +		    net_eq(dev_net(ifa->ifa_dev->dev), net))
> +			return ifa;
> +
> +	return NULL;
> +}
> +

Any particular reason you do not use this helper to replace the lookup
in __ip_dev_find() ?

In this case, copy paste can be avoided, please avoid a future patch
consolidating the things...

Thanks.
