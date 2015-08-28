From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Thu, 27 Aug 2015 18:49:09 -0700
Message-ID: <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
References: <CAM_iQpX4VFeEe4zGj0kx7x7q6GO7Kx+kKC2FW_CRiGSrk0aZVA@mail.gmail.com>
	<20150827.154202.1831965840563413727.davem@davemloft.net>
	<CAM_iQpWscW+F4pnDXwn6uVsyaxVrYmUL6c8YF4wam29Lb4SVvg@mail.gmail.com>
	<20150827.161850.712938458604844308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33872 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbH1BtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 21:49:10 -0400
Received: by obbfr1 with SMTP id fr1so34005476obb.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 18:49:09 -0700 (PDT)
In-Reply-To: <20150827.161850.712938458604844308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 4:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu, 27 Aug 2015 15:47:55 -0700
>
>> On Thu, Aug 27, 2015 at 3:42 PM, David Miller <davem@davemloft.net> wrote:
>>> If you fix it properly, by making every qdisc capable of being ->init()'d
>>> without explicit parameters, it will be the best behavior overall.
>>
>> The problem is ->init() is not even called when setting it as default,
>> since setting a default qdisc doesn't need to create a qdisc. This is
>> why the flag has to be in ops->flags rather than qdisc->flags.
>
> Just sounds like another shortcoming of how default qdiscs are handled,

It has to, due to its definition. I don't see any other way except we change
the meaning of the default qdisc.

> rather than a reason to not fix things properly.

If you mean the crash, my patch can fix it too by simply rejecting the
invalid and buggy case like HTB, even though I do have local patches
to fix it directly.

Like I said, the more important question is not if it crashes, it is if we
should reject invalid case as early as possible or just wait for an error
to happen later.
