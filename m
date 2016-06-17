From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Thu, 16 Jun 2016 19:14:36 -0700
Message-ID: <CAM_iQpVkFvgbYQsVB0hFKa5zVa1KCPAz=cQ7sAXdJwNM=8hpzQ@mail.gmail.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com> <57634687.3050107@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34297 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbcFQCO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 22:14:56 -0400
In-Reply-To: <57634687.3050107@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 5:38 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-06-16 05:43 PM, Cong Wang wrote:
>>
>> On Thu, Jun 16, 2016 at 1:50 PM, Alexey Khoroshilov
>> <khoroshilov@ispras.ru> wrote:
>>>
>>> tcf_ife_init() contains a big chunk of code executed with
>>> ife->tcf_lock spinlock held. But that code contains several calls
>>> to sleeping functions:
>>>    populate_metalist() and use_all_metadata()
>>>      -> add_metainfo()
>>>        -> find_ife_oplist(metaid)
>>>          -> read_lock()
>>>          -> try_module_get(o->owner)
>>>        -> kzalloc(sizeof(*mi), GFP_KERNEL);
>>
>>
>> Hmm, we don't need to hold that spinlock when we create a new ife action,
>> since we haven't inserted it yet. We do need it when we modify an existing
>> one. So I am thinking if we can refactor that code to avoid spinlock
>> whenever possible.
>>
>
> Does attached (compile tested) patch help?

You at least miss the unlock in load_metaops_and_vet()?

I think we can just remove that tcf_lock, I am testing a patch now.
