From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Mon, 01 Jun 2015 15:42:41 +0200
Message-ID: <1433166161.3505.7.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
	 <1432207249.2343.9.camel@sipsolutions.net>
	 <1706098.2opyZ2hT8S@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58754 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbbFANmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 09:42:47 -0400
In-Reply-To: <1706098.2opyZ2hT8S@tachyon.chronox.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-01 at 15:21 +0200, Stephan Mueller wrote:

> Just a short question on ieee80211_aes_ccm_encrypt, ieee80211_aes_ccm_decrypt, 
> ieee80211_aes_gcm_encrypt, ieee80211_aes_gcm_decrypt, ieee80211_aes_gmac: can 
> the aad parameter of these functions be zero?

What do you mean by "zero"? The pointer itself can clearly never be
NULL.

The contents, now, that's a more interesting question. I believe it can
never be all zeroes, since association request frames are not
encrypted/protected and thus at least one byte in here must be non-zero.
The MAC addresses are also very likely non-zero, but technically
00:00:00:00:00:00 is a valid MAC address I believe.

johannes
