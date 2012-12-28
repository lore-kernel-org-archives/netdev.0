From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [RFC PATCH 0/3] Make rfc3686 template work with asynchronous block
 ciphers
Date: Fri, 28 Dec 2012 12:04:48 +0200
Message-ID: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure how this patchset should be dealt with (should 1st patch go
through different tree than 2nd and 3rd?), so therefore it's RFC.

Second patch makes rfc3686 template work with asynchronous block ciphers and
third patch changes aesni-intel to use this template. First patch fixed problem
in xfrm_algo found with help of 2nd and 3rd patches and without 1st patch
2nd patch breaks aes-ctr with IPSEC.


---

Jussi Kivilinna (3):
      xfrm_algo: probe asynchronous block ciphers instead of synchronous
      crypto: ctr - make rfc3686 asynchronous block cipher
      crypto: aesni-intel - remove rfc3686(ctr(aes)), utilize rfc3686 from ctr-module instead


 arch/x86/crypto/aesni-intel_glue.c |   37 --------
 crypto/ctr.c                       |  173 +++++++++++++++++++++++-------------
 crypto/tcrypt.c                    |    4 +
 crypto/tcrypt.h                    |    1 
 net/xfrm/xfrm_algo.c               |    3 -
 5 files changed, 116 insertions(+), 102 deletions(-)
