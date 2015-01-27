From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Wed, 28 Jan 2015 07:39:24 +1100
Message-ID: <20150127203924.GB9061@gondor.apana.org.au>
References: <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
 <20150127112304.GA4548@gondor.apana.org.au>
 <20150127114028.GG22262@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42282 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932809AbbA0Ujv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:39:51 -0500
Content-Disposition: inline
In-Reply-To: <20150127114028.GG22262@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 11:40:28AM +0000, Thomas Graf wrote:
> 
> This is unrelated to resize run control though, the reason is that
> I'm converting tcp_hashinfo et al and they require a hybrid approach.
> The tables may be too big to construct a parallel data structure, we
> don't want to hold off inserts or deletes while the expensive dump
> is underway. Even though we can't build a shadow structure while
> locking everybody else out, we still want to provide a way to somehow
> achieve consistent information. I think that NLM_F_INTR with fallback
> to restarting the dump is a good option and very easy to implement. In
> that case, we want to lock out resize from dumping iterations but
> still allow parallel insert/delete.

Well I guess Dave needs to make the call.  Do we want to allow
lockless walks over the hash table or not?

Personally I don't think a linked list is that big a deal.  But then
you guys were agonsing over a single pointer so who knows.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
