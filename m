From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Sun, 22 Mar 2015 13:06:30 +0000
Message-ID: <20150322130630.GA16023@casper.infradead.org>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50402 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbCVNGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 09:06:33 -0400
Content-Disposition: inline
In-Reply-To: <20150322121755.GH1185@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/15 at 12:17pm, Thomas Graf wrote:
> On 03/22/15 at 07:04pm, Herbert Xu wrote:
> > +	struct bucket_table *new_tbl;
> > +	struct bucket_table *tbl;
> > +	int err;
> >  
> > -	ASSERT_RHT_MUTEX(ht);
> > +	if (size < ht->p.min_size)
> > +		size = ht->p.min_size;
> 
> We should only shrink if size < old_tbl->size

I found the check further down. Any particular reason why check
after allocation and then free again? Why do you want to avoid
the allocation inside the mutex?

> > -	new_tbl = bucket_table_alloc(ht, old_tbl->size / 2);
> > +	new_tbl = bucket_table_alloc(ht, size);
> >  	if (new_tbl == NULL)
> >  		return -ENOMEM;
