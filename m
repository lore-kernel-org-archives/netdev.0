From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3 net-next] rhashtable: Use spin_lock_bh_nested()
 consistently
Date: Sat, 14 Mar 2015 13:21:18 +1100
Message-ID: <20150314022118.GB10086@gondor.apana.org.au>
References: <cover.1426257747.git.tgraf@suug.ch>
 <cover.1426257747.git.tgraf@suug.ch>
 <ad7f4c80fc041ae4aae4e2ed5294ba1f218e6afb.1426257747.git.tgraf@suug.ch>
 <20150313.125411.1315810617883806607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46457 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbbCNCVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:21:22 -0400
Content-Disposition: inline
In-Reply-To: <20150313.125411.1315810617883806607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 12:54:11PM -0400, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Fri, 13 Mar 2015 15:45:20 +0100
> 
> > No change in behaviour as the outer lock already disables softirq
> > but it prevents bugs down the line as this lock logically requires
> > the BH variant.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> I would prefer you don't do this.
> 
> x_bh() may be relatively cheap, but it is not zero cost.
> 
> If there is an invariant that when we are called here BH
> is disabled, make it explicit.

Agreed.  I dropped the _bh precisely for this reason when I did
the arbitrary rehash.  Please don't add it back because it serves
zero purpose.  Only the outside lock should do _bh while the
nested one should not.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
