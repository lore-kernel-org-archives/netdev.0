From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix refcnt when GETing of
 action after bind
Date: Sun, 22 Jan 2017 07:56:20 -0500
Message-ID: <d361fc0a-96e9-0ebb-54cb-596ff5832036@mojatatu.com>
References: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpURppLMupbxCSqmZe866APGrcYficzaOTFNyzheQrrePg@mail.gmail.com>
 <7a55a129-1e96-80f7-373d-1ff6a95b5269@mojatatu.com>
 <CAM_iQpXZqgcSbK2A0_RYmZxmawNgM9RtUsA2Bf0Jf91meu2SWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36638 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdAVM5H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 07:57:07 -0500
Received: by mail-qt0-f193.google.com with SMTP id l7so11336830qtd.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 04:56:22 -0800 (PST)
In-Reply-To: <CAM_iQpXZqgcSbK2A0_RYmZxmawNgM9RtUsA2Bf0Jf91meu2SWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-20 01:20 AM, Cong Wang wrote:
> On Wed, Jan 18, 2017 at 3:33 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 17-01-17 01:17 PM, Cong Wang wrote:
>>>

>> I did.
>> The issue there (after your original patch) was destroy() would
>> decrement the refcount to zero and a GET was essentially translated
>> to a DEL. Incrementing the refcount earlier protected against that
>> assuming destroy was going to decrement it.
>> However, when an action is bound the destroy() doesnt decrement
>> the refcnt. So the refcnt keeps going up forever (and therefore
>> deleting fails in the future). So we cant use destroy() as is.
>
> Hmm, tcf_action_destroy() should not touch the refcnt at all in this case,
> right? Since the refcnt here is not for readers in kernel code but for
> user-space. We mix the use of this refcnt, which leads to problems.
>
> Your patch is not correct either for DEL, tcf_action_destroy() is not
> needed to call again after tcf_del_notify() fails, right? Probably
> it is not needed at all:

Cong,
Please proceed to separate del from get. The trickery is biting us.
Also - run those tests i had in my patch. There is a difference
between the bound vs not-bound use cases.

cheers,
jamal
