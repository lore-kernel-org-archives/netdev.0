From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Wed, 12 Dec 2007 21:31:58 +0800
Message-ID: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au>
References: <20071211034603.cbcc4762.akpm@linux-foundation.org>
Cc: olel@ans.pl, bugme-daemon@bugzilla.kernel.org,
	shemminger@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4790 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751659AbXLLNxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 08:53:16 -0500
In-Reply-To: <20071211034603.cbcc4762.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Remove stray rtnl_unlock().
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9542

Adnrew, please cc Jay Vosburgh <fubar@us.ibm.com> on bonding
issues.

> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> +++ a/drivers/net/bonding/bond_sysfs.c
> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
> out:
>        write_unlock_bh(&bond->lock);
> 
> -       rtnl_unlock();
> -

Looking at the changeset that added this perhaps the intention
is to hold the lock? If so we should add an rtnl_lock to the start
of the function.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
