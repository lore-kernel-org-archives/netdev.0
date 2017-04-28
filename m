From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 0/7] crypto: aesni: provide generic gcm(aes)
Date: Fri, 28 Apr 2017 18:11:55 +0200
Message-ID: <cover.1493395785.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current aesni AES-GCM implementation only offers support for
rfc4106(gcm(aes)).  This makes some things a little bit simpler
(handling of associated data and authentication tag), but it means
that non-IPsec users of gcm(aes) have to rely on
gcm_base(ctr-aes-aesni,ghash-clmulni), which is much slower.

This patchset adds handling of all valid authentication tag lengths
and of any associated data length to the assembly code, and exposes a
generic gcm(aes) AEAD algorithm to the crypto API.

With these patches, performance of MACsec on a single core increases
by 40% (from 4.5Gbps to around 6.3Gbps).

Sabrina Dubroca (7):
  crypto: aesni: make non-AVX AES-GCM work with any aadlen
  crypto: aesni: make non-AVX AES-GCM work with all valid auth_tag_len
  crypto: aesni: make AVX AES-GCM work with any aadlen
  crypto: aesni: make AVX AES-GCM work with all valid auth_tag_len
  crypto: aesni: make AVX2 AES-GCM work with any aadlen
  crypto: aesni: make AVX2 AES-GCM work with all valid auth_tag_len
  crypto: aesni: add generic gcm(aes)

 arch/x86/crypto/aesni-intel_asm.S        | 231 +++++++++++++++++++------
 arch/x86/crypto/aesni-intel_avx-x86_64.S | 283 ++++++++++++++++++++++---------
 arch/x86/crypto/aesni-intel_glue.c       | 208 +++++++++++++++++------
 3 files changed, 539 insertions(+), 183 deletions(-)

-- 
2.12.2
