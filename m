From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack
 crash, etc)
Date: Tue, 28 Jun 2016 20:42:41 +0800
Message-ID: <20160628124241.GA17940@gondor.apana.org.au>
References: <20160628123743.7960.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: luto@amacapital.net, linux-bluetooth@vger.kernel.org,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35934 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbcF1Mmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 08:42:50 -0400
Content-Disposition: inline
In-Reply-To: <20160628123743.7960.qmail@ns.sciencehorizons.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 08:37:43AM -0400, George Spelvin wrote:
> Just a note, crypto/cts.c also does a lot of sg_set_buf() in stack buffers.
> 
> I have a local patch (appended, if anyone wants) to reduce the wasteful
> amount of buffer space it uses (from 7 to 3 blocks on encrypt, from
> 6 to 3 blocks on decrypt), but it would take some rework to convert to
> crypto_cipher_encrypt_one() or avoid stack buffers entirely.

I'm currently working on cts and I'm removing the stack usage
altogether by having it operate on the src/dst SG lists only.

It's part of the skcipher conversion though so it'll have to go
through the crypto tree.

BTW, the only cts user in our tree appears to be implementing
CTS all over again and is only calling the crypto API cts for
the last two blocks.  Someone should fix that.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
