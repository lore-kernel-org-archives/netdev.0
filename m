From: David Miller <davem@redhat.com>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Mon, 09 Mar 2015 15:51:37 -0400 (EDT)
Message-ID: <20150309.155137.26393830527159591.davem@redhat.com>
References: <20150202.192634.1792206005008667377.davem@davemloft.net>
	<20150203201750.GA22474@gondor.apana.org.au>
	<20150309095833.GA4028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbbCITwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 15:52:08 -0400
In-Reply-To: <20150309095833.GA4028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Mar 2015 20:58:33 +1100

> Currently hash_rnd is a parameter that users can set.  However,
> no existing users set this parameter.  It is also something that
> people are unlikely to want to set directly since it's just a
> random number.
> 
> In preparation for allowing the reseeding/rehashing of rhashtable,
> this patch moves hash_rnd into bucket_table so that it's now an
> internal state rather than a parameter.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thomas is right, you're going to have to move the hash_rnd initialization
to where we allocate the bucket tables, otherwise the first shrink/expand
will set it to zero.
