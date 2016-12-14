From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH 4/3] random: use siphash24 instead
 of md5 for get_random_int/long
Date: Wed, 14 Dec 2016 18:58:47 +0100
Message-ID: <CAHmME9pyXhcqCDQXDS03tCfz_8AXWb-99KM-LFyeLHTO1+eqfg@mail.gmail.com>
References: <20161214001656.19388-1-Jason@zx2c4.com> <20161214031037.25498-1-Jason@zx2c4.com>
 <20161214163731.luj2dzmnihcuhn5p@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com,
        "Theodore Ts'o" <tytso@mit.edu>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        George Spelvin <linux@horizon.com>,
        Scott Bauer <sbauer@eng.utah.edu>,
        Andi Kleen <ak@linux.intel.com>,
        Andy Lutomirski <luto@amacapital.net>,
        Greg KH <gregkh@linuxfoundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161214163731.luj2dzmnihcuhn5p@thunk.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Ted,

On Wed, Dec 14, 2016 at 5:37 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> One somewhat undesirable aspect of the current algorithm is that we
> never change random_int_secret.

Why exactly would this be a problem? So long as the secret is kept
secret, the PRF is secure. If an attacker can read arbitrary kernel
memory, there are much much bigger issues to be concerned about. As
well, the "chaining" variable I introduce ensures that the random
numbers are, per-cpu, related to the uniqueness of timing of
subsequent calls.

> So I've been toying with the
> following, which is 4 times faster than md5.  (I haven't tried
> benchmarking against siphash yet.)
>
> [    3.606139] random benchmark!!
> [    3.606276] get_random_int # cycles: 326578
> [    3.606317] get_random_int_new # cycles: 95438
> [    3.607423] get_random_bytes # cycles: 2653388

Cool, I'll benchmark it against the siphash implementation. I like
what you did with batching up lots of chacha output, and doling it out
bit by bit. I suspect this will be quite fast, because with chacha20
you get an entire block.

> P.S.  It's interesting to note that siphash24 and chacha20 are both
> add-rotate-xor based algorithms.

Quite! Lots of nice shiny things are turning out be be ARX -- ChaCha,
BLAKE2, Siphash, NORX. The simplicity is really appealing.

Jason
