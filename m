From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: iproute2: Behavioural Bug?
Date: Tue, 25 Aug 2015 10:44:09 +0530
Message-ID: <CAA5aLPj6Whq_U3VXx60J+b0rZFj9kucXy8H9NM9rYCTc9OPMoQ@mail.gmail.com>
References: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
	<20150824232229.GC5905@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	xiyou.wangcong@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:36440 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbbHYFOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 01:14:09 -0400
Received: by obkg7 with SMTP id g7so132781522obk.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 22:14:09 -0700 (PDT)
In-Reply-To: <20150824232229.GC5905@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian,

There are two filters 15:2:2 and 15:2:3 and I have deleted only
15:2:3, so 15:2:2 will still be there and hence this condition
"destroy proto tp when all filters are gone" should not be applicable
over here.

On Tue, Aug 25, 2015 at 4:52 AM, Florian Westphal <fw@strlen.de> wrote:
> Akshat Kakkar <akshat.1984@gmail.com> wrote:
>
> [ CC Cong ]
>
>> When I am trying to delete a single tc filter (i.e. specifying its
>> handle), it is deleting all the
>> filters with the same priority/preference. i.e. it is ignoring the
>> handle specified.
>>
>> But, When I am doing similar activity in hashtable 800: it is deleting only the
>> specified filter, i.e. it is behaving as expected.
>>
>> I am unable to comprehend the reason for this difference in behaviour.
>>
>> Infact, in kernel 2.6.32 all is working as expected. However, in
>> kernel 3.1 and 4.1 it is having the behaviour as mentioned above.
>>
>> For example, following set of commands  create a hashtable 15: and add
>> 2 filters to it.
>>
>> tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
>> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
>> ht 15:2: match ip src 10.0.0.2 flowid 1:10
>> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
>> ht 15:2: match ip src 10.0.0.3 flowid 1:10
>>
>> Now following command DELETES ALL THE FILTERS, though it should only
>> delete FILTER 15:2:3 !
>> tc filter del dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
>>
>> O/p of tc filter show eth0 is this case is blank. As all filters are deleted.
>
> Happens since
>
> 1e052be69d045c8d0f82ff1116fd3e5a79661745
> ("net_sched: destroy proto tp when all filters are gone").
