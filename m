From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Fri, 2 Dec 2011 15:22:28 +0400
Message-ID: <20111202112228.GB3433@tugrik.mns.mnsspb.ru>
References: <20111129.124715.163094087536706067.davem@davemloft.net> <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com> <20111201165018.GA19451@tugrik.mns.mnsspb.ru> <20111201.130045.2061330448127491799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:45971 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753795Ab1LBLYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 06:24:38 -0500
Content-Disposition: inline
In-Reply-To: <20111201.130045.2061330448127491799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2011 at 01:00:45PM -0500, David Miller wrote:
> From: Kirill Smelkov <kirr@mns.spb.ru>
> Date: Thu, 1 Dec 2011 20:50:18 +0400
> 
> > One "regression" is it is now not possible to disable BQL at compile time,
> > because CONFIG_BQL can't be set to "n" via usual ways.
> > 
> > Description and patch below. Thanks.
> 
> It's intentional, and your patch will not be applied.
> 
> The Kconfig entry and option is merely for expressing internal dependencies,
> not for providing a way to disable the code.

I'm maybe wrong somewhere - sorry then, but why there is e.g.

     static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
                                            unsigned int bytes)
     {
    +#ifdef CONFIG_BQL
    +       dql_queued(&dev_queue->dql, bytes);
    +       if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
    +               set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
    +               if (unlikely(dql_avail(&dev_queue->dql) >= 0))
    +                       clear_bit(__QUEUE_STATE_STACK_XOFF,
    +                           &dev_queue->state);
    +       }
    +#endif
     }


and that netdev_tx_sent_queue() is called on every xmit.

I wanted to save cycles on my small/slow hardware and compile BQL out in
case I know the system is not going to use it. I'm netdev newcomer, so
sorry if I ask naive questions, but what's wrong it?


Thanks,
Kirill
