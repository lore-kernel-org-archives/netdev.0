From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH/RFC] Use of uninitialized data in udp_recvmsg().
Date: Tue, 6 Mar 2007 10:57:32 +1100
Message-ID: <20070305235732.GA24642@gondor.apana.org.au>
References: <E1HOLBe-000660-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0703051257520.27979@jchow-amax.eng.vmware.com> <20070305233449.GA24159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jim Chow <jchow@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933230AbXCEX5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 18:57:39 -0500
Content-Disposition: inline
In-Reply-To: <20070305233449.GA24159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 10:34:49AM +1100, Herbert Xu wrote:
> > 
> > That's not true.  Please see my post.
> > 
> > Specifically, at linux-2.6.20.1/net/ipv4/udp.c:843, it seems that 
> > udp_recvmsg() can randomly ignore whether the HW has computed a checksum 
> > and compute it in SW redundantly.
> 
> Sorry, you're right.  This bug has been there for years.

Actually I think we should fix UDP regardless of whether we initialise
msg_flags to zero here.  It's just too error-prone to rely on it to not
have MSG_TRUNC set.

I'm going to clean this up for UDP and improve the UDP-lite checksum
handling while I'm at it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
