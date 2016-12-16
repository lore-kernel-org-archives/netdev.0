From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Fri, 16 Dec 2016 01:03:12 +0100
Message-ID: <0397a465-62f9-c956-82e2-a874fd56ffe8@stressinduktion.org>
References: <CAHmME9p9cf1W3vhbu=YTRY1Xt=fmE1sVqY1XPt5iQwxfCfQUOA@mail.gmail.com>
 <e574d97f-e0b4-f5e2-6d60-88d3ce185249@stressinduktion.org>
 <CAHmME9rF0pKxfc3p9ThD3LZU2+ZNPeR-4=9MVEE3AJQKBMNA+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9rF0pKxfc3p9ThD3LZU2+ZNPeR-4=9MVEE3AJQKBMNA+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.12.2016 00:43, Jason A. Donenfeld wrote:
> Hi Hannes,
> 
> Good news.
> 
> On Thu, Dec 15, 2016 at 10:45 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>>> How's that sound?
>>
>> I am still very much concerned about the API.
> 
> Thanks for pushing me and putting up with my daftness... the constant
> folding works absolutely perfectly. I've run several tests. When gcc
> knows that a struct is aligned (say, via __aligned(8)), then it erases
> the branch and makes a direct jump to the aligned code. When it's
> uncertain, it evaluates at runtime. So, now there is a single
> siphash() function that chooses the best one automatically. Behind the
> scene there's siphash_aligned and siphash_unaligned, but nobody needs
> to call these directly. (Should I rename these to have a double
> underscore prefix?) On platforms that have
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS, of course all of this
> disappears and everything goes directly to the aligned version.
> 
> So, I think this assuages your concerns entirely. A single API entry
> point that does the right thing.
> 
> Whew! Good thinking, and thanks again for the suggestion.

Awesome, thanks for trying this out. This basically resolves my concern
API-wise so far.

Hannes out. ;)
