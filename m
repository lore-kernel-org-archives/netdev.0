From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 10:21:54 +0100
Message-ID: <20081202092154.GG13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au> <20081202084419.GF13998@secunet.com> <20081202085052.GA30301@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:55324 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYLBJVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 04:21:08 -0500
Content-Disposition: inline
In-Reply-To: <20081202085052.GA30301@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 04:50:52PM +0800, Herbert Xu wrote:
> 
> > > This achieves exactly the same thing as your current patch-set
> > > plus:
> > > 
> > > 1) The uesr no longer has to make a system-wide choice of whether
> > > to enable this, instead the control is per-SA through the usual
> > > algorithm selection mechanism which means that this no longer
> > > conflicts with async crypto;
> > > 
> > > 2) There is no change to the xfrm code;
> > > 
> > > 3) The same mechanism can benefit other crypto users such as
> > > disk encryption.
> > 
> > The padata stuff is generic, so it can be used even for disk
> > encryption or for anything else that should run in parallel but
> > needs a certain order at a given point.
> 
> What about the first issue?
> 

Yes, that's a point. If it is in the network layer we probaply need this
system-wide choice because it would bring a useless overhead to
the sk_buff if this thing is not used. So this could be a plus for
putting it to the crypto layer if we don't need this system-wide choice
there.
