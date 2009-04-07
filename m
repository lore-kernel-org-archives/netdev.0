From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 8 Apr 2009 01:11:30 +0400
Message-ID: <20090407211130.GA5918@ioremap.net>
References: <1238701718.5669.26.camel@bender> <20090407072647.GA11480@gondor.apana.org.au> <1239108520.32737.28.camel@dogo.mojatatu.com> <20090407130447.GA14329@gondor.apana.org.au> <1239112067.32737.51.camel@dogo.mojatatu.com> <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com> <1239137800.21227.10.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johann.baudy@gnu-log.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:49754 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007AbZDGVLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 17:11:41 -0400
Content-Disposition: inline
In-Reply-To: <1239137800.21227.10.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2009 at 04:56:40PM -0400, jamal (hadi@cyberus.ca) wrote:
> Makes sense for what you are trying to do (or someone else a long
> while back who wanted to notify user space of a sent skb).
> Any skb metadata can mutate along its path. Actually even
> if you used a field off the skb->data it too could be changed 
> somewhere along the path before destructor is invoked.
> There maybe a "hard way" to achieve your goal: use the address
> of the skb to derive your index; i am not 100% sure if your destructor
> will always be called (check skb_expand() for example).

It should, I actually do not see any sending path which does not invoke
original skb destructor with the new data. It does not change the fact
though, that effectively any other skb field can be modified during skb
lifecycle no matter at which level it was allocated.

Having a data pointer as an index could work though, especially it looks
promising for fragments placed in own pages.

-- 
	Evgeniy Polyakov
