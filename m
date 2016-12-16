From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v6 3/5] random: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 23:23:59 +0100
Message-ID: <CAHmME9pip1w3fYKKZ==RUYss+GZmQ1w3kjT4Lgvkxi_=SyK+wg@mail.gmail.com>
References: <CAHmME9rbKi3O1SS89LRMEUeMdKyrdutXAfjb9QmW3KNoCuE-wg@mail.gmail.com>
 <CALCETrX9v=Uwd1zZub=QpD73Lq0LM67NEi1qwqRUjtD5U1bHYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrX9v=Uwd1zZub=QpD73Lq0LM67NEi1qwqRUjtD5U1bHYw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

> Agreed.  A simpler contruction would be:
>
> chaining++;
> output = H(chaining, secret);
>
> And this looks a whole lot like Ted's ChaCha20 construction.

In that simpler construction with counter-based secret rekeying and in
Ted's ChaCha20 construction, the issue is that every X hits, there's a
call to get_random_bytes, which has variable performance and entropy
issues. Doing it my way with it being time based, in the event that
somebody runs ` :(){ :|:& };:`, system performance doesn't suffer
because ASLR is making repeated calls to get_random_bytes every 128 or
so process creations. In the time based way, the system performance
will not suffer.

Jason
