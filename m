From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 11:18:38 +0100
Message-ID: <20070126101838.GC1639@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:53954 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161030AbXAZKQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 05:16:09 -0500
Content-Disposition: inline
In-Reply-To: <20070126095251.GA24204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 08:52:51PM +1100, Herbert Xu wrote:
> On Fri, Jan 26, 2007 at 10:49:50AM +0100, Jarek Poplawski wrote:
> > 
> > How do we know about those improper deals? 
> > I understand there should be no other users here
> > if it's __kfree_skb now. So I mean to test and warn
> > before kfree_skb for some debugging time.
> 
> We only need to do that if there is a legitimate reason to use
> __kfree_skb.  Which there was when this code was first written
> since kfree_skb had an unconditional atomic op back then.
> 
> Now that it's a conditinoal atomic op __kfree_skb is no longer
> necessary.

I don't mean it's necessary. I mean now skb is freed
unconditionally and after this patch, if there is some
error in counting, skb will stay. I thought Masayuki
wrote about such possibility, but if I missed his
point, then the rest is really O.K.
 
Cheers,
Jarek P.
