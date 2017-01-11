From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 8/8] crypto/testmgr: Allocate only the required
 output size for hash tests
Date: Wed, 11 Jan 2017 15:13:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB025EE7B@AcuExch.aculab.com>
References: <cover.1484090585.git.luto@kernel.org>
 <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        "Eric Biggers" <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: 'Andy Lutomirski' <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski
> Sent: 10 January 2017 23:25
> There are some hashes (e.g. sha224) that have some internal trickery
> to make sure that only the correct number of output bytes are
> generated.  If something goes wrong, they could potentially overrun
> the output buffer.
> 
> Make the test more robust by allocating only enough space for the
> correct output size so that memory debugging will catch the error if
> the output is overrun.

Might be better to test this by allocating an overlong buffer
and then explicitly checking that the output hasn't overrun
the allowed space.

If nothing else the error message will be clearer.

	David
