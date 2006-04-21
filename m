From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 11:33:40 +1000
Message-ID: <20060421013340.GA29123@gondor.apana.org.au>
References: <200604201035.00100.shaw@vranix.com> <20060420233631.GA28380@gondor.apana.org.au> <20060420235149.GA28503@gondor.apana.org.au> <1145572617.3310.4.camel@rh4> <20060421012701.GA29053@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawvrana@gmail.com, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49682 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932097AbWDUBdv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 21:33:51 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <20060421012701.GA29053@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2006 at 11:27:01AM +1000, herbert wrote:
> On Thu, Apr 20, 2006 at 03:36:57PM -0700, Michael Chan wrote:
> >
> > If we're in tg3_close() and the reset task isn't running yet, tg3_close
> > () will proceed. However, when the reset task finally runs, it will see
> > that netif_running() is zero and will just return.
> 
> Yes you're absolutely right.

Actually, what if the tg3_close is followed by a tg3_open? That could
produce a spurious reset which I suppose isn't that bad.  Also if the
module is unloaded bad things will happen as well.  So I still don't
feel too comfortable about leaving it scheduled after a close.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
