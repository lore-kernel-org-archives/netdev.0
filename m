From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Sat, 05 Dec 2015 22:48:29 -0500 (EST)
Message-ID: <20151205.224829.171477269244585844.davem@davemloft.net>
References: <20151204143956.GA17471@gondor.apana.org.au>
	<20151204.165334.1119277452308794437.davem@davemloft.net>
	<20151205070354.GA23255@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, phil@nwl.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151205070354.GA23255@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 5 Dec 2015 15:03:54 +0800

> Sorry Dave but you'll have to revert this because I've been able
> to trigger the following crash with the patch:
> 
> Testing concurrent rhashtable access from 50 threads
> ------------[ cut here ]------------
> kernel BUG at ../mm/vmalloc.c:1337!
> invalid opcode: 0000 [#1] PREEMPT SMP 
> 
> The reason is that because I was testing insertions with BH disabled,
> and __vmalloc doesn't like that, even with GFP_ATOMIC.  As we
> obviously want to continue to support rhashtable users inserting
> entries with BH disabled, we'll have to look for an alternate
> solution.

Ok, reverted, thanks for the heads up.
