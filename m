From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3 1/3] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 00:34:30 +0100
Message-ID: <CAHmME9pu6No0wqPzPpaBwQR_b+5CXvh0kke7J8ouN=rx4pxMGg@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
 <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
 <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com> <CA+55aFyBGQpEKiAcs0w58ZEie+L8OrWvf_2hvGx4E=L56p5hMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        David Laight <David.Laight@aculab.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54071 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933121AbcLNXef (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 18:34:35 -0500
In-Reply-To: <CA+55aFyBGQpEKiAcs0w58ZEie+L8OrWvf_2hvGx4E=L56p5hMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Linus,

On Thu, Dec 15, 2016 at 12:30 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> No. The bug is talking about "words" in the first place.
>
> Depending on your background, a "word" can be generally be either 16
> bits or 32 bits (or, in some cases, 18 bits).
>
> In theory, a 64-bit entity can be a "word" too, but pretty much nobody
> uses that. Even architectures that started out with a 64-bit register
> size and never had any smaller historical baggage (eg alpha) tend to
> call 32-bit entities "words".
>
> So 16 bits can be a word, but some people/architectures will call it a
> "half-word".
>
> To make matters even more confusing, a "quadword" is generally always
> 64 bits, regardless of the size of "word".
>
> So please try to avoid the use of "word" entirely. It's too ambiguous,
> and it's not even helpful as a "size of the native register". It's
> almost purely random.
>
> For the kernel, we tend use
>
>  - uX for types that have specific sizes (X being the number of bits)
>
>  - "[unsigned] long" for native register size
>
> But never "word".

The voice of reason. Have a desired name for this function family?

siphash_3u64s
siphash_3u64
siphash_three_u64
siphash_3sixityfourbitintegers

Or does your reasonable dislike of "word" still allow for the use of
dword and qword, so that the current function names of:

siphash_3qwords
siphash_6dwords

are okay?

Jason
