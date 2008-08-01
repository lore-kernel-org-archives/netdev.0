From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 1 Aug 2008 07:01:50 +0000
Message-ID: <20080801070150.GB4435@ff.dom.local>
References: <20080726131838.GA2873@ami.dom.local> <20080726.173434.48036095.davem@davemloft.net> <20080727203757.GA2527@ami.dom.local> <20080731.052932.110299354.davem@davemloft.net> <20080801064810.GA4435@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@axxeo.de, peterz@infradead.org,
	Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:61074 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbYHAG4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:56:33 -0400
Received: by nf-out-0910.google.com with SMTP id d3so377899nfc.21
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2008 23:56:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080801064810.GA4435@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 06:48:10AM +0000, Jarek Poplawski wrote:
> On Thu, Jul 31, 2008 at 05:29:32AM -0700, David Miller wrote:
...
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 63d6bcd..69320a5 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
> >  {
> >  	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
> >  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> > +	spin_lock_init(&dev->tx_global_lock);
> 
> This will probably need some lockdep annotations similar to
> _xmit_lock.

...BTW, we probably could also consider some optimization here: the
xmit_lock of the first queue could be treated as special, and only
the owner could do such a freezing. This would save changes of
functionality to non mq devices. On the other hand, it would need
remembering about this special treatment (so, eg. a separate lockdep
initialization than all the others).

Jarek P.
