From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Fri, 28 Aug 2015 14:39:45 -0700
Message-ID: <CAM_iQpVqgFMoKE8JGpHw3e+YTqRoVYADoKBprFaaV-Es=uDKdQ@mail.gmail.com>
References: <CAM_iQpWscW+F4pnDXwn6uVsyaxVrYmUL6c8YF4wam29Lb4SVvg@mail.gmail.com>
	<20150827.161850.712938458604844308.davem@davemloft.net>
	<CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
	<20150827.212359.1624170801280596846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35144 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbbH1Vjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 17:39:45 -0400
Received: by oigk185 with SMTP id k185so31909202oig.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 14:39:45 -0700 (PDT)
In-Reply-To: <20150827.212359.1624170801280596846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 9:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu, 27 Aug 2015 18:49:09 -0700
>
>> On Thu, Aug 27, 2015 at 4:18 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Cong Wang <xiyou.wangcong@gmail.com>
>>> Date: Thu, 27 Aug 2015 15:47:55 -0700
>>>
>>>> On Thu, Aug 27, 2015 at 3:42 PM, David Miller <davem@davemloft.net> wrote:
>>>>> If you fix it properly, by making every qdisc capable of being ->init()'d
>>>>> without explicit parameters, it will be the best behavior overall.
>>>>
>>>> The problem is ->init() is not even called when setting it as default,
>>>> since setting a default qdisc doesn't need to create a qdisc. This is
>>>> why the flag has to be in ops->flags rather than qdisc->flags.
>>>
>>> Just sounds like another shortcoming of how default qdiscs are handled,
>>
>> It has to, due to its definition. I don't see any other way except we change
>> the meaning of the default qdisc.
>
> We are talking past eachother.
>
> If a default qdisc like HTB is choosen, we invoke the ->init() function
> and we change the HTB ->init() function to do something reasonable
> if a NULL set of configuration attributes is given.  ie. make HTB use
> some defaults.
>
> Please explain to me why this won't fix the problem.

It does, and it is exactly what my local patch does.

The problem is setting HTB as default is already invalid from the
beginning, so HTB->init() is not supposed be called since we can
reject it earlier, and this is my whole point.

If HTB is not a good example, as using HTB as default might
make some sense, please try ingress qdisc, no error at _any_ time,
and apparently defaulting to ingress is totally non-sense.
