From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Mon, 26 Jan 2015 14:36:13 -0800 (PST)
Message-ID: <20150126.143613.1798698028405169123.davem@davemloft.net>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
	<20150126222259.GC30116@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, tgraf@suug.ch, ying.xue@windriver.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150126222259.GC30116@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 27 Jan 2015 09:23:00 +1100

> On Mon, Jan 26, 2015 at 10:09:24AM +0000, David Laight wrote:
>>
>> That doesn't look right to me.
>> Surely you shouldn't be calling rcu_read_lock() when the mutex
>> request is interrupted.
>> 
>> So maybe:
>> 	err = mutex_lock_interruptible(&ht->mutex);
>> 	if (err)
>> 		return err;
>> 	rcu_read_lock();
> 
> No, we need to grab the RCU read lock while holding the mutex
> in order to prevent future resizes from happening once we release
> the mutex.
> 
> We don't want to hold the mutex which would stop other walks from
> starting.

I really think the amount of time and effort being put into making
the walker function properly is excessive.

Let's just say that if you want to use rhashtable, you have to use a
linked list, or similar separate mechanism, to have stable walks of
the entire set of objects.
