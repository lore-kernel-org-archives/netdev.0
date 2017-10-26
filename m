From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Thu, 26 Oct 2017 12:10:14 -0700
Message-ID: <CAM_iQpVJXAvGmf_xFJnL_fTFDyqAXJg95_MwOwv4NyMNEvokHw@mail.gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
 <20171025.104353.1317026584880877750.davem@davemloft.net> <CAM_iQpVLHLx9eVgO0S--iq-XkhZE82Y30Z0REwU6qx8OGgm+mA@mail.gmail.com>
 <20171026001916.GU3659@linux.vnet.ibm.com> <CAM_iQpXQAeXeVtUNBTsF6VxR6OiGFbQgXiRFzrRrTQ72_6fxCA@mail.gmail.com>
 <20171026135812.GY3659@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45217 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751984AbdJZTKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 15:10:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id d28so3186981pfe.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 12:10:36 -0700 (PDT)
In-Reply-To: <20171026135812.GY3659@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 6:58 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> So when removing an entire chain, you flush any queued workqueue handlers
> to make sure that any operations using elements on that chain have also
> completed, correct?  This might also motivate the rcu_barrier() calls.

Yes, we can only free it after all pending RCU callbacks and works finish,
because they are in the same chain and we are freeing the head of the
chain in tcf_block_put().

>
> Seems to me that your proposed patch is at least worth a try, then.
>

Thank you! Then it makes some basic sense. I did a quick test and
don't see any crash or lockdep warning.
