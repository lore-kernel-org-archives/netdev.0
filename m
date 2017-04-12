From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] net: allow configuring default qdisc
Date: Wed, 12 Apr 2017 15:59:25 -0700
Message-ID: <20170412155925.4bd3ed5e@xeon-e3>
References: <20170408193946.18469-1-sthemmin@microsoft.com>
        <20170411.220959.313852914647879245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33704 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755387AbdDLW72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 18:59:28 -0400
Received: by mail-pf0-f169.google.com with SMTP id s16so20125944pfs.0
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 15:59:28 -0700 (PDT)
In-Reply-To: <20170411.220959.313852914647879245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Apr 2017 22:09:59 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat,  8 Apr 2017 15:39:46 -0400
> 
> > Since 3.12 it has been possible to configure the default queuing
> > discipline via sysctl. This patch adds ability to configure the
> > default queue discipline in kernel configuration. This is useful for
> > environments where configuring the value from userspace is difficult
> > to manage.
> > 
> > The default is still the same as before (pfifo_fast) and it is
> > possible to change after kernel init with sysctl. This is similar
> > to how TCP congestion control works.
> > 
> > Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> > ---
> > v2 - rearrange order of menu items
> >      use pfifo_fast not pfifo  
> 
> Stephen I'm still thinking about this.
> 
> Normal users typing "make oldconfig" shouldn't be asked a question
> like this.  They have no idea.  This is just like how we hide all the
> advanced ipv4 routing choices behind the Kconfig symbol
> IP_ADVANCED_ROUTER and TCP congestion control with TCP_CONG_ADVANCED.
> 
> And from experience I know that if it shows up when Linus types 'make'
> after pulling this in, he will complain :-)


I understand your concern about less clueful users not knowing what
to answer. But there have been many recent cases where things have
been added with the adage "just hit return and take the default".

The most recent example was in the block layer.

commit d34849913819a5e0cbfbe724dbe79df89278c524
Author: Jens Axboe <axboe@fb.com>
Date:   Fri Jan 13 14:43:58 2017 -0700

    blk-mq-sched: allow setting of default IO scheduler
    
    Add Kconfig entries to manage what devices get assigned an MQ
    scheduler, and add a blk-mq flag for drivers to opt out of scheduling.
    The latter is useful for admin type queues that still allocate a blk-mq
    queue and tag set, but aren't use for normal IO.
    
    Signed-off-by: Jens Axboe <axboe@fb.com>
    Reviewed-by: Bart Van Assche <bart.vanassche@sandisk.com>
    Reviewed-by: Omar Sandoval <osandov@fb.com>

Maybe Linus understands IO better than networking :=)
