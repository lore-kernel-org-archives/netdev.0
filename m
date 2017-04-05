From: Mike Galbraith <efault@gmx.de>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Wed, 05 Apr 2017 07:56:30 +0200
Message-ID: <1491371790.4536.151.camel@gmx.de>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
         <1491364545.4536.90.camel@gmx.de>
         <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:64326 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752346AbdDEF4d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 01:56:33 -0400
In-Reply-To: <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 22:19 -0700, Cong Wang wrote:
> On Tue, Apr 4, 2017 at 8:55 PM, Mike Galbraith <efault@gmx.de> wrote:

> > That won't help, cond_resched() has the same impact upon a lone
> > SCHED_FIFO task as yield() does.. none.
> 
> Hmm? In the comment you quote:
> 
>  * If you want to use yield() to wait for something, use wait_event().
>  * If you want to use yield() to be 'nice' for others, use cond_resched().
> 
> So if cond_resched() doesn't help, why this misleading comment?

This is not an oh let's be nice guys thing, it's a perfect match of...

<copy/paste>
 * while (!event)
 *      yield();
(/copy/paste>

..get off the CPU until this happens thing.  With nobody to yield the C
PU to, some_qdisc_is_busy() will remain true forever more.

> I picked the latter one, because the former is harder to implement
> properly (at least for -net) we need qdisc's to notify this waiter once
> they finish transmitting packets, which means we probably need
> a per-netdevice wait struct.

Yup, why I merely notified net-fu masters of lurking spinner.  I met it
 because I sometimes run most kthreads at prio 1, some prioritized, and
kworkers at prio 2.  (never mind why, but they're excellent reasons)

	-Mike
