From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Thu, 18 Dec 2008 14:23:33 +0300
Message-ID: <494A32B5.2020802@bigtelecom.ru>
References: <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local> <48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local> <493FDCD4.5020108@bigtelecom.ru> <20081211084606.GA4129@ff.dom.local> <20081215111308.GA5853@ff.dom.local> <4949F127.6030105@bigtelecom.ru> <20081218081737.GA8416@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:48222 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbYLRLXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 06:23:40 -0500
In-Reply-To: <20081218081737.GA8416@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for all Jarek!

Vyacheslav Badalian

> On Thu, Dec 18, 2008 at 09:43:51AM +0300, Badalian Vyacheslav wrote:
>   
>> Hello
>> result: Patch 2+3 = uptime 7 days without crashes.
>> May i revert patches and try single new patch?
>>     
>
> Here is my current opinion on this bug:
>
> 1) I'm almost sure it's not a htb, but hrtimers bug (some race),
>
> 2) the htb patches you've tested are not "the proper" way of fixing
>    it; I see substantial changes in hrtimers code in the "-tip" tree
>    (probably for 2.6.29), which, probably, you'll be advised by
>    hrtimers maintainers to try, and I guess, it's not easy on a
>    production system,
>
> So, it's up to you:
>
> 1) since these patches work for you, you can stop with testing and
>    wait with these patched kernels until 2.6.29 (I can propose this
>    #2 patch as a temporary fix then),
>
> 2) for curiosity you could try this patch #4 alone on one box first
>    (after reverting at least patch #2), but again: if it works, it
>    could be only treated as a temporary hack, and alternative of #2.
>
> Thanks,
> Jarek P.
>
>   
>>> On Thu, Dec 11, 2008 at 08:46:06AM +0000, Jarek Poplawski wrote:
>>>   
>>>       
>>>> On Wed, Dec 10, 2008 at 06:14:28PM +0300, Badalian Vyacheslav wrote:
>>>>     
>>>>         
>>>>> Hello again! Sorry for long away.
>>>>>       
>>>>>           
>>>> Hi!
>>>>
>>>>     
>>>>         
>>>>> I was go away from this work for long time.
>>>>>
>>>>> May we return to this bug?
>>>>> Servers at last stable kernel 2.6.27.8
>>>>> HZ=1000, HR=off, DynamicTicks=off, hysteresis=1
>>>>> Sorry - no patched, update do not i. Do you have fresh patches or ideas
>>>>> for tests?
>>>>>       
>>>>>           
>>>> Not much, but I can have if you only are willing to test them...
>>>> I attach below a patch which combines 2 patches I sent yesterday to
>>>> netdev (PATCH 7/6 and 8/6) vs. 2.6.27.7 (named testing patch #3 here).
>>>>
>>>> You can still try the testing patch #2 I sent previously (quoted below)
>>>> with or without this new #3 patch.
>>>>
>>>>     
>>>>         
>>> Here is another idea worth checking (instead of patch #2).
>>>
>>> Jarek P.
>>>
>>> --- (testing patch #4)
>>>
>>> diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
>>> --- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
>>> +++ b2.6.27.7/net/sched/sch_htb.c	2008-12-15 10:44:32.000000000 +0000
>>> @@ -924,6 +924,7 @@ static struct sk_buff *htb_dequeue(struc
>>>  		}
>>>  	}
>>>  	sch->qstats.overlimits++;
>>> +	qdisc_watchdog_cancel(&q->watchdog);
>>>  	qdisc_watchdog_schedule(&q->watchdog, next_event);
>>>  fin:
>>>  	return skb;
>>>
>>>
>>>   
>>>       
>
>
>   

