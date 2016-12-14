From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 00:17:18 +0100
Message-ID: <CAHmME9qNcsXtdWO_rmngSXXeBsTbA9B_33oLJ_pWOWcO7P2JZg@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
 <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
 <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com> <CALx6S349hOFhnMgM_TgKXC1O7bmOvR87Nm=5B7_sNLEWiZU8Zg@mail.gmail.com>
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
In-Reply-To: <CALx6S349hOFhnMgM_TgKXC1O7bmOvR87Nm=5B7_sNLEWiZU8Zg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Tom,

On Thu, Dec 15, 2016 at 12:14 AM, Tom Herbert <tom@herbertland.com> wrote:
> I'm confused, doesn't 2dword == 1qword? Anyway, I think the qword
> functions are good enough. If someone needs to hash over some odd
> length they can either put them in a structure padded to 64 bits or
> call the hash function that takes a byte length.

Yes. Here's an example:

static inline u64 siphash24_2dwords(const u32 a, const u32 b, const u8
key[SIPHASH24_KEY_LEN])
{
       return siphash24_1qword(((u64)b << 32) | a, key);
}

This winds up being extremely useful and syntactically convenient in a
few places. Check out my git branch in about 10 minutes or wait for v4
to be posted tomorrow; these are nice helpers.

> I'd still drop the "24" unless you really think we're going to have
> multiple variants coming into the kernel.

Okay. I don't have a problem with this, unless anybody has some reason
to the contrary.

Jason
