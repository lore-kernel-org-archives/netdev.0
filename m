From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 17:06:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0241238@AcuExch.aculab.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161215232840.22459.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "djb@cr.yp.to" <djb@cr.yp.to>
To: 'George Spelvin' <linux@sciencehorizons.net>,
        "ak@linux.intel.com" <ak@linux.intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "ebiggers3@gmail.com" <ebiggers3@gmail.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "Jason@zx2c4.com" <Jason@zx2c4.com>,
        "jeanphilippe.aumasson@gmail.com" <jeanphilippe.aumasson@gmail.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "luto@amacapital.net" <luto@amacapital.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tom@herbertland.com" <tom@herbertland.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "tytso@mit.edu" <tytso
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161215232840.22459.qmail@ns.sciencehorizons.net>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin
> Sent: 15 December 2016 23:29
> > If a halved version of SipHash can bring significant performance boost
> > (with 32b words instead of 64b words) with an acceptable security level
> > (64-bit enough?) then we may design such a version.
> 
> I was thinking if the key could be pushed to 80 bits, that would be nice,
> but honestly 64 bits is fine.  This is DoS protection, and while it's
> possible to brute-force a 64 bit secret, there are more effective (DDoS)
> attacks possible for the same cost.

A 32bit hash would also remove all the issues about the alignment
of IP addresses (etc) on 64bit systems.

> (I'd suggest a name of "HalfSipHash" to convey the reduced security
> effectively.)
> 
> > Regarding output size, are 64 bits sufficient?
> 
> As a replacement for jhash, 32 bits are sufficient.  It's for
> indexing an in-memory hash table on a 32-bit machine.

It is also worth remembering that if the intent is to generate
a hash table index (not a unique fingerprint) you will always
get collisions on the final value.
Randomness could still give overlong hash chains - which might
still need rehashing with a different key.

	David
