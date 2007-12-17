From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Mon, 17 Dec 2007 08:57:55 +0100
Message-ID: <20071217075755.GA2128@ff.dom.local>
References: <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <47656931.1040309@gmail.com> <20071217012632.GA8475@gondor.apana.org.au> <20071217072601.GA1654@ff.dom.local> <20071217073133.GA10813@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:60298 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbXLQHwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 02:52:43 -0500
Received: by fg-out-1718.google.com with SMTP id e21so261400fga.17
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 23:52:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071217073133.GA10813@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 03:31:33PM +0800, Herbert Xu wrote:
> On Mon, Dec 17, 2007 at 08:26:01AM +0100, Jarek Poplawski wrote:
> >
> > Btw. #2: David Miller gave this example of ASSERT_RTNL use:
> > 
> > 	ASSERT_RTNL();
> > 	page = alloc_page(GFP_KERNEL);
> > 
> > But isn't there a debugging duplication: it seems alloc_page() is used
> > in so many places and this check for GFP is/should_be there already?
> 
> On some paths this may be buried a conditional.  Also if you
> replace it with a mutex_is_locked without the may_sleep it won't
> catch the case that started all this, namely the promiscuous path.
> 

Right! There is only a question how much is such cases vs. checked
already, because then a might_sleep is really more readable when
added explicitly.

Jarek P.
