From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Fri, 16 Dec 2016 22:31:15 +0100
Message-ID: <CAHmME9qPx3WUHF3__3wNOXr-AUti4WPO1qDiFus3Zr133FyV1g@mail.gmail.com>
References: <CAHmME9q0LaxQ3uinzWyD1mDCpyeLw_2TEAN33T6dDrTKCuHs7g@mail.gmail.com>
 <20161216212528.26003.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: kernel-hardening@lists.openwall.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161216212528.26003.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi George,

On Fri, Dec 16, 2016 at 10:25 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> But yes, the sequence number is supposed to be (random base) + (timestamp).
> In the old days before Canter & Siegel when the internet was a nice place,
> people just used a counter that started at boot time.
>
> But then someone observed that I can start a connection to host X,
> see the sequence number it gives back to me, and thereby learn the
> seauence number it's using on its connections to host Y.
>
> And I can use that to inject forged data into an X-to-Y connection,
> without ever seeing a single byte of the traffic!  (If I *can* observe
> the traffic, of course, none of this makes the slightest difference.)
>
> So the random base was made a keyed hash of the endpoint identifiers.
> (Practically only the hosts matter, but generally the ports are thrown
> in for good measure.)  That way, the ISN that host X sends to me
> tells me nothing about the ISN it's using to talk to host Y.  Now the
> only way to inject forged data into the X-to-Y connection is to
> send 2^32 bytes, which is a little less practical.

Oh, okay, that is exactly what I thought was going on. I just thought
you were implying that jiffies could be moved inside the hash, which
then confused my understanding of how things should be. In any case,
thanks for the explanation.

Jason
