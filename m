From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 09:36:31 +1000
Message-ID: <20060420233631.GA28380@gondor.apana.org.au>
References: <200604201035.00100.shaw@vranix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:273 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751281AbWDTXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 19:36:36 -0400
To: shawvrana@gmail.com
Content-Disposition: inline
In-Reply-To: <200604201035.00100.shaw@vranix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 05:35:00PM +0000, shawvrana@gmail.com wrote:
> 
> If the e1000_tx_timeout_task were running concurrently with e1000_down, it 
> seems that they could both attempt to kfree_skb concurrently when running 
> e1000_unmap_and_free_tx_resource.   I googled around to find mention of this 
> anywhere with no luck.  Has this been discussed already?

Yes that's definitely buggy.  There needs to be some form of
synchronisation as the TG3 driver does.  However, to be frank
I'm not too fond of what the TG3 driver does either.  Is there
no better way than an msleep loop?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
