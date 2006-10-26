From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] d80211: switch crypto to use block ciphers
Date: Thu, 26 Oct 2006 10:06:24 +1000
Message-ID: <20061026000624.GA29389@gondor.apana.org.au>
References: <20061025224150.GA7364@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41223 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932212AbWJZAGo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 20:06:44 -0400
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061025224150.GA7364@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2006 at 03:41:50PM -0700, David Kimdon wrote:
> 
> I don't actually know the implications of that first hunk where we do
> "arc4" -> "ecb(arc4)".  I look though the various commits by Herbert
> Xu and that appeared to be the right thing.

Basically if you encrypt/decrypt more than a block at a time and you're
using ECB then ecb(arc4) is right.  So the changes to net/d80211/wep.c
are good.

If you're only encrypting/decrypting a single block then you should
use the cipher interface.  So net/d80211/aes_ccm.c should do that
instead.  See drivers/net/wirless/airo.c for an example of that.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
