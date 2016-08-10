From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 0/5] net_sched: tc action fixes and updates
Date: Wed, 10 Aug 2016 13:06:30 -0700
Message-ID: <CAM_iQpUCqzytG662vBd4D0Zx09CWA9a1VuZerTatMMhdy42jBA@mail.gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com> <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33503 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935183AbcHJUGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 16:06:52 -0400
Received: by mail-io0-f173.google.com with SMTP id 38so52123470iol.0
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 13:06:51 -0700 (PDT)
In-Reply-To: <a79fc4fd-69aa-0af6-bb2d-7729610f97e4@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 7:34 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-08-08 04:46 PM, Cong Wang wrote:
>>
>> This patchset fixes several regressions caused by the previous
>> code refactor. Thanks to Jamal for catching them!
>>
>
> Cong,
>
> Good news: oops gone. I havent done more testing than I did
> before; but looks good so far.
>
> Bad news: You have introduced a performance regression which is
> noticeable at high speed.
>
> tcf_exts_exec() is the culprit - and conversion to from flexarray
> to linked list in the fast problem to be specific.

Ah, this reminds me that I don't have to use flex_array, initially
I thought the tcf_exts could hold as many actions as it wants,
but actually there is a upper bound, TCA_ACT_MAX_PRIO.
IOW, a regular dynamic array is just enough here.

I just replaced the flex_array with a regular one, it works fine
for me too, at least no crash with all of my test cases.

Please try v2, since you have more test cases that I do.
Or it would be great if you can share your test cases with
me or us.

Be patient, every big change could have regression. :)

Thanks.
