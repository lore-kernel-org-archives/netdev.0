From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 15 Dec 2016 18:28:40 -0500
Message-ID: <20161215232840.22459.qmail@ns.sciencehorizons.net>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
Cc: djb@cr.yp.to
To: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If a halved version of SipHash can bring significant performance boost
> (with 32b words instead of 64b words) with an acceptable security level
> (64-bit enough?) then we may design such a version.

I was thinking if the key could be pushed to 80 bits, that would be nice,
but honestly 64 bits is fine.  This is DoS protection, and while it's
possible to brute-force a 64 bit secret, there are more effective (DDoS)
attacks possible for the same cost.

(I'd suggest a name of "HalfSipHash" to convey the reduced security
effectively.)

> Regarding output size, are 64 bits sufficient?

As a replacement for jhash, 32 bits are sufficient.  It's for
indexing an in-memory hash table on a 32-bit machine.


(When you're done thinking about this, as a matter of personal interest
I'd love a hash expert's opinion on
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2a18da7a9c7886f1c7307f8d3f23f24318583f03
and
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8387ff2577eb9ed245df9a39947f66976c6bcd02
which is a non-cryptographic hash function of novel design that's
inspired by SipHash.)
