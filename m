From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Sun, 05 Jul 2009 02:30:03 +0200
Message-ID: <4A4FF40B.5090003@itcare.pl>
References: <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:56069 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108AbZGEAaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jul 2009 20:30:02 -0400
In-Reply-To: <4A4FF34E.7080001@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh

I forgot - please Jarek give me patch with sync rcu and i will make tes=
t=20
on preempt kernel

Thanks
Pawe=B3 Staszewski

Pawe=B3 Staszewski pisze:
> Jarek Poplawski pisze:
>> On Thu, Jul 02, 2009 at 07:43:25AM +0200, Pawe=B3 Staszewski wrote:
>> =20
>>> Jarek Poplawski pisze:
>>>   =20
>>>> On Thu, Jul 02, 2009 at 12:17:19AM +0200, Pawe=B3 Staszewski wrote=
:
>>>>       =20
>>>>> Jarek Poplawski pisze:
>>>>>            =20
>>>> ...
>>>>       =20
>>>>>> So, after your findings I'm about to recommend sending to -stabl=
e
>>>>>> 3 patches from net-2.6, with additional lowering of threshold_ro=
ot
>>>>>> settings, but it would be nice if you could give it a try with
>>>>>> CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't bre=
ak
>>>>>> your other apps!) It is expected to work this time...;-) Maybe a
>>>>>> bit slower.
>>>>>>
>>>>>>  =20
> Ok kernel configured with CONFIG_PREEMPT
> and all this day work without any problems (with Jarek last patch).
>
>
> So in attached file trere is fib_tirestats
> I dont see any big change of (cpu load or faster/slower=20
> routing/propagating routes from bgpd or something else) - in avg ther=
e=20
> is from 2% to 3% more of CPU load i dont know why but it is - i chang=
e
> from "preempt" to "no preempt" 3 times and check this my "mpstat -P=20
> ALL 1 30"
> always avg cpu load was from 2 to 3% more compared to "no preempt"
>
> Regards
> Pawe=B3 Staszewski
>
>
>>>>>>                =20
>>>>> Patch applied to 2.6.29.5 with CONFIG_PREEMPT_NONE
>>>>> And working :)
>>>>>            =20
>>>> Hmm... It should, because you tested very similar patch already;-)
>>>> Sorry if I didn't make it clear.
>>>>
>>>>        =20
>>> Yes i know there was almost identical one.
>>> And i see this was without sync rcu :)
>>>    =20
>>
>> Yes, it looks like we can't free memory so simple because of such hu=
ge
>> latencies.=20
>> =20
>>>>> fib_triestats in attached file
>>>>>
>>>>> I think I can test it with PREEMPT enabled but first i must make=20
>>>>> some  other tests of my apps that are on server.
>>>>>            =20
>>>> It could probably matter only if you're using some broken out-of-t=
ree
>>>> patches. Otherwise the kernel is expected to work OK.
>>>>
>>>>        =20
>>> Im a little confused about using of PREEMPT kernel because of past
>>> there was many oopses / lockups :) but yes that was a little long=20
>>> time ago.
>>> I will try to make this test today.
>>>
>>>   =20
>>>> Btw., it would be also interesting to check if there is any differ=
ence
>>>> wrt. these route cache problems while PREEMPT is enabled.
>>>>      =20
>>
>> And you're very right! The place we're fixing is the best example. O=
n
>> the other hand, I hope there is not many such places yet. But if we
>> test/fix it there will be one less...
>>
>> Jarek P.
>>
>>
>>  =20
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

