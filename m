From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net: check for refcount if pop a stacked dst_entry
Date: Fri, 4 Jun 2010 13:23:46 +0200
Message-ID: <20100604112346.GC13408@secunet.com>
References: <20100604104012.GA13408@secunet.com>
 <20100604104115.GB13408@secunet.com>
 <1275648679.2482.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47282 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451Ab0FDLYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 07:24:20 -0400
Content-Disposition: inline
In-Reply-To: <1275648679.2482.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 04, 2010 at 12:51:19PM +0200, Eric Dumazet wrote:
> 
> Hmm, this might fix the thing, but we probably can do it without the
> dst_clone(), if you replace the 
> 
> skb_dst_set(skb, dst);
> 
> by 
> 
> skb_dst_set_noref(skb, dst);
> 
> in xfrm_output_one() ?
> 

Yes, this should work too. I'll update the patch to use
skb_dst_set_noref() in xfrm_output_one() and remove the 
dst_clone() in skb_dst_pop().
