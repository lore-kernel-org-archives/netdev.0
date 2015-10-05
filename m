From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] act_mirred: fix a race condition on mirred_list
Date: Mon, 5 Oct 2015 08:07:28 -0400
Message-ID: <56126800.2030600@mojatatu.com>
References: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
 <561265EC.6050906@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36543 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbJEMHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 08:07:31 -0400
Received: by igcrk20 with SMTP id rk20so58820854igc.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 05:07:31 -0700 (PDT)
In-Reply-To: <561265EC.6050906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Never mind. Mirred is speacial because it points to other netdevs.
So:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Thanks Cong.

cheers,
jamal

On 10/05/15 07:58, Jamal Hadi Salim wrote:
> Hi Cong,
>
> I am wondering if making the bindcount or refcount atomic would help?
> How does this bug get created? i.e the RTNL is still around.
> Why is this specific to mirred only?
>
> cheers,
> jamal
>
>
> On 10/01/15 14:37, Cong Wang wrote:
>> After commit 1ce87720d456 ("net: sched: make cls_u32 lockless")
>> we began to release tc actions in a RCU callback. However,
>> mirred action relies on RTNL lock to protect the global
>> mirred_list, therefore we could have a race condition
>> between RCU callback and netdevice event, which caused
>> a list corruption as reported by Vinson.
>>
>> Instead of relying on RTNL lock, introduce a spinlock to
>> protect this list.
>>
>> Note, in non-bind case, it is still called with RTNL lock,
>> therefore should disable BH too.
>>
