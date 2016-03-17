From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Thu, 17 Mar 2016 10:41:15 +0100
Message-ID: <20160317094115.GA11706@midget.suse.cz>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36493 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933165AbcCQJlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 05:41:20 -0400
Content-Disposition: inline
In-Reply-To: <20160317050359.GA3840@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 01:03:59PM +0800, Herbert Xu wrote:
> On Wed, Mar 16, 2016 at 05:00:26PM +0100, Jiri Bohac wrote:
> > Prevent xfrm_output() from segmenting UFO packets so that they will be
> > fragmented after the xfrm transforms.
> 
> Fair enough.  But I wonder if this is enough.  Wouldn't UDP notice
> that we're doing IPsec and prefragment the packet anyway? So I think
> this check may also be needed in the UDP output path.

Fixes my broken case. Ftracing a sendmsg call that sends ~8k of
data over the UDP socket, I see a single 8k skb travel through the
stack all the way to xfrm_output(). MTU is 1500.
That's the whole poing of fragmentation offloading, to pass all
the data at once as far as we can, isn't it? What UDP code did
you think would "notice and prefragment"?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
