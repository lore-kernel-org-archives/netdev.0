From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 18:49:07 +0800
Message-ID: <20100310104907.GA23752@gondor.apana.org.au>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com> <201003101041.32518.arnd@arndb.de> <1268217583.2880.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, paulmck@linux.vnet.ibm.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39591 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753782Ab0CJKtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 05:49:17 -0500
Content-Disposition: inline
In-Reply-To: <1268217583.2880.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 11:39:43AM +0100, Eric Dumazet wrote:
>
> Its really rcu_dereference_bh() that could/should be used:
> I see no problem changing
> 
> 
>         local_bh_disable();
>         ...
>         rcu_read_lock();
>         rcu_dereference(rt_hash_table[h].chain);
>         rcu_read_unlock();
>         ...
>         local_bh_enable();

Why don't we just ignore the bh part for rcu_dereference?

After all it's call_rcu_bh and the other primitives that we really
care about.  For rcu_dereference bh should make no difference
whatsoever.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
