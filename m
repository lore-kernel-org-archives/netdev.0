From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 10:49:50 +0100
Message-ID: <20070126094950.GB1639@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:46490 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161015AbXAZJrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 04:47:21 -0500
Content-Disposition: inline
In-Reply-To: <20070126091606.GA23469@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 08:16:06PM +1100, Herbert Xu wrote:
> On Fri, Jan 26, 2007 at 09:28:38AM +0100, Jarek Poplawski wrote:
> > 
> > So maybe for some time there should be added skb->users
> > test with a warning to reveal this?
> 
> Or just replace __kfree_skb by kfree_skb.  The atomic operation (the
> expensive part of kfree_skb vs. __kfree_skb) is only taken when it
> is needed.

But: 

> This change might reveals a memory leak of skb.
> If it happens, it would be because someone doesn't deal with the skb properly.

How do we know about those improper deals? 
I understand there should be no other users here
if it's __kfree_skb now. So I mean to test and warn
before kfree_skb for some debugging time.

Jarek P.
