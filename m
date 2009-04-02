From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] net: allow multiple dev per napi with GRO
Date: Thu, 2 Apr 2009 16:28:48 +0800
Message-ID: <20090402082848.GA29686@gondor.apana.org.au>
References: <20090401142020.395f51bb@nehalam> <20090402.010801.243630133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36271 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755200AbZDBI24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:28:56 -0400
Content-Disposition: inline
In-Reply-To: <20090402.010801.243630133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 01:08:01AM -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 1 Apr 2009 14:20:20 -0700
> 
> > GRO assumes that there is a one-to-one relationship between NAPI
> > structure and network device. Some devices like sky2 share multiple
> > devices on a single interrupt so only have one NAPI handler. Rather than
> > split GRO from NAPI, just have GRO assume if device changes that
> > it is a different flow.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Looks good, applied.

Yep, looks good to me too.  It's only the non-skb interface that
can't handle a shared napi as it uses napi->dev to construct the
skb.

I'm currently experimenting with a new interface to replace the
existing non-skb interface.  The idea is to get the driver to do
what we currently do in napi_fraginfo_skb through helpers.  This
should remove the usage of napi->dev.  It should also remove the
unnecessary double-copying of the frags array.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
