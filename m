From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Fri, 18 Mar 2016 09:05:28 +0100
Message-ID: <20160318080528.GK3347@gauss.secunet.com>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
 <20160317094115.GA11706@midget.suse.cz>
 <20160317102459.GG3347@gauss.secunet.com>
 <20160317170855.GA21145@midget.suse.cz>
 <20160318023653.GA17000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Bohac <jbohac@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49777 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbcCRIFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 04:05:32 -0400
Content-Disposition: inline
In-Reply-To: <20160318023653.GA17000@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 10:36:53AM +0800, Herbert Xu wrote:
> On Thu, Mar 17, 2016 at 06:08:55PM +0100, Jiri Bohac wrote:
> > On Thu, Mar 17, 2016 at 11:24:59AM +0100, Steffen Klassert wrote:
> > > In IPv6 this check is missing, so this could be the
> > > problem if this is IPv6.
> > 
> > indeed, this patch also fixes my problem:
> 
> Hmm, is this what you really want? If I understood you correctly,
> you want the fragmentation to occur after IPsec.

The main problem was probably that UFO handling does not work at
all on IPv6 IPsec. 

> So while this
> might generate the same output, it is still going to prefragment
> the data, only to merge them back for IPsec and then refragment
> again.

This is far away from being optimal, but this is what usually
happens if a local application sends data that we need to
fragment.

We currently work on avoiding the linearization on IPsec,
but having a skb with a fraglist is really the worst case.
