From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 8/8] crypto/testmgr: Allocate only the required output
 size for hash tests
Date: Wed, 11 Jan 2017 23:52:03 -0800
Message-ID: <CALCETrWZuHmZHzOUVp4J9cw9ajfS2JVr0fLyV0tyoyybGkCBqA@mail.gmail.com>
References: <890f4bdb28a1cf72f6b802b220b35ebaf0f76bb9.1484090585.git.luto@kernel.org>
 <20170112074752.GA14230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112074752.GA14230@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2017 at 11:47 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> Andy Lutomirski <luto@kernel.org> wrote:
>> There are some hashes (e.g. sha224) that have some internal trickery
>> to make sure that only the correct number of output bytes are
>> generated.  If something goes wrong, they could potentially overrun
>> the output buffer.
>>
>> Make the test more robust by allocating only enough space for the
>> correct output size so that memory debugging will catch the error if
>> the output is overrun.
>>
>> Tested by intentionally breaking sha224 to output all 256
>> internally-generated bits while running on KASAN.
>>
>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>
> This patch doesn't seem to depend on anything else in the series.
> Do you want me to take it separately?

Yes, please.  Its only relation to the rest of the series is that I
wanted to make sure that I didn't mess up sha224's finalization code.

--Andy
