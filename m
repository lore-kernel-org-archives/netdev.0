From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 16:55:14 +0200
Message-ID: <200705281655.15105.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705281249.56106.mb@bu3sch.de> <200705281612.15649.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-wireless" <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35987
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbXE1O4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 10:56:13 -0400
In-Reply-To: <200705281612.15649.maxi@daemonizer.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 28 May 2007 16:12:12 Maximilian Engelhardt wrote:
> On Monday 28 May 2007, Michael Buesch wrote:
> > Can you also test the following patch?
> > I think there's a bug in b44 that is doesn't properly discard
> > shared IRQs, so it might possibly generate a NAPI storm, dunno.
> > Worth a try.
> >
> > Index: linux-2.6.22-rc3/drivers/net/b44.c
> > ===================================================================
> > --- linux-2.6.22-rc3.orig/drivers/net/b44.c	2007-05-27 23:01:44.000000000
> > +0200 +++ linux-2.6.22-rc3/drivers/net/b44.c	2007-05-28 12:48:27.000000000
> > +0200 @@ -911,6 +911,8 @@ static irqreturn_t b44_interrupt(int irq
> >  	spin_lock(&bp->lock);
> >
> >  	istat = br32(bp, B44_ISTAT);
> > +	if (istat == 0xFFFFFFFF)
> > +		goto out; /* Shared IRQ not for us */
> >  	imask = br32(bp, B44_IMASK);
> >
> >  	/* The interrupt mask register controls which interrupt bits
> > @@ -942,6 +944,7 @@ irq_ack:
> >  		bw32(bp, B44_ISTAT, istat);
> >  		br32(bp, B44_ISTAT);
> >  	}
> > +out:
> >  	spin_unlock(&bp->lock);
> >  	return IRQ_RETVAL(handled);
> >  }
> 
> I did try this patch on a affected kernel, but I didn't notice any big 
> difference. Perhaps the kernel is a bit less slow during the test, but It's 
> hard to tell.

Ok, but anyway. I think this is a bug and needs to be fixed this way. Gary?

-- 
Greetings Michael.
