From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Tue, 2 Jun 2009 19:05:52 +1000
Message-ID: <20090602090552.GA26611@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55013 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752008AbZFBJFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:05:52 -0400
Content-Disposition: inline
In-Reply-To: <200905292346.04815.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 11:46:04PM +0930, Rusty Russell wrote:
> 
> This effectively reverts 99ffc696d10b28580fe93441d627cf290ac4484c
> "virtio: wean net driver off NETDEV_TX_BUSY".
> 
> The complexity of queuing an skb (setting a tasklet to re-xmit) is
> questionable, especially once we get rid of the other reason for the
> tasklet in the next patch.
> 
> If the skb won't fit in the tx queue, just return NETDEV_TX_BUSY.  It
> might be frowned upon, but it's common and not going away any time
> soon.

This looks like a step backwards to me.  If we have to do this
to fix a bug, sure.  But just doing it for the sake of it smells
wrong.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
