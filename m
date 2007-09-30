From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sun, 30 Sep 2007 17:38:28 +0200
Message-ID: <46FFC2F4.8090602@trash.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41905 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757438AbXI3Pib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 11:38:31 -0400
In-Reply-To: <20070930004341.GA7769@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sun, Sep 30, 2007 at 08:26:01AM +0800, Herbert Xu wrote:
> 
>>Indeed.  The only other case I can think of is defragmentation.
>>But even there we should be able to squeeze it into the original
>>skb :)
> 
> 
> OK it won't be pretty but it's definitely doable.  We simply
> swap the contents of that skb with the head skb that would've
> otherwise been returned.
> 
> If this is the only place in netfilter where we need to modify
> *pskb then I think it's worthwhile.
> 
> So the question is are there any other places that we haven't
> covered which also needs to change *pskb?


>From a quick look it seems at least IPv4 and IPv6 don't need to
change the skb anywhere else. It seems to be necessary for
bridging though to unshare the skb. OTOH br_netfilter.c already
unshares the skb for IPv4 and IPv6, so we could simply do this
unconditionally before calling the hooks.

