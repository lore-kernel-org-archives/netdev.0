From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 3/4] secure_seq: use siphash24 instead of md5_transform
Date: Wed, 14 Dec 2016 22:01:29 +0100
Message-ID: <CAHmME9qtRC5daEPgDEtNgP9tEajd=xRG=qkHE5XoOMA_zAeysw@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <20161214035927.30004-3-Jason@zx2c4.com>
 <CAHmME9pEM=cDC5S=j1BU2oCF8-WdnbRfiVojcet4rXcRLcpJRw@mail.gmail.com> <CALx6S37mGaLJoacxyu3_ZQANSNz9UU38-b-V6g1nma=Gye3pjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Andi Kleen <ak@linux.intel.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S37mGaLJoacxyu3_ZQANSNz9UU38-b-V6g1nma=Gye3pjw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2016 at 9:12 PM, Tom Herbert <tom@herbertland.com> wrote:
> If you pad the data structure to 64 bits then we can call the version
> of siphash that only deals in 64 bit words. Writing a zero in the
> padding will be cheaper than dealing with odd lengths in siphash24.
On Wed, Dec 14, 2016 at 9:27 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> What I don't really understand is that the addition of this complexity
> actually reduces the performance, as you have to take the "if (left)"
> branch during hashing and causes you to make a load_unaligned_zeropad.

Oh, duh, you guys are right. Fixed in my repo [1]. I'll submit the
next version in a day or so to let some other comments come in.

Thanks again for your reviews.

Jason

[1] https://git.zx2c4.com/linux-dev/log/?h=siphash
