From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: properly report out of memory errors
Date: Sun, 12 Jun 2016 20:45:11 -0700
Message-ID: <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34787 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933283AbcFMDpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 23:45:36 -0400
Received: by mail-yw0-f196.google.com with SMTP id b75so2606307ywe.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 20:45:31 -0700 (PDT)
In-Reply-To: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> +               struct Qdisc *child;
> +
> +               if (q->queues[i] != &noop_qdisc)
> +                       continue;
> +
> +               child = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
> +                                         TC_H_MAKE(sch->handle, i + 1));
> +               if (!child)
> +                       return -ENOMEM;

Since this is inside a loop, shouldn't we kfree the previous child
creations when we fail?



> +               sch_tree_lock(sch);
> +               q->queues[i] = child;
> +               sch_tree_unlock(sch);
>         }
>         return 0;
>  }
>
>
