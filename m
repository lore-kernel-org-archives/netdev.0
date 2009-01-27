From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 18:11:30 +1100
Message-ID: <20090127071130.GA29125@gondor.apana.org.au>
References: <20090125.212203.15909648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, zbr@ioremap.net, w@1wt.eu, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39449 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751879AbZA0HNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 02:13:53 -0500
Content-Disposition: inline
In-Reply-To: <20090125.212203.15909648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 22 Jan 2009 09:04:42 +0000
> 
>> It seems this sk_sndmsg_page usage (refcounting) isn't consistent.
>> I used here tcp_sndmsg() way, but I think I'll go back to this question
>> soon.
> 
> Indeed, it is something to look into, as well as locking.
> 
> I'll try to find some time for this, thanks Jarek.

After a quick look it seems to be OK to me.  The code in the patch
is called from tcp_splice_read, which holds the socket lock.  So as
long as the patch uses the usual TCP convention it should work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
