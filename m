From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 07 Apr 2009 08:48:40 -0400
Message-ID: <1239108520.32737.28.camel@dogo.mojatatu.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johann Baudy <johann.baudy@gnu-log.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:31430 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbZDGMv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 08:51:27 -0400
Received: by wa-out-1112.google.com with SMTP id j5so2057511wah.21
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 05:51:25 -0700 (PDT)
In-Reply-To: <20090407072647.GA11480@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-07 at 15:26 +0800, Herbert Xu wrote:

> What if something modifies skb->mark after it's sent? 
> For now the only thing I can think of is a tc netfilter action.  So you could
> also solve the problem by removing that feature since IMHO it is
> pretty dodgy :)

I see it as being non-trivial even with tc/mark. What did you
have in mind? 
If it was possible to have a different skb->cookie (other than
skb->mark, sort of "global cb") which the sender sets and 
the kernel never touches then this would be easy. The skb->destructor
can then be sure that it was the original skb in the lookup. Such a
field could serve other purposes like notify user space that the packet
has been really sent out (eg in the case of tun). But that would require
a new field on the skb.

[For a fleeting latte-moment there i thought i had a clever idea: I
wanted to say that the numeric (32/64 bit) allocated address of the skb
may be useful for the cookie but i think that could change in the skb's
kernel lifetime (skb_expand etc).]

cheers,
jamal

