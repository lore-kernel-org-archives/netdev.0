From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 12:17:11 +1000
Message-ID: <20060808021711.GA12795@gondor.apana.org.au>
References: <1154797002.5081.21.camel@jzny2> <20060805230517.GA25468@gondor.apana.org.au> <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <1154867083.6269.35.camel@jzny2> <1154999971.5138.19.camel@jzny2> <20060808012217.GA12468@gondor.apana.org.au> <1155000832.5138.31.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45833 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751045AbWHHCRw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 22:17:52 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155000832.5138.31.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 09:33:52PM -0400, jamal wrote:
> 
> Is there a need for a schedule if that happens? i.e assuming that the
> clearing happens because there are no more packets to process. 
> OTOH, if the other side sets the QDISC_RUNNING right after the test,
> then qdisc is running will be entered.

CPU0				CPU1
__qdisc_run
	netif_queue_stopped
				netif_wake_queue
					__netif_schedule
						test_bit
	clear_bit

So you may end up losing that wake event.  The QDISC_RUNNING bit was
originally designed to be used under the qdisc lock, so using it
in a different contexts will require new synchronisation mechanisms.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
