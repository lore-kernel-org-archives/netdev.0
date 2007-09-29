From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sat, 29 Sep 2007 12:31:14 +0800
Message-ID: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2407 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750833AbXI2EbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 00:31:25 -0400
In-Reply-To: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> 
> Currently we have the call path:
> macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
>        __dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock
> 
> When mutex debugging is on taking a mutex complains if we are not
> allowed to sleep.  At that point we have called netif_tx_lock_bh
> so we are clearly not allowed to sleep.  Arguably this is not a
> problem for mutex_trylock.

Actually holding the TX lock here is a bug.  We're going to
call down into the hardware with __dev_set_promiscuity, which
may sleep (think USB NICs), so we definitely shouldn't be holding
any spin locks.

Patrick, could we avoid taking the TX lock here somehow?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
