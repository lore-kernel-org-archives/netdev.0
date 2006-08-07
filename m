From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 09:40:49 +1000
Message-ID: <20060807234049.GA11611@gondor.apana.org.au>
References: <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com> <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com> <1154973625.5446.56.camel@jzny2> <20060807184748.GA10909@edgar.underground.se.axis.com> <1154977413.5446.83.camel@jzny2> <20060807232340.GA11088@gondor.apana.org.au> <Pine.WNT.4.63.0608071628370.3576@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12038 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932419AbWHGXlY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:41:24 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0608071628370.3576@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 04:35:36PM -0700, Brandeburg, Jesse wrote:
> 
> e1000 only clears the interrupts when it reads ICR in e1000_intr (before 
> scheduling napi poll) so any interrupts that occur while polling (and 
> interrupts are disabled) will cause a new assertion once interrupts are 
> re-enabled.  Sometimes a little bit inefficient due to extra trips through 
> poll, but guarantees never to miss an int.  I'm open to creative ways to 
> avoid this, but adding an I/O read in e1000_clean would be pretty yucky.

The standard solution in Linux is to clear and recheck.  So just before
you reenable the interrupts you'd clear pending interrupts again and
check for rx/tx work, if there is work then you just go back to polling.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
