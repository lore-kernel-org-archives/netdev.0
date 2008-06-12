From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 17:31:36 -0700 (PDT)
Message-ID: <20080611.173136.28540067.davem@davemloft.net>
References: <20080610.224023.116817726.davem@davemloft.net>
	<20080611104027.GC4171@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35133
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751546AbYFLAbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 20:31:36 -0400
In-Reply-To: <20080611104027.GC4171@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Jun 2008 10:40:27 +0000

> On 11-06-2008 07:40, David Miller wrote:
> ...
> > diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
> > index 0dcfc03..d776bcf 100644
> > --- a/drivers/net/usb/kaweth.c
> > +++ b/drivers/net/usb/kaweth.c
> > @@ -706,7 +706,8 @@ static void kaweth_kill_urbs(struct kaweth_device *kaweth)
> >  	usb_kill_urb(kaweth->rx_urb);
> >  	usb_kill_urb(kaweth->tx_urb);
> >  
> > -	flush_scheduled_work();
> > +	cancel_delayed_work(&kaweth->lowmem_work);
> > +	cancel_work_sync(&kaweth->lowmem_work.work);
> > 
> 
> Why not cancel_delayed_work_sync()?

I simply didn't know it existed :-)  I've updated my patch
to use cancel_delayed_work_sync() as appropriate, thanks!
