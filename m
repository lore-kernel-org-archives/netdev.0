From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Thu, 24 Aug 2006 13:04:47 +0200
Message-ID: <44ED87CF.20702@o2.pl>
References: <20060817093615.GA25553@ms2.inr.ac.ru>	<20060821081642.GA2637@ff.dom.local>	<20060821.011703.78716718.davem@davemloft.net>	<20060821110201.GA3674@ff.dom.local>	<20060822103556.GA3262@ff.dom.local> <20060823113119.03f47a6a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:62611 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751099AbWHXLEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 07:04:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060823113119.03f47a6a@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23-08-2006 20:31, Stephen Hemminger wrote:
> On Tue, 22 Aug 2006 12:35:56 +0200
> Jarek Poplawski <jarkao2@o2.pl> wrote:
...
>> I've found it at last but on that occasion I've got some
>> doubt according to rcu_read_lock and rcu_call treatment:
>> isn't it "illegal to block while in an RCU read-side
>> section"? And I think it takes place in:
>>
> 
> No, it is perfectly okay for a cpu to acquire a lock
> while in an RCU section, it just can't acquire a mutex/semaphore that
> will put it to sleep. That is caught by the might_sleep() check.

Then I've wrongly understood it can't sleep while in RCU
and that enabled bh can make it sleep.

>> fib_lookup(): from tb_insert (fn_hash_insert() or
>>   fn_trie_insert()), fib_create_info(), fib_check_nh() 
>>
>> fn_trie_lookup(): like above, inet_addr_type(),
>>   tb_lookup()
>>
>> fib_rule_put(): like #1 above or #2 after tb_lookup(),
>>   fib_res_put()
>>
>> Shouldn't there be _bh also?
> 
> fib_rule_put only does something if refcount == 1 in which
> case it is safe.

It's like above. I've thought (wrongly): fib_rule_put() calls 
call_rcu() and is made to sleep.

Thanks for explaining: now I can peacefully go... to sleep!

Jarek P.


