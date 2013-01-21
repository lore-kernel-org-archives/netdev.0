From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next 2/2] mcast: add multicast proxy support (IPv4 and IPv6)
Date: Mon, 21 Jan 2013 09:12:06 -0500
Message-ID: <OF894319C2.8EF01FDC-ON87257AFA.004BC5D6-85257AFA.004E0255@us.ibm.com>
References: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com> <1358528378-2110-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:56904 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab3AUONc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 09:13:32 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 21 Jan 2013 07:13:31 -0700
In-Reply-To: <1358528378-2110-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index a9454cb..e8ec94a 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -828,6 +828,48 @@ static struct mfc_cache *ipmr_cache_find(struct
> mr_table *mrt,
>     return NULL;
>  }
> 
> +/* Look for a (*,*,oif) entry */
> +static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table 
*mrt,
> +                      int vifi)
> +{
> +   int line = MFC_HASH(0, 0);
> +   struct mfc_cache *c;
> +
> +   list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
> +      if (c->mfc_origin == 0 &&
> +          c->mfc_mcastgrp == 0 &&

        These are addresses-- should compare against INADDR_ANY to make 
that
clear.

...
> +static struct mfc_cache *ipmr_cache_find_any(struct mr_table *mrt,
> +                    __be32 mcastgrp, int vifi)
> +{
...
> +
> +   list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
> +      if (c->mfc_origin == 0 && c->mfc_mcastgrp == mcastgrp) {

        Use INADDR_ANY instead of 0.

> 
> -   if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
> +   if (mfc->mfcc_mcastgrp.s_addr &&
> +       !ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
>        return -EINVAL;

        mfc->mfcc_mcastgrp.s_addr != INADDR_ANY &&
 
Otherwise, it looks ok to me. With those changes,

Acked-by: David L Stevens <dlstevens@us.ibm.com>

                                                +-DLS
