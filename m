From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next-2.6 PATCH] net: consolidate netif_needs_gso() checks
Date: Thu, 17 Jun 2010 20:18:57 +1000
Message-ID: <20100617101857.GA1053@gondor.apana.org.au>
References: <20100617001804.5155.30862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, John Fastabend <john.r.fastabend@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:49816 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757970Ab0FQKTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 06:19:06 -0400
Content-Disposition: inline
In-Reply-To: <20100617001804.5155.30862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 05:18:12PM -0700, Jeff Kirsher wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> 
> netif_needs_gso() is checked twice in the TX path once,
> before submitting the skb to the qdisc and once after
> it is dequeued from the qdisc just before calling
> ndo_hard_start().  This opens a window for a user to
> change the gso/tso or tx checksum settings that can
> cause netif_needs_gso to be true in one check and false
> in the other.
> 
> Specifically, changing TX checksum setting may cause
> the warning in skb_gso_segment() to be triggered if
> the checksum is calculated earlier.
> 
> This consolidates the netif_needs_gso() calls so that
> the stack only checks if gso is needed in
> dev_hard_start_xmit().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
