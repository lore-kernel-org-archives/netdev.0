From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Mon, 15 Feb 2010 10:19:27 +0100
Message-ID: <201002151019.27364.arnd@arndb.de>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com> <201002142013.08745.arnd@arndb.de> <20100215002131.GC15437@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53293 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab0BOJUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 04:20:09 -0500
In-Reply-To: <20100215002131.GC15437@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 15 February 2010, Herbert Xu wrote:
> On Sun, Feb 14, 2010 at 08:13:08PM +0100, Arnd Bergmann wrote:
> >
> > Ah, good point. Will that also work for the checksumming? Also, should the
> > host really be doing segmentation and checksumming for the guest if the
> > hardware can't do it? So even if everything works correctly, we might
> > want to let the guest do the work in order to get accounting of the CPU
> > cycles right.
> 
> Yes the amount you save by ensuring we postpone the processing until
> as last as possible is tremendous.

Ok. If the host actually saves more time than it spends on segmenting
the data, the accounting problem doesn't exist.

> As for accounting, it depends on how we structure the vhost backend.
> If it could stay in the process context of the qemu process then all
> should be fine.

I believe the bulk of the work is currently done in a separate
kernel thread that is shared by all users of vhost. We can probably
try some measurements and see if any insane amounts of time are
spent in that thread.

	Arnd
