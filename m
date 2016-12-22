From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v7 6/6] siphash: implement HalfSipHash1-3 for hash tables
Date: Wed, 21 Dec 2016 16:46:35 -0800
Message-ID: <20161222004635.GV8388@tassilo.jf.intel.com>
References: <20161216030328.11602-1-Jason@zx2c4.com>
 <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-7-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        linux-crypto@vger.kernel.org,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        edumazet@google.com,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        luto@amacapital.net,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161221230216.25341-7-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 64-bit x86_64:
> [    0.509409] test_siphash:     SipHash2-4 cycles: 4049181
> [    0.510650] test_siphash:     SipHash1-3 cycles: 2512884
> [    0.512205] test_siphash: HalfSipHash1-3 cycles: 3429920
> [    0.512904] test_siphash:    JenkinsHash cycles:  978267

I'm not sure what these numbers mean. Surely a single siphash2-4
does not take 4+ million cycles? 

If you run them in a loop please divide by the iterations.

But generally running small code in a loop is often an unrealistic
benchmark strategy because it hides cache misses, primes
predictors, changes frequencies and changes memory costs,
but also can overload pipelines and oversubscribe
resources.

[see also page 46+ in http://halobates.de/applicative-mental-models.pdf]

So the numbers you get there are at least somewhat
dubious. It would be good to have at least some test which
is not just a tiny micro benchmark to compare before making
conclusions.

-Andi
