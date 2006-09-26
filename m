From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Tue, 26 Sep 2006 20:36:21 +0200
Message-ID: <20060926183621.GX18349@postel.suug.ch>
References: <20060926115910.GV18349@postel.suug.ch> <45192BD4.9030702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4536 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750701AbWIZSgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 14:36:02 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45192BD4.9030702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-09-26 15:32
> Thomas Graf wrote:
> > Prevents filters from being added if the first generated
> > handle already exists.
> > 
> > Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > Index: net-2.6/net/sched/cls_basic.c
> > ===================================================================
> > --- net-2.6.orig/net/sched/cls_basic.c	2006-09-26 13:35:29.000000000 +0200
> > +++ net-2.6/net/sched/cls_basic.c	2006-09-26 13:35:39.000000000 +0200
> > @@ -194,7 +194,7 @@
> >  	if (handle)
> >  		f->handle = handle;
> >  	else {
> > -		int i = 0x80000000;
> > +		unsigned int i = 0x80000000;
> 
> I don't see how this patch changes anything, the loop already
> ends when i == 0 (and it can't go negative):
> 
>         do {
>                 if (++head->hgenerator == 0x7FFFFFFF)
>                         head->hgenerator = 1;
>         } while (--i > 0 && basic_get(tp, head->hgenerator));
> 
> which should also make sure that no handle gets used twice:
> 
>         if (i <= 0) {
>                 printk(KERN_ERR "Insufficient number of handles\n");
>                 goto errout;
>         }

You're right, 0x80000000 - 1 is already positive. Ignore the patch.
