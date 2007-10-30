From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [CRYPTO] tcrypt: Move sg_init_table out of timing loops
Date: Tue, 30 Oct 2007 22:18:20 +0800
Message-ID: <20071030141820.GA16501@gondor.apana.org.au>
References: <20071026145905.GA13850@gondor.apana.org.au> <E1IlQfM-0003cO-00@gondolin.me.apana.org.au> <20071029201627.GD7499@kernel.dk> <20071030000827.GA9037@gondor.apana.org.au> <20071030055056.GG7499@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1532 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752181AbXJ3OSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 10:18:46 -0400
Content-Disposition: inline
In-Reply-To: <20071030055056.GG7499@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 06:50:58AM +0100, Jens Axboe wrote:
>
> How so? The reason you changed it to sg_init_table() + sg_set_buf() is
> exactly because sg_init_one() didn't properly init the entry (as they
> name promised).

For one of the cases yes but the other one repeatedly calls
sg_init_one on the same sg entry while we really only need
to initialise it once and call sg_set_buf afterwards.

Normally this is irrelevant but the loops in question are
trying to estimate the speed of the algorithms so it's good
to exclude as much noise from them as possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
