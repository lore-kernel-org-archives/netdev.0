From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Thu, 17 Mar 2016 11:24:59 +0100
Message-ID: <20160317102459.GG3347@gauss.secunet.com>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
 <20160317094115.GA11706@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35012 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935494AbcCQKZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 06:25:08 -0400
Content-Disposition: inline
In-Reply-To: <20160317094115.GA11706@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 10:41:15AM +0100, Jiri Bohac wrote:
> On Thu, Mar 17, 2016 at 01:03:59PM +0800, Herbert Xu wrote:
> > On Wed, Mar 16, 2016 at 05:00:26PM +0100, Jiri Bohac wrote:
> > > Prevent xfrm_output() from segmenting UFO packets so that they will be
> > > fragmented after the xfrm transforms.
> > 
> > Fair enough.  But I wonder if this is enough.  Wouldn't UDP notice
> > that we're doing IPsec and prefragment the packet anyway? So I think
> > this check may also be needed in the UDP output path.
> 
> Fixes my broken case. 

Is this IPv4 or IPv6? IPv4 should not create a GSO skb
if IPsec is done. It checks for rt->dst.header_len
in __ip_append_data() and does a fallback to the
standard case if rt->dst.header_len is non zero.

In IPv6 this check is missing, so this could be the
problem if this is IPv6.
