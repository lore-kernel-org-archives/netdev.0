From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] blkcipher: Copy iv from desc even for 0-len walks
Date: Wed, 9 Dec 2015 20:18:58 +0800
Message-ID: <20151209121858.GC27962@gondor.apana.org.au>
References: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	martin@strongswan.org, stable@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 06, 2015 at 02:51:37AM +0100, Jason A. Donenfeld wrote:
> Some ciphers actually support encrypting zero length plaintexts. For
> example, many AEAD modes support this. The resulting ciphertext for
> those winds up being only the authentication tag, which is a result of
> the key, the iv, the additional data, and the fact that the plaintext
> had zero length. The blkcipher constructors won't copy the IV to the
> right place, however, when using a zero length input, resulting in
> some significant problems when ciphers call their initialization
> routines, only to find that the ->iv parameter is uninitialized. One
> such example of this would be using chacha20poly1305 with a zero length
> input, which then calls chacha20, which calls the key setup routine,
> which eventually OOPSes due to the uninitialized ->iv member.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: <stable@vger.kernel.org>

Applied to crypto.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
