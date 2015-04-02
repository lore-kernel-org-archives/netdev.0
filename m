From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [rhashtable] [ INFO: suspicious RCU usage. ]
Date: Thu, 2 Apr 2015 11:58:10 +0800
Message-ID: <20150402035810.GA5408@gondor.apana.org.au>
References: <20150402005211.GC12979@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150402005211.GC12979@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2015 at 08:52:11AM +0800, Fengguang Wu wrote:
> Hi Herbert,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> 
> commit ccd57b1bd32460d27bbb9c599e795628a3c66983
> Author:     Herbert Xu <herbert@gondor.apana.org.au>
> AuthorDate: Tue Mar 24 00:50:28 2015 +1100
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Mon Mar 23 22:07:52 2015 -0400
> 
>     rhashtable: Add immediate rehash during insertion
>     
>     This patch reintroduces immediate rehash during insertion.  If
>     we find during insertion that the table is full or the chain
>     length exceeds a set limit (currently 16 but may be disabled
>     with insecure_elasticity) then we will force an immediate rehash.
>     The rehash will contain an expansion if the table utilisation
>     exceeds 75%.
>     
>     If this rehash fails then the insertion will fail.  Otherwise the
>     insertion will be reattempted in the new hash table.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Acked-by: Thomas Graf <tgraf@suug.ch>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> [    0.552992]   Adding 2048 keys
> [    0.553792] 
> [    0.554400] ===============================
> [    0.555285] [ INFO: suspicious RCU usage. ]
> [    0.556176] 4.0.0-rc4-01225-gccd57b1 #171 Not tainted
> [    0.557156] -------------------------------
> [    0.558044] lib/rhashtable.c:400 suspicious rcu_dereference_check() usage!

This should have been fixed by

	58be8a583d8d316448bafa5926414cfb83c02dec.

Can you check whether this commit was in your tested tree?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
