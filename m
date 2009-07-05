From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Sun, 05 Jul 2009 02:31:04 +0200
Message-ID: <4A4FF448.9000102@itcare.pl>
References: <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020603040408050800060002"
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:45791 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822AbZGEAbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jul 2009 20:31:03 -0400
In-Reply-To: <4A4FF34E.7080001@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020603040408050800060002
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Sorry again no attachement.




Pawe³ Staszewski pisze:
> Jarek Poplawski pisze:
>> On Thu, Jul 02, 2009 at 07:43:25AM +0200, Pawe³ Staszewski wrote:
>>  
>>> Jarek Poplawski pisze:
>>>    
>>>> On Thu, Jul 02, 2009 at 12:17:19AM +0200, Pawe³ Staszewski wrote:
>>>>        
>>>>> Jarek Poplawski pisze:
>>>>>             
>>>> ...
>>>>        
>>>>>> So, after your findings I'm about to recommend sending to -stable
>>>>>> 3 patches from net-2.6, with additional lowering of threshold_root
>>>>>> settings, but it would be nice if you could give it a try with
>>>>>> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't break
>>>>>> your other apps!) It is expected to work this time...;-) Maybe a
>>>>>> bit slower.
>>>>>>
>>>>>>   
> Ok kernel configured with CONFIG_PREEMPT
> and all this day work without any problems (with Jarek last patch).
>
>
> So in attached file trere is fib_tirestats
> I dont see any big change of (cpu load or faster/slower 
> routing/propagating routes from bgpd or something else) - in avg there 
> is from 2% to 3% more of CPU load i dont know why but it is - i change
> from "preempt" to "no preempt" 3 times and check this my "mpstat -P 
> ALL 1 30"
> always avg cpu load was from 2 to 3% more compared to "no preempt"
>
> Regards
> Pawe³ Staszewski
>
>
>>>>>>                 
>>>>> Patch applied to 2.6.29.5 with CONFIG_PREEMPT_NONE
>>>>> And working :)
>>>>>             
>>>> Hmm... It should, because you tested very similar patch already;-)
>>>> Sorry if I didn't make it clear.
>>>>
>>>>         
>>> Yes i know there was almost identical one.
>>> And i see this was without sync rcu :)
>>>     
>>
>> Yes, it looks like we can't free memory so simple because of such huge
>> latencies. 
>>  
>>>>> fib_triestats in attached file
>>>>>
>>>>> I think I can test it with PREEMPT enabled but first i must make 
>>>>> some  other tests of my apps that are on server.
>>>>>             
>>>> It could probably matter only if you're using some broken out-of-tree
>>>> patches. Otherwise the kernel is expected to work OK.
>>>>
>>>>         
>>> Im a little confused about using of PREEMPT kernel because of past
>>> there was many oopses / lockups :) but yes that was a little long 
>>> time ago.
>>> I will try to make this test today.
>>>
>>>    
>>>> Btw., it would be also interesting to check if there is any difference
>>>> wrt. these route cache problems while PREEMPT is enabled.
>>>>       
>>
>> And you're very right! The place we're fixing is the best example. On
>> the other hand, I hope there is not many such places yet. But if we
>> test/fix it there will be one less...
>>
>> Jarek P.
>>
>>
>>   
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--------------020603040408050800060002
Content-Type: text/plain;
 name="fib_triestats.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_triestats.txt"

cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     2.44
        Max depth:      6
        Leaves:         277814
        Prefixes:       291306
        Internal nodes: 66420
          1: 32737  2: 14850  3: 10332  4: 4871  5: 2313  6: 942  7: 371  8: 3  17: 1
        Pointers: 599098
Null ptrs: 254865
Total size: 18067  kB

Counters:
---------
gets = 2003686
backtracks = 78789
semantic match passed = 1977687
semantic match miss = 112
null node hit= 1470619
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 2008497
backtracks = 1417179
semantic match passed = 4823
semantic match miss = 0
null node hit= 197044
skipped node resize = 0





--------------020603040408050800060002--
