From: David Miller <davem@davemloft.net>
Subject: Re: LRO restructuring?
Date: Mon, 11 Aug 2008 17:54:34 -0700 (PDT)
Message-ID: <20080811.175434.215224347.davem@davemloft.net>
References: <48A03EF9.9090602@myri.com>
	<20080812005033.GA18547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, netdev@vger.kernel.org, brice@myri.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbYHLAyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:54:33 -0400
In-Reply-To: <20080812005033.GA18547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 12 Aug 2008 08:50:33 +0800

> On Mon, Aug 11, 2008 at 09:30:33AM -0400, Andrew Gallatin wrote:
> >
> > For lro_receive_frags() based LRO, it would be ideal to locate the
> > header in place in the frag via the mac_hdr argument to the
> > get_frag_header() callback.  Eg, I'm hoping that neither the driver
> > nor the LRO module will need to allocate extra memory per frame and
> > copy the headers to it in the common case when forwarding is
> > not enabled.  That would add quite a bit of overhead.
> 
> You don't have to save the whole thing, just save enough so we
> can easily/exactly reconstruct it on output, i.e., save the lengths.

And the checksums :-)  As an intermediate node we don't want
to touch the checksum.

The length and the checksum is two u16 values, which would be
able to fit in a single 32-bit descriptor or something like
that.
