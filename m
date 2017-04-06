From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Thu, 6 Apr 2017 18:13:55 -0400
Message-ID: <20170406181355.7fc4353a@plumbers-lap.home.lan>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
        <1491364545.4536.90.camel@gmx.de>
        <CAM_iQpXpZjpS1ZG7hH-52jt41FzzyMZ0rss9PauaSD54XSQiXQ@mail.gmail.com>
        <1491371790.4536.151.camel@gmx.de>
        <CAM_iQpUa-w9k4EFafQCEpbmR0PANwkLieYMxGwi59373h8jHUg@mail.gmail.com>
        <1491443659.4718.57.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36392 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751557AbdDFWOA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 18:14:00 -0400
Received: by mail-io0-f171.google.com with SMTP id l7so39103674ioe.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 15:14:00 -0700 (PDT)
In-Reply-To: <1491443659.4718.57.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Apr 2017 03:54:19 +0200
Mike Galbraith <efault@gmx.de> wrote:

> On Wed, 2017-04-05 at 16:42 -0700, Cong Wang wrote:
> > On Tue, Apr 4, 2017 at 10:56 PM, Mike Galbraith <efault@gmx.de> wrote:  
> > > On Tue, 2017-04-04 at 22:19 -0700, Cong Wang wrote:  
> > > > On Tue, Apr 4, 2017 at 8:55 PM, Mike Galbraith <efault@gmx.de> wrote:  
> > >   
> > > > > That won't help, cond_resched() has the same impact upon a lone
> > > > > SCHED_FIFO task as yield() does.. none.  
> > > > 
> > > > Hmm? In the comment you quote:
> > > > 
> > > >  * If you want to use yield() to wait for something, use wait_event().
> > > >  * If you want to use yield() to be 'nice' for others, use cond_resched().
> > > > 
> > > > So if cond_resched() doesn't help, why this misleading comment?  
> > > 
> > > This is not an oh let's be nice guys thing, it's a perfect match of...
> > > 
> > > 
> > >  * while (!event)
> > >  *      yield();  
> > > (/copy/paste>  
> > > 
> > > ..get off the CPU until this happens thing.  With nobody to yield the C
> > > PU to, some_qdisc_is_busy() will remain true forever more.  
> > 
> > 
> > This is exactly the misleading part, a while-loop waiting for an event
> > can always be a be-nice-for-others thing, because if not we can just
> > spin as a spinlock.  
> 
> Ah, but the kworker _is_ spinning on a 'lock' or sorts, starving the
> 'owner', ergo this polling loop fails the 'may be nice' litmus test. 
>  No polling loop is safe without a guarantee that the polling thread
> cannot block the loop breaking event.
> 
> 	-Mike

Why not replace yield with msleep(1) which gets rid of the inversion
issues?
