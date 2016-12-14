From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 13:35:30 -0800
Message-ID: <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com> <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
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
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 12:55 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hey Tom,
>
> Just following up on what I mentioned in my last email...
>
> On Wed, Dec 14, 2016 at 8:35 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>> I think your suggestion for (2) will contribute to further
>> optimizations for (1). In v2, I had another patch in there adding
>> siphash_1word, siphash_2words, etc, like jhash, but I implemented it
>> by taking u32 variables and then just concatenating these into a
>> buffer and passing them to the main siphash function. I removed it
>> from v3 because I thought that these kind of missed the whole point.
>> In particular:
>>
>> a) siphash24_1word, siphash24_2words, siphash24_3words, etc should
>> take u64, not u32, since that's what siphash operates on natively
>
> I implemented these here:
> https://git.zx2c4.com/linux-dev/commit/?h=siphash&id=4652b6f3643bdba217e2194d89661348bbac48a0
>
Those look good, although I would probably just do 1,2,3 words and
then have a function that takes n words like jhash. Might want to call
these dword to distinguish from 32 bit words in jhash.

Also, what is the significance of "24" in the function and constant
names? Can we just drop that and call this siphash?

Tom

> This will be part of the next version of the series I submit. It's not
> immediately clear that using it is strictly faster than the struct
> trick though. However, I'm not yet sure why this would be.
>
> Jason
