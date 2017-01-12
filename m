From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net-next 1/4] siphash: add cryptographically secure PRF
Date: Thu, 12 Jan 2017 19:30:17 +0100
Message-ID: <CAHmME9ocpbm_pafLv40VKgR0AJ1fbphjO-gwtddZJ3v8maLgvQ@mail.gmail.com>
References: <20170107040459.GA575@zzz> <20170112150417.GA15951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Biggers <ebiggers3@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112150417.GA15951@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 4:04 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> typedef struct {
>>        u64 v[2];
>> } siphash_key_t;
>
> If it's just an 128-bit value then we have u128 in crypto/b128ops.h
> that could be generalised for this.

Nope, it's actually two 64-bit values. Yes, the user fills it in as
one blob to get_random_bytes, but it's used internally by the
algorithm as two distinct variables (which conveniently fit into
64-bit registers).
