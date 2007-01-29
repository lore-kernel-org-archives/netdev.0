From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Mon, 29 Jan 2007 09:26:16 +0100
Message-ID: <20070129082616.GA1652@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp> <20070126082838.GA1639@ff.dom.local> <20070126091606.GA23469@gondor.apana.org.au> <20070126094950.GB1639@ff.dom.local> <20070126095251.GA24204@gondor.apana.org.au> <20070126101838.GC1639@ff.dom.local> <20070126104518.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>,
	davem@davemloft.net, yoshfuji@linux-ipv6.org, mhuth@mvista.com,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51339 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933262AbXA2IXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 03:23:40 -0500
Content-Disposition: inline
In-Reply-To: <20070126104518.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 09:45:18PM +1100, Herbert Xu wrote:
> On Fri, Jan 26, 2007 at 11:18:38AM +0100, Jarek Poplawski wrote:
> > 
> > I don't mean it's necessary. I mean now skb is freed
> > unconditionally and after this patch, if there is some
> > error in counting, skb will stay. I thought Masayuki
> > wrote about such possibility, but if I missed his
> > point, then the rest is really O.K.
> 
> OK, I see what you mean.

Now I see what I mean too... And it's very bad!

This patch was done to allow more skb->users here, so
this debugging would warn mainly about something we've
just enabled.

I was simply fooled by this change - how it was
possible to work all these days? I see, the main idea
is: the data from skb is copied at this level only and
no cloning (tcp_ipv4). Except tcp_ipv6.

So this patch is changing it to ipv6 way. It seems to
be quite brave. I think there was some reason to do
this "old way" and I hope consequences were analyzed.

There are also other doubts: what decisions are made?
According to tcp_rcv_state_process skb should be
dropped. tcp_v6_do_rcv seems to have other opinion.
And after this change there could be, probably, more
such doubtful places.

Maybe it would be sufficient to enable this by some
additional "if" and return code from conn_request
in the "if (th->syn)" block? 

Regards,
Jarek P.
