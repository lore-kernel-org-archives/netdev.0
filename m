From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 13:37:51 -0500
Message-ID: <20161221183751.1123.qmail@ns.sciencehorizons.net>
References: <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: eric.dumazet@gmail.com, Jason@zx2c4.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Now I am quite confused.
>
> George said :
>> Cycles per byte on 1024 bytes of data:
>>                       Pentium Core 2  Ivy
>>                       4       Duo     Bridge
>> SipHash-2-4           38.9     8.3     5.8
>> HalfSipHash-2-4       12.7     4.5     3.2
>> MD5                    8.3     5.7     4.7
>
> That really was for 1024 bytes blocks, so pretty much useless for our
> discussion ?

No, they're actually quite relevant, but you have to interpret them
correctly.  I thought I explained in the text following that table,
but let me make it clearer:

To find the time to compute the SipHash of N bytes, round (N+17) up to
the next multiple of 8 bytes and multiply by the numbers above.

To find the time to compute the HalfSipHash of N bytes, round (N+9) up to
the next multiple of 4 bytes and multiply by the numbers above.

To find the time to compute the MD5 of N bytes, round (N+9) up to the
next multiple of 64 bytes and multiply by the numbers above.

It's the different rounding rules that make all the difference.  For small
input blocks, SipHash can be slower per byte yet still faster because
it hashes fewer bytes.

> Reading your numbers last week, I thought SipHash was faster, but George
> numbers are giving the opposite impression.

SipHash annihilates the competition on 64-bit superscalar hardware.
SipHash dominates the field on 64-bit in-order hardware.
SipHash wins easily on 32-bit hardware *with enough registers*.
On register-starved 32-bit machines, it really struggles.

As I explained, in that last case, SipHash barely wins at all.
(On a P4, it actually *loses* to MD5, not that anyone cares.  Running
on a P4 and caring about performance are mutually exclusive.)
