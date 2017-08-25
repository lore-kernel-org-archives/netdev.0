From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2 3/4] net_sched: remove tc class reference
 counting
Date: Fri, 25 Aug 2017 11:36:45 +0200
Message-ID: <20170825093645.GD2023@nanopsycho>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-4-xiyou.wangcong@gmail.com>
 <20170825090021.GA4829@nanopsycho>
 <20170825091850.GI15739@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38685 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754864AbdHYJgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 05:36:48 -0400
Received: by mail-wm0-f47.google.com with SMTP id z132so8124683wmg.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 02:36:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170825091850.GI15739@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 25, 2017 at 11:18:50AM CEST, fw@strlen.de wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>> Fri, Aug 25, 2017 at 01:51:29AM CEST, xiyou.wangcong@gmail.com wrote:
>> >For TC classes, their ->get() and ->put() are always paired, and the
>> >reference counting is completely useless, because:
>> >
>> >1) For class modification and dumping paths, we already hold RTNL lock,
>> >   so all of these ->get(),->change(),->put() are atomic.
>> 
>> There is ongoing initiative by Florian to avoid taking RTNL for some
>> rtnetlink calls. I think that for dumping it could be done in tc as well.
>> Don't we need the refcnt then?
>
>Dumping is a problem at this time because several places depend on RTNL
>to ensure we get a consistent state, even "simple" functions like
>rtnl_fill_ifinfo, see e.g.  2907c35ff64708065e5a7fd54e8ded8263eb3074
>(net: hold rtnl again in dump callbacks).
>
>So for these places we already need some other way (e.g. seqlock)
>to ensure we don't put garbage in netlink skb.
>
>At this time I think that it is better if Congs patches go in
>(Unless there are other problems of course) as they simplify
>things quite a bit, and I am not sure that we need refcount.
>
>It might be enough to use rcu and detect when the class we just read
>from might have been in inconsistent state (so we can retry).
>
>Does that make sense to you?

It does. Thanks!
