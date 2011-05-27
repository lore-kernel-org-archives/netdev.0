From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2 v2] af-packet: Use existing netdev reference for bound
 sockets.
Date: Fri, 27 May 2011 13:18:25 -0700
Message-ID: <4DE00711.6070000@candelatech.com>
References: <1306467745.2543.60.camel@edumazet-laptop>	<4DDF2463.3020001@candelatech.com>	<1306526921.2533.7.camel@edumazet-laptop> <20110527.161542.568477840432205227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53157 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab1E0USb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 16:18:31 -0400
In-Reply-To: <20110527.161542.568477840432205227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2011 01:15 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Fri, 27 May 2011 22:08:41 +0200
>
>> Le jeudi 26 mai 2011 =E0 21:11 -0700, Ben Greear a =E9crit :
>>> On 05/26/2011 08:42 PM, Eric Dumazet wrote:
>>>> Le jeudi 26 mai 2011 =E0 16:55 -0700, greearb@candelatech.com a =E9=
crit :
>>>
>>>>>    out_free:
>>>>>    	kfree_skb(skb);
>>>>>    out_unlock:
>>>>> -	if (dev)
>>>>> +	if (dev&&   need_rls_dev)
>>>>>    		dev_put(dev);
>>>>>    out:
>>>>>    	return err;
>>>>
>>>> Hmmm, I wonder why you want this Ben.
>>>>
>>>> IMHO this is buggy, because we can sleep in this function.
>>>>
>>>> We must take a ref on device (its really cheap these days, now we =
have a
>>>> percpu device refcnt)
>>>
>>> Why must you take the reference?  And if we must, why isn't the
>>> current code that assigns the prot_hook.dev without taking a
>>> reference OK?
>>>
>>
>> If we sleep, device can disappear under us.
>>
>> The only way to not take a reference is to hold rcu_read_lock(), but
>> you're not allowed to sleep under rcu_read_lock().
>
> You still have not addresses Ben's point.
>
> Why is it ok for the po->prot_hook.dev handling to not take a
> reference?  It's been doing this forever.  Ben is just borrowing this
> behavior for his uses.
>
> After some more research I think it happens to be OK because
> ->prot_hook.dev is used _only_ for pointer comparisons, it is never
> actually dereferenced or used in any other way.  Probably, we should
> just use ->ifindex for this.

It's easy enough to add a dev_hold() when I assign the skb instead
of looking it up in my patch, but perhaps it would be cleaner over all =
to
just hold a ref on the prot_hook.dev when it is originally assigned?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

