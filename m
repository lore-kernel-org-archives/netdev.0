From: Roy Keene <lkml@rkeene.org>
Subject: Re: ip_rcv_finish() NULL pointer kernel panic
Date: Thu, 26 Jan 2017 10:02:58 -0600 (CST)
Message-ID: <alpine.LNX.2.02.1701260959410.24491@maul.oc9.org>
References: <alpine.LNX.2.02.1701260627510.24491@maul.oc9.org>  <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org> <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oc9.org ([108.175.9.112]:47106 "EHLO mail.oc9.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752265AbdAZQFm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 11:05:42 -0500
In-Reply-To: <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, 2017-01-26 at 09:32 -0600, Roy Keene wrote:
>> This bug appears to have existed for a long time:
>>
>>  	https://www.spinics.net/lists/netdev/msg222459.html
>>
>>  	http://www.kernelhub.org/?p=2&msg=823752
>>
>> Though possibly with different things not setting the "input" function
>> pointer in the "struct dst_entry".
>>
>> include/net/dst.h:
>>   496 static inline int dst_input(struct sk_buff *skb) {
>>   498         return skb_dst(skb)->input(skb);
>>   499 }
>>
>> Is there any reason not to check to see if this pointer is NULL before
>> blindly calling it ?
>
> Sure. It can not be NULL at this point.
>

It clearly can be NULL at this point, since there are kernel panics for 
15 years of this -- going all the way back to 2.2.20 !

https://lists.gt.net/linux/kernel/250077

It seems like it might actually be a good idea to do as Alex Bligh 
suggested all those years ago and I re-suggested now.

> Just look at the code in ip_rcv_finish() :
>
> It first make sure to get a valid dst.
>
> Something is broken, probably in bridge netfilter code.
>

I'll try poking around there.

> I suspect the dst here points to &br->fake_rtable, and this is not
> expected.
>
> br_drop_fake_rtable() should have been called somewhere ...
>

Thanks,
 	Roy Keene
