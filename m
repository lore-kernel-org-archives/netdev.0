From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Mon, 18 Apr 2016 16:02:02 +0800
Message-ID: <20160418080202.GA18155@gondor.apana.org.au>
References: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sd@queasysnail.net, arnd@arndb.de,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> The new MACsec driver uses the AES crypto algorithm, but can be configured
> even if CONFIG_CRYPTO is disabled, leading to a build error:
> 
> warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
> warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
> crypto/built-in.o: In function `gcm_enc_copy_hash':
> aes_generic.c:(.text+0x2b8): undefined reference to `crypto_xor'
> aes_generic.c:(.text+0x2dc): undefined reference to `scatterwalk_map_and_copy'
> 
> This adds an explicit 'select CRYPTO' statement the way that other
> drivers handle it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")

Thnis patch is bogus.  The build error is coming from the fact
that GCM is built-in but CRYPTO_ALGAPI is (presumably) only built
as a module.  The patch in question does nothing to address that
AFAICS.

In fact this strikes me as a kbuild bug because CRYPTO_GCM already
selects (indirectly) CRYPTO_ALGAPI so why is this happening at all?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
