From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 12:57:44 -0800
Message-ID: <CALx6S370xBZr2UzzuVb2t5L+S6JQwVKTZZfOA4vBALjJ3ojREQ@mail.gmail.com>
References: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
 <20161216204128.25034.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>, vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35234 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753897AbcLPU5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 15:57:45 -0500
Received: by mail-qk0-f195.google.com with SMTP id n204so13131069qke.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 12:57:45 -0800 (PST)
In-Reply-To: <20161216204128.25034.qmail@ns.sciencehorizons.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 12:41 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Tom Herbert wrote:
>> Tested this. Distribution and avalanche effect are still good. Speed
>> wise I see about a 33% improvement over siphash (20 nsecs/op versus 32
>> nsecs). That's about 3x of jhash speed (7 nsecs). So that might closer
>> to a more palatable replacement for jhash. Do we lose any security
>> advantages with halfsiphash?
>
> What are you testing on?  And what input size?  And does "33% improvement"
> mean 4/3 the rate and 3/4 the time?  Or 2/3 the time and 3/2 the rate?
>
Sorry, that is over an IPv4 tuple. Intel(R) Xeon(R) CPU E5-2660 0 @
2.20GHz. Recoded the function I was using to look like more like 64
bit version and yes it is indeed slower.

> These are very odd results.  On a 64-bit machine, SipHash should be the
> same speed per round, and faster because it hashes more data per round.
> (Unless you're hitting some unexpected cache/decode effect due to REX
> prefixes.)
>
> On a 32-bit machine (other than ARM, where your results might make sense,
> or maybe if you're hashing large amounts of data), the difference should
> be larger.
>
> And yes, there is a *significant* security loss.  SipHash is 128 bits
> ("don't worry about it").  hsiphash is 64 bits, which is known breakable
> ("worry about it"), so we have to do a careful analysis of the cost of
> a successful attack.
>
> As mentioned in the e-mails that just flew by, hsiphash is intended
> *only* for 32-bit machines which bog down on full SipHash.  On all 64-bit
> machines, it will be implemented as an alias for SipHash and the security
> concerns will Just Go Away.
>
> The place where hsiphash is expected to make a big difference is 32-bit
> x86.  If you only see 33% difference with "gcc -m32", I'm going to be
> very confused.
