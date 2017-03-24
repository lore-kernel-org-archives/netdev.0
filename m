From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next] net: sched: choke: remove dead filter classify code
Date: Fri, 24 Mar 2017 10:59:15 -0700
Message-ID: <CAM_iQpXTM9X75RXj6mvTYatL0=TjFyYmFaKLeQBv74zZVFUs6g@mail.gmail.com>
References: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:33993 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933963AbdCXR7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:59:47 -0400
Received: by mail-wr0-f180.google.com with SMTP id l43so6606363wre.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:59:36 -0700 (PDT)
In-Reply-To: <1490284936-19412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 9:02 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> sch_choke is classless qdisc so it does not define cl_ops. Therefore
> filter_list cannot be ever changed, being NULL all the time.
> Reason is this check in tc_ctl_tfilter:

Are you sure? According to the definition in comments:

   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
   unresponsive flows) is a variant of RED that penalizes misbehaving flows but
   maintains no flow state. The difference from RED is an additional step
   during the enqueuing process. If average queue size is over the
   low threshold (qmin), a packet is chosen at random from the queue.
   If both the new and chosen packet are from the same flow, both
   are dropped. Unlike RED, CHOKe is not really a "classful" qdisc because it
   needs to access packets in queue randomly. It has a minimal class
   interface to allow overriding the builtin flow classifier with
   filters.

It should implement filters otherwise how to classify flows in
its definition?
