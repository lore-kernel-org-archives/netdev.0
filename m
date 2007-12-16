From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Badness at net/core/dev.c:2199
Date: Sun, 16 Dec 2007 21:46:37 +0300
Message-ID: <20071216184637.GA20871@2ka.mipt.ru>
References: <Pine.SOC.4.64.0712161952130.27147@math.ut.ee> <20071216182057.GB31380@2ka.mipt.ru> <20071216103340.07479359@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52445 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102AbXLPSrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 13:47:03 -0500
Content-Disposition: inline
In-Reply-To: <20071216103340.07479359@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 10:33:40AM -0800, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> > index 3653314..9e0e97a 100644
> > --- a/drivers/net/tulip/interrupt.c
> > +++ b/drivers/net/tulip/interrupt.c
> > @@ -151,8 +151,9 @@ int tulip_poll(struct napi_struct *napi, int budget)
> >                         if (tulip_debug > 5)
> >                                 printk(KERN_DEBUG "%s: In tulip_rx(), entry %d %8.8x.\n",
> >                                        dev->name, entry, status);
> > -		       if (work_done++ >= budget)
> > +		       if (work_done >= budget)
> >                                 goto not_done;
> > +		       work_done++;
> >  
> >                         if ((status & 0x38008300) != 0x0300) {
> >                                 if ((status & 0x38000300) != 0x0300) {
> > 
> > 
> 
> I already sendout a correct patch last week. It should pre-increment.

That will work too.
Thanks Stephen.

-- 
	Evgeniy Polyakov
