From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Kill harmless RCU warning in rhashtable_walk_init
Date: Fri, 18 Dec 2015 16:27:31 -0500 (EST)
Message-ID: <20151218.162731.305092674804556753.davem@davemloft.net>
References: <20151218062450.GA19749@gondor.apana.org.au>
	<1450443254.8474.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151218131408.GA21756@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ying.huang@linux.intel.com, lkp@01.org,
	linux-kernel@vger.kernel.org, colin.king@canonical.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151218131408.GA21756@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 18 Dec 2015 21:14:08 +0800

> On Fri, Dec 18, 2015 at 04:54:14AM -0800, Eric Dumazet wrote:
>>
>> You can avoid the comment by using the self documented and lockdep
>> enabled primitive
>> 
>> iter->walker->tbl = rcu_dereference_protected(ht->tbl,
>> 					      lockdep_is_held(&ht->lock));
> 
> That is just gross.  I think a comment is much better in this case.

Herbert, this macro was created exactly to handle this situation,
and this is what we do everywhere else in the tree.

Please use it.

Thanks.
