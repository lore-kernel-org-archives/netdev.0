From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Thu, 11 Aug 2016 17:08:30 -0700
Message-ID: <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com> <CAM_iQpUCqzytG662vBd4D0Zx09CWA9a1VuZerTatMMhdy42jBA@mail.gmail.com>
 <62bb1c25-2967-dedc-89ac-01632d0e090d@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35658 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbcHLAIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 20:08:51 -0400
Received: by mail-io0-f196.google.com with SMTP id q83so722019iod.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 17:08:51 -0700 (PDT)
In-Reply-To: <62bb1c25-2967-dedc-89ac-01632d0e090d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 9:20 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-08-10 04:06 PM, Cong Wang wrote:
>>
>> On Wed, Aug 10, 2016 at 7:34 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>> On 16-08-08 04:46 PM, Cong Wang wrote:
>
>
>>> tcf_exts_exec() is the culprit - and conversion to from flexarray
>>> to linked list in the fast problem to be specific.
>>
>>
>> Ah, this reminds me that I don't have to use flex_array, initially
>> I thought the tcf_exts could hold as many actions as it wants,
>> but actually there is a upper bound, TCA_ACT_MAX_PRIO.
>> IOW, a regular dynamic array is just enough here.
>>
>
> Yes, a regular array would be enough.
>
>
>> I just replaced the flex_array with a regular one, it works fine
>> for me too, at least no crash with all of my test cases.
>>
>
> Ok, I did a quick look at your patch - I still see you converting
> from array to list. I mean get tcf_exts_exec() to take an array
> and walk it. That will restore the perf numbers to the same level.


Makes sense! I just did this change as you suggest.


>
>> Please try v2, since you have more test cases that I do.
>> Or it would be great if you can share your test cases with
>> me or us.
>>
>> Be patient, every big change could have regression. :)
>>
>
> No problem Cong - except we have a kernel that crashes right now.
> BTW: I just thought of another test which uses a different code
> path
> # add a policer rule
> sudo $TC actions add action police rate 1kbit burst 90k drop
> #dump rules..
> sudo $TC -s actions ls action police
>

Passed:

[root@localhost ~]# tc actions add action police rate 1kbit burst 90k drop
[root@localhost ~]# tc actions ls action police

action order 0:  police 0x1 rate 1000bit burst 23440b mtu 2Kb action
drop overhead 0b
ref 1 bind 0
[root@localhost ~]# tc -s actions ls action police

action order 0:  police 0x1 rate 1000bit burst 23440b mtu 2Kb action
drop overhead 0b
ref 1 bind 0
Action statistics:
Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
backlog 0b 0p requeues 0


Thanks.
