From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: choke: remove dead filter
 classify code
Date: Fri, 24 Mar 2017 12:46:38 -0700 (PDT)
Message-ID: <20170324.124638.1229066743314753196.davem@davemloft.net>
References: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
        <CAM_iQpXTM9X75RXj6mvTYatL0=TjFyYmFaKLeQBv74zZVFUs6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com,
        mlxsw@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966477AbdCXTqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:46:39 -0400
In-Reply-To: <CAM_iQpXTM9X75RXj6mvTYatL0=TjFyYmFaKLeQBv74zZVFUs6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 24 Mar 2017 10:59:15 -0700

> On Thu, Mar 23, 2017 at 9:02 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> sch_choke is classless qdisc so it does not define cl_ops. Therefore
>> filter_list cannot be ever changed, being NULL all the time.
>> Reason is this check in tc_ctl_tfilter:
> 
> Are you sure? According to the definition in comments:
> 
>    CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
>    unresponsive flows) is a variant of RED that penalizes misbehaving flows but
>    maintains no flow state. The difference from RED is an additional step
>    during the enqueuing process. If average queue size is over the
>    low threshold (qmin), a packet is chosen at random from the queue.
>    If both the new and chosen packet are from the same flow, both
>    are dropped. Unlike RED, CHOKe is not really a "classful" qdisc because it
>    needs to access packets in queue randomly. It has a minimal class
>    interface to allow overriding the builtin flow classifier with
>    filters.
> 
> It should implement filters otherwise how to classify flows in
> its definition?

The flows are matched by hand using the flow dissector.

Jiri is right, this is all dead code and should be removed.
