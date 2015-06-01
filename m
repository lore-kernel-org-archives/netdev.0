From: Stephan Mueller <smueller@chronox.de>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Mon, 01 Jun 2015 15:49:58 +0200
Message-ID: <2141601.IbD2v8KjaT@tauon>
References: <20150521103938.GA23035@gondor.apana.org.au> <1706098.2opyZ2hT8S@tachyon.chronox.de> <1433166161.3505.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.eperm.de ([89.247.134.16]:58421 "EHLO mail.eperm.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbbFANuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 09:50:01 -0400
In-Reply-To: <1433166161.3505.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 1. Juni 2015, 15:42:41 schrieb Johannes Berg:

Hi Johannes,

>On Mon, 2015-06-01 at 15:21 +0200, Stephan Mueller wrote:
>> Just a short question on ieee80211_aes_ccm_encrypt,
>> ieee80211_aes_ccm_decrypt, ieee80211_aes_gcm_encrypt,
>> ieee80211_aes_gcm_decrypt, ieee80211_aes_gmac: can the aad parameter of
>> these functions be zero?
>
>What do you mean by "zero"? The pointer itself can clearly never be
>NULL.

Thanks for clarifying: indeed I mean the value of the pointer, not the pointer 
itself :-)
>
>The contents, now, that's a more interesting question. I believe it can
>never be all zeroes, since association request frames are not
>encrypted/protected and thus at least one byte in here must be non-zero.
>The MAC addresses are also very likely non-zero, but technically
>00:00:00:00:00:00 is a valid MAC address I believe.

So, even when having a malicious AP, that value is never zero? The driver of 
the question is the following code in the patch set:

+       sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));

...

+       aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);

...

        crypto_aead_encrypt(aead_req);


When I played around with the aead_request_set_crypt, I saw a crash in the 
scatterlist handling of the crypto API when the first SGL entry has a zero 
length.

Ciao
Stephan
