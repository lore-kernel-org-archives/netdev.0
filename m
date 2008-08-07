From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 07 Aug 2008 15:44:53 -0700 (PDT)
Message-ID: <20080807.154453.14005681.davem@davemloft.net>
References: <20080803085553.GA1512@gondor.apana.org.au>
	<20080806.230741.137564172.davem@davemloft.net>
	<489B5BC5.3030600@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	buytenh@wantstofly.org, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org, dale@farnsworth.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753188AbYHGWox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 18:44:53 -0400
In-Reply-To: <489B5BC5.3030600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 07 Aug 2008 13:32:05 -0700

> David Miller wrote:
> > So I had this idea.  My goal is to minimize the number of DMA
> > mappings the driver has to make.
> > 
> > We don't touch anything in the original TSO skb.  However we expand
> > the headroom (if necessary) and in the area in front of skb->data we
> > build the header areas for the sub-TSO frames, one by one.
> > 
> > We give the driver some iterator functions that walk through the
> > header areas and compute offset/length pairs into the
> > skb_shared_info() page list.
> 
> Is that like Solaris Multi Data Transmit?

No, it's slightly different.

Solaris just accumulates a list of packets and gives them all to the
device at once.  It doesn't do anything interesting to optimize
the DMA mappings or anything clever like we'll be doing here.

Here, the TCP stack will be working with TSO frames, which cuts down
per-packet overhead and whatnot.  Solaris works with just normal MSS
sized frames when it does it's batching thing.  And that's all it is,
batching.

