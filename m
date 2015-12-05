From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Sat, 5 Dec 2015 15:06:03 +0800
Message-ID: <20151205070603.GB23255@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204143956.GA17471@gondor.apana.org.au>
 <20151204170101.GB29598@orbit.nwl.cc>
 <1449251120.25029.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204181555.GC29598@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43904 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbbLEHGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:06:13 -0500
Content-Disposition: inline
In-Reply-To: <20151204181555.GC29598@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 07:15:55PM +0100, Phil Sutter wrote:
>
> > Only one should really do this, while others are waiting.
> 
> Sure, that was my previous understanding of how this thing works.

Yes that's clearly how it should be.  Unfortunately while adding
the locking to do this, I found out that you can't actually call
__vmalloc with BH disabled so this is a no-go.

Unless we can make __vmalloc work with BH disabled, I guess we'll
have to go back to multi-level lookups unless someone has a better
suggestion.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
