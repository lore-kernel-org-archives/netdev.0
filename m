From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 21 Apr 2009 20:49:19 +0800
Message-ID: <20090421124919.GA18444@gondor.apana.org.au>
References: <20090130065721.GA4886@gondor.apana.org.au> <adaiqnwr91j.fsf@cisco.com> <20090130.135107.116108989.davem@davemloft.net> <ada3af0qgez.fsf@cisco.com> <20090421090918.GA6034@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aluno3@poczta.onet.pl,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47900 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751274AbZDUMtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 08:49:41 -0400
Content-Disposition: inline
In-Reply-To: <20090421090918.GA6034@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 11:09:18AM +0200, Lennert Buytenhek wrote:
> On Fri, Jan 30, 2009 at 07:54:12PM -0800, Roland Dreier wrote:
> 
> > > > I don't believe this is accurate.  Calling skb_linearize() (on a kernel
> > > > with CONFIG_HIGHMEM set) can end up calling local_bh_enable() in
> > > > kunmap_skb_frag(), which can obviously cause problems if the initial
> > > > context relies on having BHs disabled (as hard_start_xmit does).
> > >
> > > local_bh_{enable,disable}() nests, so this is not a problem
> > 
> > Duh.  OK, then the only bugs seem to be that iw_nes does skb_linearize
> > with irqs off (due to being an LLTX driver), and mv643xx_eth leaks an
> > skb on its error path if skb_linearize fails.
> 
> (Found this when deleting old netdev@ mail...)  mv643xx_eth returns
> NETDEV_TX_BUSY if skb_linearize fails, so the qdisc will requeue the
> skb, and we shouldn't free it.  Am I missing something?

I don't think the issue here is the leak.  Calling skb_linearize is
simply illegal if you support netpoll because netpoll will call the
xmit routine with IRQs off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
