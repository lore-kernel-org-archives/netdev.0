From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Thu, 17 Mar 2016 11:49:53 +0100
Message-ID: <20160317104953.GB11706@midget.suse.cz>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
 <20160317094115.GA11706@midget.suse.cz>
 <20160317102459.GG3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45389 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935208AbcCQKt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 06:49:56 -0400
Content-Disposition: inline
In-Reply-To: <20160317102459.GG3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 11:24:59AM +0100, Steffen Klassert wrote:
> > > On Wed, Mar 16, 2016 at 05:00:26PM +0100, Jiri Bohac wrote:
> > Fixes my broken case. 
> 
> Is this IPv4 or IPv6? IPv4 should not create a GSO skb
> if IPsec is done. It checks for rt->dst.header_len
> in __ip_append_data() and does a fallback to the
> standard case if rt->dst.header_len is non zero.

It's IPv6.

> In IPv6 this check is missing, so this could be the
> problem if this is IPv6.

Doesn't the check do exactly the opposite of what the RFC says?
The RFC wants ESP to be performed first and fragmentation after
that. UDPv4 currently seems to be doing the opposite. Well at
least it works, unlike in the IPv6 case, where the packet is
fragmented, but not enough space is reserved, so after adding the
ESP headers, it is fragmented once more.

(Details can be found in my first e-mail in this thread, I now
replied into the old thread after >1 month, sorry for that:
http://thread.gmane.org/gmane.linux.network/396952
)
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
