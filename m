From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 10:55:40 -0500
Message-ID: <20161221155540.29529.qmail@ns.sciencehorizons.net>
References: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, linux@sciencehorizons.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually, DJB just made a very relevant suggestion.

As I've mentioned, the 32-bit performance problems are an x86-specific
problem.  ARM does very well, and other processors aren't bad at all.

SipHash fits very nicely (and runs very fast) in the MMX registers.

They're 64 bits, and there are 8 of them, so the integer registers can
be reserved for pointers and loop counters and all that.  And there's
reference code available.

How much does kernel_fpu_begin()/kernel_fpu_end() cost?

Although there are a lot of pre-MMX x86es in embedded control applications,
I don't think anyone is worried about their networking performance.
(Specifically, all of this affects only connection setup, not throughput 
on established connections.)
