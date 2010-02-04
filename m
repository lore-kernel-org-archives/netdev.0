From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] Net / pktgen: Fix freezing problem
Date: Thu, 4 Feb 2010 23:19:22 +0100
Message-ID: <201002042319.22226.rjw@sisk.pl>
References: <201002042250.58944.rjw@sisk.pl> <20100204141239.aa94e75c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ciprian Dorin Craciun <ciprian.craciun@gmail.com>,
	Greg KH <gregkh@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:46177 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757441Ab0BDWSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 17:18:34 -0500
In-Reply-To: <20100204141239.aa94e75c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 February 2010, Andrew Morton wrote:
> On Thu, 4 Feb 2010 22:50:58 +0100 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> > Subject: Net / pktgen: Fix freezing problem
> > 
> > Add missing try_to_freeze() to one of the pktgen_thread_worker() code
> > paths so that it doesn't block suspend/hibernation.
> > 
> > Fixes http://bugzilla.kernel.org/show_bug.cgi?id=15006
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > Reported-and-tested-by: Ciprian Dorin Craciun <ciprian.craciun@gmail.com>
> > ---
> >  net/core/pktgen.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > Index: linux-2.6/net/core/pktgen.c
> > ===================================================================
> > --- linux-2.6.orig/net/core/pktgen.c
> > +++ linux-2.6/net/core/pktgen.c
> > @@ -3524,6 +3524,7 @@ static int pktgen_thread_worker(void *ar
> >  			wait_event_interruptible_timeout(t->queue,
> >  							 t->control != 0,
> >  							 HZ/10);
> > +			try_to_freeze();
> >  			continue;
> >  		}
> >  
> 
> Also needed in -stable, IMO.

Indeed.
