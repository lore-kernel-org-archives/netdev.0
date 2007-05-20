From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [5/5] 2.6.22-rc2: known regressions
Date: Sun, 20 May 2007 21:15:22 +1000
Message-ID: <E1HpjNi-0006oH-00@gondolin.me.apana.org.au>
References: <20070519215737.5a98a070@freepuppy>
Cc: davem@davemloft.net, michal.k.k.piotrowski@gmail.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, doug.chapman@hp.com, cramerj@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	bcollins@ubuntu.com, yoshfuji@linux-ipv6.org
To: shemminger@linux-foundation.org (Stephen Hemminger)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1254 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754783AbXETLP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 07:15:56 -0400
In-Reply-To: <20070519215737.5a98a070@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> Looks more like the IPV6 SNMP6 OOPS, I saw and fixed with:
> 
> commit 5632c5152aa621885d87ea0b8fdd5a6bb9f69c6f
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Sat Apr 28 21:16:39 2007 -0700
> 
>    [IPV6]: Track device renames in snmp6.
>    
>    When network device's are renamed, the IPV6 snmp6 code
>    gets confused. It doesn't track name changes so it will OOPS
>    when network device's are removed.
>    
>    The fix is trivial, just unregister/re-register in notify handler.
>    
>    Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>    Signed-off-by: David S. Miller <davem@davemloft.net>

It's quite possible that this fixes it, especially since the version
in Ubuntu's bug report came out the day before your fix went in :)

However, I don't really get why it's crashing in the first place.
Without your patch, if the device is renamed the proc entry just
keeps the original name.  When it goes down it should still get
removed correctly.

Could you explain this in a bit more detail?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
