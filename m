From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rhashtable: Kill harmless RCU warning in
 rhashtable_walk_init
Date: Fri, 18 Dec 2015 23:42:59 -0500 (EST)
Message-ID: <20151218.234259.445944618583370177.davem@davemloft.net>
References: <20151218131408.GA21756@gondor.apana.org.au>
	<20151218.162731.305092674804556753.davem@davemloft.net>
	<20151219024528.GA27814@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ying.huang@linux.intel.com, lkp@01.org,
	linux-kernel@vger.kernel.org, colin.king@canonical.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151219024528.GA27814@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 19 Dec 2015 10:45:28 +0800

> On Fri, Dec 18, 2015 at 04:27:31PM -0500, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Fri, 18 Dec 2015 21:14:08 +0800
>> 
>> > On Fri, Dec 18, 2015 at 04:54:14AM -0800, Eric Dumazet wrote:
>> >>
>> >> You can avoid the comment by using the self documented and lockdep
>> >> enabled primitive
>> >> 
>> >> iter->walker->tbl = rcu_dereference_protected(ht->tbl,
>> >> 					      lockdep_is_held(&ht->lock));
>> > 
>> > That is just gross.  I think a comment is much better in this case.
>> 
>> Herbert, this macro was created exactly to handle this situation,
>> and this is what we do everywhere else in the tree.
> 
> OK.
> 
> ---8<---
> The commit f9f51b8070be3e829100614a7372b219723b864f ("rhashtable:
> Fix walker list corruption") causes a suspicious RCU usage warning
> because we no longer hold ht->mutex when we dereference ht->tbl.
> 
> However, this is a false positive because we now hold ht->lock
> which also guarantees that ht->tbl won't disppear from under us.
> 
> This patch kills the warning by using rcu_dereference_protected.
> 
> Reported-by: kernel test robot <ying.huang@linux.intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

The correct commti SHA1 is c6ff5268293ef98e48a99597e765ffc417e39fa5.

Or at least, when I run:

	git show f9f51b8070be3e829100614a7372b219723b864f

I get:

	fatal: bad object f9f51b8070be3e829100614a7372b219723b864f

:-)

I fixed this up and applied this, thanks!
