From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc
 to inappropriate ones
Date: Thu, 27 Aug 2015 21:23:59 -0700 (PDT)
Message-ID: <20150827.212359.1624170801280596846.davem@davemloft.net>
References: <CAM_iQpWscW+F4pnDXwn6uVsyaxVrYmUL6c8YF4wam29Lb4SVvg@mail.gmail.com>
	<20150827.161850.712938458604844308.davem@davemloft.net>
	<CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbbH1EYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 00:24:01 -0400
In-Reply-To: <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 27 Aug 2015 18:49:09 -0700

> On Thu, Aug 27, 2015 at 4:18 PM, David Miller <davem@davemloft.net> wrote:
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>> Date: Thu, 27 Aug 2015 15:47:55 -0700
>>
>>> On Thu, Aug 27, 2015 at 3:42 PM, David Miller <davem@davemloft.net> wrote:
>>>> If you fix it properly, by making every qdisc capable of being ->init()'d
>>>> without explicit parameters, it will be the best behavior overall.
>>>
>>> The problem is ->init() is not even called when setting it as default,
>>> since setting a default qdisc doesn't need to create a qdisc. This is
>>> why the flag has to be in ops->flags rather than qdisc->flags.
>>
>> Just sounds like another shortcoming of how default qdiscs are handled,
> 
> It has to, due to its definition. I don't see any other way except we change
> the meaning of the default qdisc.

We are talking past eachother.

If a default qdisc like HTB is choosen, we invoke the ->init() function
and we change the HTB ->init() function to do something reasonable
if a NULL set of configuration attributes is given.  ie. make HTB use
some defaults.

Please explain to me why this won't fix the problem.
