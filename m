From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Crypto Update for 2.6.21
Date: Thu, 8 Feb 2007 02:47:17 +1100
Message-ID: <20070207154717.GA2757@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1743 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030633AbXBGPr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 10:47:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Here is the crypto update for 2.6.21:

Please pull from

git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6.git

or

master.kernel.org:/pub/scm/linux/kernel/git/herbert/crypto-2.6.git

Summary:

* Added Camellia, PCBC, DES-like encryption for RxRPC.
* API updates in preparation for async.

Andrew Donofrio (1):
      [CRYPTO] tcrypt: Added test vectors for sha384/sha512

David Howells (2):
      [CRYPTO] pcbc: Add Propagated CBC template
      [CRYPTO] fcrypt: Add FCrypt from RxRPC

Herbert Xu (7):
      [CRYPTO] all: Check for usage in hard IRQ context
      [CRYPTO] tcrypt: Removed vestigial crypto_alloc_tfm call
      [CRYPTO] api: Remove deprecated interface
      [CRYPTO] api: Add type-safe spawns
      [CRYPTO] api: Allow multiple frontends per backend
      [CRYPTO] xcbc: Use new cipher interface
      [CRYPTO] api: Use structs for cipher/compression

Noriaki TAKAMIYA (6):
      [CRYPTO] camellia: Add Kconfig entry.
      [CRYPTO] camellia: added the code of Camellia cipher algorithm.
      [CRYPTO] camellia: added the testing code of Camellia cipher
      [IPSEC]: added the definition of Camellia cipher
      [IPSEC]: added the entry of Camellia cipher algorithm to ealg_list[]
      [CRYPTO] doc: added the developer of Camellia cipher

Richard Knutsson (1):
      [CRYPTO] geode: Convert pci_module_init() to pci_register_driver()

 Documentation/crypto/api-intro.txt |    4 
 crypto/Kconfig                     |   31 
 crypto/Makefile                    |    3 
 crypto/algapi.c                    |   15 
 crypto/api.c                       |   80 -
 crypto/blkcipher.c                 |    9 
 crypto/camellia.c                  | 1801 +++++++++++++++++++++++++++++++++++++
 crypto/cbc.c                       |    9 
 crypto/cipher.c                    |  447 ---------
 crypto/compress.c                  |    5 
 crypto/digest.c                    |   24 
 crypto/ecb.c                       |    9 
 crypto/fcrypt.c                    |  423 ++++++++
 crypto/hash.c                      |    5 
 crypto/hmac.c                      |    9 
 crypto/internal.h                  |   27 
 crypto/lrw.c                       |   11 
 crypto/pcbc.c                      |  349 +++++++
 crypto/tcrypt.c                    |   73 +
 crypto/tcrypt.h                    |  538 +++++++++++
 crypto/xcbc.c                      |   60 -
 drivers/crypto/geode-aes.c         |    2 
 fs/ecryptfs/crypto.c               |    4 
 fs/ecryptfs/ecryptfs_kernel.h      |    1 
 include/crypto/algapi.h            |   24 
 include/linux/crypto.h             |  148 ---
 include/linux/pfkeyv2.h            |    1 
 net/xfrm/xfrm_algo.c               |   17 
 28 files changed, 3396 insertions(+), 733 deletions(-)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
