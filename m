From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 11:18:41 +0300
Message-ID: <20110516081841.GA8073@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl>
 <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au>
 <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404Ab1EPISm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 04:18:42 -0400
Content-Disposition: inline
In-Reply-To: <20110516080702.GA1857@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 06:07:02PM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 10:32:10AM +0300, Michael S. Tsirkin wrote:
> >
> > So how is NETIF_F_SG supposed to be enabled then?
> 
> It should either be enabled at device creation time, or whatever
> user-space entity managing the device creation should enable it
> along with checksumming and anything else applicable.

There's no interface for userspace to enable it: userspace
only has an ioctl to enable/disable checksum offloading.
SG is an implementation detail.

> > In upstream kernels userspace can disable checksum offloading then
> > re-enable and get SG set back.  userspace came to depend on this
> > behaviour so I think changing this is a regression.
> 
> Can you point me to the relevant code in the upstream kernel?
> I'm not aware of any automatic SG enabling for network devices
> in general when you enable checksum offloading.
> 
> Cheers,

I think what happens _SG is enabled at device creation time and
then upstream just keeps it on always, even when user clears
CSUM. With net-next code changed so that _SG gets cleared when CSUM
'gets cleared. But then it does not get reenabled when CSUM
gets reenabled.

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
