From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Mon, 17 Dec 2007 15:31:33 +0800
Message-ID: <20071217073133.GA10813@gondor.apana.org.au>
References: <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <47656931.1040309@gmail.com> <20071217012632.GA8475@gondor.apana.org.au> <20071217072601.GA1654@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3462 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758457AbXLQHbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 02:31:45 -0500
Content-Disposition: inline
In-Reply-To: <20071217072601.GA1654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 08:26:01AM +0100, Jarek Poplawski wrote:
>
> Btw. #2: David Miller gave this example of ASSERT_RTNL use:
> 
> 	ASSERT_RTNL();
> 	page = alloc_page(GFP_KERNEL);
> 
> But isn't there a debugging duplication: it seems alloc_page() is used
> in so many places and this check for GFP is/should_be there already?

On some paths this may be buried a conditional.  Also if you
replace it with a mutex_is_locked without the may_sleep it won't
catch the case that started all this, namely the promiscuous path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
