From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Fixes slab corruption in cbq_destroy
Date: Thu, 16 Sep 2004 22:33:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916203327.GA27685@postel.suug.ch>
References: <20040916132856.GA27293@postel.suug.ch> <4149998C.6060501@trash.net> <20040916140943.GC27293@postel.suug.ch> <4149AA12.10306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4149AA12.10306@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <4149AA12.10306@trash.net> 2004-09-16 16:58
> Thomas Graf wrote:
> 
> >* Patrick McHardy <4149998C.6060501@trash.net> 2004-09-16 15:47
> > 
> >
> >>I don't see how there can be slab corruption. qdisc_put_rtab only
> >>calls kfree if the table is found in qdisc_rtab_list, which only
> >>happens once. But the patch is still fine as cleanup :)
> >>   
> >>
> >
> >On second call to qdisc_put_rtab with tab pointing to an already
> >freed qdisc_rate_table:
> >
> >sch_api.c:271:  if (!tab || --tab->refcnt)
> > 
> >
> You're right, no double free but accessing and modifying of freed memory.

My patch description was misleading should have been something like
this:

Fixes slab corruption in cbq_destroy. cbq_destroy_filters and
qdisc_put_rtab(q->link.R_tab) are already called in cbq_destroy_class.
The latter lead to a slab corruption due to use of q->link.R_tab after
being freed by previous call to qdisc_put_rtab. Problem introduced
in 1.21.
