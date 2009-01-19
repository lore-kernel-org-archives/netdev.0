From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 07:45:20 +0100
Message-ID: <20090119064520.GD12946@1wt.eu>
References: <20090119030844.GA31941@gondor.apana.org.au> <20090118.192719.198405397.davem@davemloft.net> <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1615 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754170AbZASGpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 01:45:42 -0500
Content-Disposition: inline
In-Reply-To: <20090118.221908.47032075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 10:19:08PM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 19 Jan 2009 07:14:20 +0100
> 
> > On Sun, Jan 18, 2009 at 07:27:19PM -0800, David Miller wrote:
> > > From: Herbert Xu <herbert@gondor.apana.org.au>
> > > Date: Mon, 19 Jan 2009 14:08:44 +1100
> > > 
> > > > One thing to note is that Myricom's driver probably uses page
> > > > frags which means that you're not actually triggering the copy.
> > 
> > So does this mean that the corruption problem should still there for
> > such a driver ? I'm asking before testing, because at these speeds,
> > validity tests are not that easy ;-)
> 
> It ought not to, but it seems that is the case where you
> saw the original corruptions, so hmmm...
> 
> Actually, I see, the myri10ge driver does put up to
> 64 bytes of the initial packet into the linear area.
> If the IPV4 + TCP headers are less than this, you will
> hit the corruption case even with the myri10ge driver.
> 
> So everything checks out.

OK, so I will modify my tools in order to perform a few checks.

Thanks!
Willy

