From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 23:56:41 +0100
Message-ID: <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com> <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Tom,

On Wed, Dec 14, 2016 at 10:35 PM, Tom Herbert <tom@herbertland.com> wrote:
> Those look good, although I would probably just do 1,2,3 words and
> then have a function that takes n words like jhash. Might want to call
> these dword to distinguish from 32 bit words in jhash.

So actually jhash_Nwords makes no sense, since it takes dwords
(32-bits) not words (16-bits). The siphash analog should be called
siphash24_Nqwords.

I think what I'll do is change what I already have to:
siphash24_1qword
siphash24_2qword
siphash24_3qword
siphash24_4qword

And then add some static inline helpers to assist with smaller u32s
like ipv4 addresses called:

siphash24_2dword
siphash24_4dword
siphash24_6dword
siphash24_8dword

While we're having something new, might as well call it the right thing.


> Also, what is the significance of "24" in the function and constant
> names? Can we just drop that and call this siphash?

SipHash is actually a family of PRFs, differentiated by the number of
SIPROUNDs after each 64-bit input is processed and the number of
SIPROUNDs at the very end of the function. The best trade-off of speed
and security for kernel usage is 2 rounds after each 64-bit input and
4 rounds at the end of the function. This doesn't fall to any known
cryptanalysis and it's very fast.
