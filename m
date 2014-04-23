From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Wed, 23 Apr 2014 07:30:27 -0400
Message-ID: <5357A453.6030901@mojatatu.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>	<534E77D0.8000307@mojatatu.com>	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>	<534FBFF0.3020606@mojatatu.com>	<CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>	<53513619.5060202@mojatatu.com>	<CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>	<535259C3.10404@mojatatu.com> <CAM_iQpVM-djLiz9Z9Bhz9zac88m8b6t1S-SRUkRxYhOaW_xJvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36981 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbaDWLap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 07:30:45 -0400
Received: by mail-ie0-f181.google.com with SMTP id tp5so739770ieb.40
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 04:30:44 -0700 (PDT)
In-Reply-To: <CAM_iQpVM-djLiz9Z9Bhz9zac88m8b6t1S-SRUkRxYhOaW_xJvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/21/14 19:28, Cong Wang wrote:
> On Sat, Apr 19, 2014 at 4:10 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 04/18/14 13:18, Cong Wang wrote:

>> RTNL is one dimension. The other is the datapath processing.
>> You need to make sure that packets still flow correctly during the
>> change over.
>
> Sure, since we grab tcf_tree_lock() before changing actions in
> tcf_exts_change(), I think this is guaranteed too.
>

Maybe - I thought there were recent changes to tcf_tree_lock that
eased the restriction. Youd need to make sure.


>> Well - then go nuts and put out a patch.
>> Replace _all or none_ is a reasonable approach.
>>
>>
>
> Great! We both agree on this.
>
> Looking at the current code, we first initialize a list of actions
> and then replace them as a whole by splicing the lists with
> tcf_tree_lock held, so this is already done. IOW, this patch
> is enough.
>
> Or am I missing anything?
>

I dont see what you are seeing. However, some quick tests will prove it.
Example go from 1->3 actions and backwards 3->1 actions.
I.e create a policy with (handwave) 3 actions and replace it with
another that has only one action. Do this while you are sending a
ping exercising this policy.
I can see how yours with 1->0 and 0->1 will work.

cheers,
jamal
