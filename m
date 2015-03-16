From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3 net-next] rhashtable: Use spin_lock_bh_nested()
 consistently
Date: Mon, 16 Mar 2015 08:44:10 +0000
Message-ID: <20150316084410.GB10896@casper.infradead.org>
References: <cover.1426257747.git.tgraf@suug.ch>
 <cover.1426257747.git.tgraf@suug.ch>
 <ad7f4c80fc041ae4aae4e2ed5294ba1f218e6afb.1426257747.git.tgraf@suug.ch>
 <20150313.125411.1315810617883806607.davem@davemloft.net>
 <20150314022118.GB10086@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41557 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbbCPIoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 04:44:11 -0400
Content-Disposition: inline
In-Reply-To: <20150314022118.GB10086@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/15 at 01:21pm, Herbert Xu wrote:
> On Fri, Mar 13, 2015 at 12:54:11PM -0400, David Miller wrote:
> > From: Thomas Graf <tgraf@suug.ch>
> > Date: Fri, 13 Mar 2015 15:45:20 +0100
> > 
> > > No change in behaviour as the outer lock already disables softirq
> > > but it prevents bugs down the line as this lock logically requires
> > > the BH variant.
> > > 
> > > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > I would prefer you don't do this.

OK, I'm dropping this patch.

> > x_bh() may be relatively cheap, but it is not zero cost.
> > 
> > If there is an invariant that when we are called here BH
> > is disabled, make it explicit.

I assume you are referring to the preempt disabled case. Fair enough.

> Agreed.  I dropped the _bh precisely for this reason when I did
> the arbitrary rehash.  Please don't add it back because it serves
> zero purpose.  Only the outside lock should do _bh while the
> nested one should not.

A note in the commit would have helped, it looked like an
accidental change.
