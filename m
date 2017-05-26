From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Fri, 26 May 2017 10:54:43 -0400 (EDT)
Message-ID: <20170526.105443.1489276661727770629.davem@davemloft.net>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
        <20170525.121456.221336477222052018.davem@davemloft.net>
        <20170526055352.GA1898@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035659AbdEZOyp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:54:45 -0400
In-Reply-To: <20170526055352.GA1898@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 May 2017 07:53:52 +0200

> Thu, May 25, 2017 at 06:14:56PM CEST, davem@davemloft.net wrote:
>>From: Cong Wang <xiyou.wangcong@gmail.com>
>>Date: Tue, 23 May 2017 09:42:37 -0700
>>
>>> tcf_chain_get() always creates a new filter chain if not found
>>> in existing ones. This is totally unnecessary when we get or
>>> delete filters, new chain should be only created for new filters
>>> (or new actions).
>>> 
>>> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>>> Cc: Jiri Pirko <jiri@mellanox.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
>>Indeed, get and delete requests should not create new objects, ever.
>>
>>I have pretty much no idea why Jiri is making such a big fuss about
>>this change, to be quite honest. :-)
> 
> Because it makes already hard to read code even worse, for *no* benefit.
> That's why.

Jiri, if you say the same thing 100 times, it doesn't help anyone
understand your arguments any better.

Creating new objects when a GET or a DEL is requested is flat out
wrong.

And Cong is fixing that.

And I also didn't find the boolean logic hard to understand at all.

It is in fact a very common pattern to pass a "create" boolean into
lookup functions, to tell them whether to create a new object on
lookup failure or not.  And then also to control that boolean via
what kind of netlink request we are processing.

So you tell me what's so bad about his change given the above?

Give me details and real facts, like I just did, rather than vague
statements about "benefit" and "hard to read".

Thank you.
