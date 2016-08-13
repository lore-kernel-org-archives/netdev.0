From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Sat, 13 Aug 2016 07:05:00 -0400
Message-ID: <7d9ff1fb-90e3-6055-1560-1cf92e23f084@mojatatu.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
 <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com>
 <CAM_iQpUCqzytG662vBd4D0Zx09CWA9a1VuZerTatMMhdy42jBA@mail.gmail.com>
 <62bb1c25-2967-dedc-89ac-01632d0e090d@mojatatu.com>
 <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35788 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbcHMLMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 07:12:21 -0400
Received: by mail-qk0-f173.google.com with SMTP id v123so8563823qkh.2
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2016 04:12:20 -0700 (PDT)
In-Reply-To: <CAM_iQpXW4Rt4=H89ZdK2BwEmK2FBHownmXEoeAWjBsQW5mLxRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-11 08:08 PM, Cong Wang wrote:
> On Thu, Aug 11, 2016 at 9:20 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-08-10 04:06 PM, Cong Wang wrote:
>>>
>>> On Wed, Aug 10, 2016 at 7:34 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>>> wrote:
>>>>
>>>> On 16-08-08 04:46 PM, Cong Wang wrote:
>>
>>
>>>> tcf_exts_exec() is the culprit - and conversion to from flexarray
>>>> to linked list in the fast problem to be specific.
>>>
>>>
>>> Ah, this reminds me that I don't have to use flex_array, initially
>>> I thought the tcf_exts could hold as many actions as it wants,
>>> but actually there is a upper bound, TCA_ACT_MAX_PRIO.
>>> IOW, a regular dynamic array is just enough here.
>>>
>>
>> Yes, a regular array would be enough.
>>
>>
>>> I just replaced the flex_array with a regular one, it works fine
>>> for me too, at least no crash with all of my test cases.
>>>
>>
>
>> No problem Cong - except we have a kernel that crashes right now.
>> BTW: I just thought of another test which uses a different code
>> path
>> # add a policer rule
>> sudo $TC actions add action police rate 1kbit burst 90k drop
>> #dump rules..
>> sudo $TC -s actions ls action police
>>
>

I tested a lot more this time.
Good news: performance regression now resolved.
Some bad news - there's still one more oops:

sudo $TC actions add action police rate 1kbit burst 90k drop index 1

note how i explicitly specified the index.
If i leave out the index, all works fine. I'll continue to see
if there are any other issue for the next while and will email.
I think you are close so  I will also make small comments on the
patches because you are going to make another update.

cheers,
jamal
