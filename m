From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 12:18:53 +0100
Message-ID: <20041231111853.GE32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <41D4A4D2.4000109@trash.net> <1104469362.1049.224.camel@jzny.localdomain> <41D52176.80703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41D52176.80703@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41D52176.80703@trash.net> 2004-12-31 10:52
> jamal wrote:
> >On Thu, 2004-12-30 at 20:01, Patrick McHardy wrote:
> >
> >>This isn't right (its also wrong in the current code). If the
> >>CPU reorders stores and another CPU looks at dst->action at
> >>the wrong time it might see an inconsistent structure. 
> >
> >
> >I think an xchg around the else should fix this.

Agreed, we do have a problem when changing a existing filter and adding
a action/police. Thanks Patrick.

> >>I also wonder if anyone
> >>actually knows why we need the xchg (here and in all the other
> >>places), it looks totally useless.
> >
> >All these were put in by Alexey and the LinuxWay(tm) took effect.
> >an xchg puts almost a lock and ensures an atomic swap. I dont see any
> >harm in leaving it as is - just needs fixing the else
> 
> No real harm, but it still should be removed IMO, or used _instead_
> of tcf_tree_lock in this place. I've asked myself multiple times what
> it is meant for and I've seen others do the same, this alone justifies
> removing it. Another reason is what you call LinuxWay(tm), strange
> things spread on their own and at some time you have to touch lots of
> files to get rid them. So its best to do it as early as possible.

There are many of those spread all around. Alexey used them right and
now some have been surrounded by locks. I wanted to fix this since ages
but didn't get around yet. I'll remove the tcf lock in my patch and
change the other occurances later.
