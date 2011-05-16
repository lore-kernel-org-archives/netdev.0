From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 12:48:21 +0300
Message-ID: <20110516094821.GA9427@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl>
 <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au>
 <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au>
 <20110516081841.GA8073@redhat.com>
 <20110516093822.GA2779@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294Ab1EPJsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 05:48:21 -0400
Content-Disposition: inline
In-Reply-To: <20110516093822.GA2779@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 07:38:22PM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 11:18:41AM +0300, Michael S. Tsirkin wrote:
> >
> > There's no interface for userspace to enable it: userspace
> > only has an ioctl to enable/disable checksum offloading.
> > SG is an implementation detail.
> 
> Yes there is: ethtool -K
> 
> Cheers,

Ok. You are right of course, I was confused.

So it's just an info message: in the end if userspace DTRT features
get enabled properly. Functionally, there is no regression.

Both bridge and tun trigger the messages ATM. I note that
dev.c takes pains to avoid these messages:
	Avoid warning from netdev_fix_features() for GSO without SG

Should all drivers do this: clear _SG if they clear checksum?  What about _GSO?
If we start doing this, this spills info about flag dependencies out to drivers.

-- 
MST
