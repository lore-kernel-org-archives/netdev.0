From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 09:51:49 +1000
Message-ID: <20060420235149.GA28503@gondor.apana.org.au>
References: <200604201035.00100.shaw@vranix.com> <20060420233631.GA28380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14865 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932150AbWDTXvy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 19:51:54 -0400
To: shawvrana@gmail.com
Content-Disposition: inline
In-Reply-To: <20060420233631.GA28380@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2006 at 09:36:31AM +1000, herbert wrote:
> 
> Yes that's definitely buggy.  There needs to be some form of
> synchronisation as the TG3 driver does.  However, to be frank
> I'm not too fond of what the TG3 driver does either.  Is there
> no better way than an msleep loop?

Actually TG3 is buggy too.  If the reset task is scheduled but
isn't running yet there is no synchronisation here to prevent the
reset task from running after tg3_close releases the tp lock.

It needs to kill the reset task and make sure it doesn't get
rescheduled by someone else.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
