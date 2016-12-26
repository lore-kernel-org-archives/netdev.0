From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [RFC PATCH 4.10 1/6] crypto/sha256: Refactor the API so it can be
 used without shash
Date: Mon, 26 Dec 2016 17:51:14 +0000
Message-ID: <CAKv+Gu-NMNCEs61f4k7JSf9iSJ1A_Gy1r=kZRGqtbDsEDz7--Q@mail.gmail.com>
References: <cover.1482545792.git.luto@kernel.org> <942b91f25a63b22ec4946378a1fffe78d655cf18.1482545792.git.luto@kernel.org>
 <CAKv+Gu-UCqwchgbhg8VN4s=Yxk=PkjXG46NZo=8P4wAQtJ2TXw@mail.gmail.com>
 <CALCETrVbT_1=cdU1+a-+KbhoFqeT3XvbHjY0s_U7C5JVgiPx_Q@mail.gmail.com> <20161226075757.GA8916@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
        Andy Lutomirski <luto@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161226075757.GA8916@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 December 2016 at 07:57, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sat, Dec 24, 2016 at 09:57:53AM -0800, Andy Lutomirski wrote:
>>
>> I actually do use incremental hashing later on.   BPF currently
>> vmallocs() a big temporary buffer just so it can fill it and hash it.
>> I change it to hash as it goes.
>
> How much data is this supposed to hash on average? If it's a large
> amount then perhaps using the existing crypto API would be a better
> option than adding this.
>

This is a good point actually: you didn't explain *why* BPF shouldn't
depend on the crypto API.
