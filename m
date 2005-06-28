From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] bugfix and scalability changes in net/ipv4/route.c
Date: Tue, 28 Jun 2005 13:14:32 -0700 (PDT)
Message-ID: <20050628.131432.13759019.davem@davemloft.net>
References: <Pine.LNX.4.62.0506232057340.29222@graphe.net>
	<20050623.211140.131918815.davem@davemloft.net>
	<42BBE72B.5010501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: dada1@cosmosbay.com
In-Reply-To: <42BBE72B.5010501@cosmosbay.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 24 Jun 2005 12:57:47 +0200

> reminder of the bugfix :
> 
> The rt_check_expire() has a serious problem on machines with large
> route caches, and a standard HZ value of 1000.
> 
> With default values, ie ip_rt_gc_interval = 60*HZ = 60000 ;
> 
> the loop count :
> 
>      for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;
> 
> 
> overflows (t is a 31 bit value) as soon rt_hash_log is >= 16  (65536
> slots in route cache hash table).
> 
> In this case, rt_check_expire() does nothing at all

I'd like this bug fix as a seperate patch.

Also, coding style problems in the spinlock part of the patch:

+	static spinlock_t	*rt_hash_locks;

That's a file static variable, no need to tab it at all.

+		if (*rthp == 0) continue ;

Please put the continue on a seperate line, properly
tabbed, and without a space between the continue and the
closing semicolon.

Please scan the rest of your patch for problems like this.

So, again please submit a seperate patch for the overflow
bug, then one for the locking changes, so they may be evaluated
and applied seperately.

Thanks a lot.
