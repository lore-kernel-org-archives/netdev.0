From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/54][pull request] Using dev_kfree/consume_skb_any
 for functions called in multiple contexts
Date: Tue, 25 Mar 2014 18:54:55 -0400 (EDT)
Message-ID: <20140325.185455.2003891926756741271.davem@davemloft.net>
References: <87r468bfqj.fsf_-_@xmission.com>
	<87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	<1395780591.12610.185.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbaCYWzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 18:55:06 -0400
In-Reply-To: <1395780591.12610.185.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Mar 2014 13:49:51 -0700

> On Mon, 2014-03-24 at 22:58 -0700, Eric W. Biederman wrote:
>> These changes are a result of walking through the network drivers
>> supporting netpoll and verifying the code paths that netpoll can cause
>> to be called in hard irq context use an appropriate flavor of
>> kfree_skb.  Either dev_kfree_skb_any or dev_consume_skb_any.
>> 
>> Since my last pass at this I have become aware of the small differences
>> between dev_kfree_skb_any and dev_consume_skb_any.
>> net/core/drop_monitor.c reports the dev_kfree_skb_any as a drop and
>> while being quite about the second.  With the weird twist that
>> dev_kfree_skb is unintuitively consume_skb.
>> 
>> As netpoll now calls the napi poll function with budget == 0, pieces of
>> a drivers the napi poll function that don't run when budget == 0 have
>> been ignored.
>> 
>> The most interesting change is to the atl1c which tried unsuccesfully to
>> tell one of it's functions which context it is called in so that it
>> could call dev_kfree_skb_irq or dev_kfree_skb as appropriate.  I have
>> just removed the extra parameter and called dev_consume_skb_any.
>> 
>> At 54 separate changes I will post each change as a separate patch (so
>> they can be reviewed) but for general sanity sake I have gathered them
>> all into a git branch for easy acces.
>> 
>> David when you are satisified with these changes please pull:
>> 
>>     git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master
>> 
>> Hopefully this will allow me to forget this class of error when dealing
>> with netpoll.
> 
> 
> Perfect, thanks Eric.
> 
> (the minor issues can be addressed later in a single followup)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Pulled, thanks everyone.
