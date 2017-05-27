From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Sat, 27 May 2017 12:02:30 +0200
Message-ID: <20170527100230.GB1831@nanopsycho>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170525.121456.221336477222052018.davem@davemloft.net>
 <20170526055352.GA1898@nanopsycho>
 <20170526.105443.1489276661727770629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36439 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdE0KCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 06:02:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id k15so7645643wmh.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 03:02:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170526.105443.1489276661727770629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 26, 2017 at 04:54:43PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 26 May 2017 07:53:52 +0200
>
>> Thu, May 25, 2017 at 06:14:56PM CEST, davem@davemloft.net wrote:
>>>From: Cong Wang <xiyou.wangcong@gmail.com>
>>>Date: Tue, 23 May 2017 09:42:37 -0700
>>>
>>>> tcf_chain_get() always creates a new filter chain if not found
>>>> in existing ones. This is totally unnecessary when we get or
>>>> delete filters, new chain should be only created for new filters
>>>> (or new actions).
>>>> 
>>>> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>>>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>>>> Cc: Jiri Pirko <jiri@mellanox.com>
>>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>>
>>>Indeed, get and delete requests should not create new objects, ever.
>>>
>>>I have pretty much no idea why Jiri is making such a big fuss about
>>>this change, to be quite honest. :-)
>> 
>> Because it makes already hard to read code even worse, for *no* benefit.
>> That's why.
>
>Jiri, if you say the same thing 100 times, it doesn't help anyone
>understand your arguments any better.
>
>Creating new objects when a GET or a DEL is requested is flat out
>wrong.
 
Allright. I ack that.


>
>And Cong is fixing that.
>
>And I also didn't find the boolean logic hard to understand at all.
>
>It is in fact a very common pattern to pass a "create" boolean into
>lookup functions, to tell them whether to create a new object on
>lookup failure or not.  And then also to control that boolean via
>what kind of netlink request we are processing.
>
>So you tell me what's so bad about his change given the above?
>
>Give me details and real facts, like I just did, rather than vague
>statements about "benefit" and "hard to read".

What I don't like is the double "n->nlmsg_type == RTM_NEWTFILTER" check
and return value decusion according to the latter check. The code logic
is split into tcf_chain_get function and its caller. That is
at least odd.

Since you don't like the PTR_ERR approach, I'll try to figure out how to
do this another way.
