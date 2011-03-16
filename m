From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/2] xfrm: Force a dst refcount before entering the
 xfrm type handlers
Date: Wed, 16 Mar 2011 08:43:06 +0100
Message-ID: <20110316074306.GT31402@secunet.com>
References: <20110316070828.GQ31402@secunet.com>
 <20110316.001732.112599674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49655 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154Ab1CPHnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 03:43:08 -0400
Content-Disposition: inline
In-Reply-To: <20110316.001732.112599674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2011 at 12:17:32AM -0700, David Miller wrote:
> 
> Steffen we really need to find another way to fix these problems.
> 
> We already make way too many expensive atomic operations in these code
> paths modified by your 3 patches, we should strive to not add new
> ones.
> 

I know that it is exspensive, but we have to take a refcount if
the crypto layer returns asyncronous. Unfortunately it is too
late to take the refcount when the crypto layer notifies us about
that as the skb might be already gone.

The second patch just moves the refcount from xfrm_output_one
to skb_dst_pop. As xfrm_output_one is the only user of
skb_dst_pop, we take the refcont just a bit realier.

The third one makes the socket policy case consistent to the
case where we get the destination entry from the flow cache
where we take a reference. We can either return the dst entry
with or without a refcont in both cases. But we can't return
sometimes with and somtimes without a refcount.

I'd be happy to see all these refcounts gone too of course,
but that's way beyond a simple bug fix.

Steffen
