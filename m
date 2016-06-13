From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: properly report out of memory
 errors
Date: Sun, 12 Jun 2016 21:29:17 -0700
Message-ID: <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34803 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964854AbcFME3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 00:29:21 -0400
Received: by mail-io0-f194.google.com with SMTP id d2so8314884iof.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 21:29:20 -0700 (PDT)
In-Reply-To: <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-12 at 20:45 -0700, Cong Wang wrote:
> On Sun, Jun 12, 2016 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +               struct Qdisc *child;
> > +
> > +               if (q->queues[i] != &noop_qdisc)
> > +                       continue;
> > +
> > +               child = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
> > +                                         TC_H_MAKE(sch->handle, i + 1));
> > +               if (!child)
> > +                       return -ENOMEM;
> 
> Since this is inside a loop, shouldn't we kfree the previous child
> creations when we fail?

You're right.

prio_init() needs to do the cleanup, as prio_destroy() wont be called
from qdisc_create()

I am testing a fix with fault injection.

Thanks.
