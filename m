From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Thu, 17 Mar 2016 13:03:59 +0800
Message-ID: <20160317050359.GA3840@gondor.apana.org.au>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57371 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbcCQFEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 01:04:16 -0400
Content-Disposition: inline
In-Reply-To: <20160316160026.GB19258@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 05:00:26PM +0100, Jiri Bohac wrote:
> xfrm_output() will segment GSO packets, including UDP (UFO) packets.
> this is wrong per RFC4303, section 3.3.4.  Fragmentation:
> 
>    If necessary, fragmentation is performed after ESP
>    processing within an IPsec implementation.  Thus,
>    transport mode ESP is applied only to whole IP
>    datagrams (not to IP fragments).
> 
> Prevent xfrm_output() from segmenting UFO packets so that they will be
> fragmented after the xfrm transforms.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Fair enough.  But I wonder if this is enough.  Wouldn't UDP notice
that we're doing IPsec and prefragment the packet anyway? So I think
this check may also be needed in the UDP output path.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
