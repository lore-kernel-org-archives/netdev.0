From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: 20 Aug 2011 20:49:39 -0400
Message-ID: <20110821004939.10392.qmail@science.horizon.com>
References: <20110820.164436.684817976385970137.davem@davemloft.net>
Cc: dan@doxpara.com, gerrit@erg.abdn.ac.uk,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	mpm@selenic.com, netdev@vger.kernel.org, w@1wt.eu
To: davem@davemloft.net, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:42357 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751774Ab1HUAtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 20:49:41 -0400
In-Reply-To: <20110820.164436.684817976385970137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> While the increase to 32 bits is definitely desirable, and defends
>> against a much less sophisticated attack, I'm concerned that this is a
>> case of robbing Peter to pay Paul.

> I disagree, attacking this random number selection is much more theoretical
> than the brute force attacks possible on 24-bits of entropy.

Can you explain more precisely what you disagree with?

What you state after the comma appears to be agreeing with what I
wrote (it seems like a restatement of my first two clauses), so I'm
unenlightened as to where the disagreement is.

I'm not saying you didn't address a real problem, just that fixing
one problem exposed another, and it would be nice to address *both*.

> Show me a usable attack on a real system, then we can talk.

If you like.  It's about a week of implementation work.  (And I
don't have 1 week/week of free time, so more than that elapsed.)

> By comparison, real attacks against the 24-bit value have been
> demonstrated.

Anywhere that I can see?

>> 2) Do *both*: Use a fixed 32-bit offset *plus* a time-varing one.
>>    They can be added together and provide the security advantages of
>>    both.  The only cost is having to compute two hashes per SYN.
>> 
>>    The main problem here is coming up with a hash function fast enough
>>    that computing both hashes is no slower than one MD5 invocation.

> Doubling the hashing cost is a non-starter.   Going to MD5 itself was
> a huge lose, and was right at the brink of acceptable performance loss.
> 
> This whole change was nearly nixed because of the cost introduced
> merely by going to MD5.

Okay, I'll make certain a proposed solution is strictly faster than MD5.
I was asking about performance goals, and you've given me an answer.
Thank you very much!

The patch comment was fairly offhand about the performance cost, and
prior discussion was apparently private, so it wasn't clear how much
pain people experienced.

My only other question is whether IPv6 on x86-32 specificaly needs to be
faster than MD5.  Is that negotiable, or is that also a hard limit?
(This is challenging because it's trying to hash 288 bits of address material
in 224 bits of available registers.)

Eureka!  The possible source addresses are very limited.  It's possible to
pre-hash them, then you only have 160 bits of per-connection variability,
which can fit in a second hash block.

This requires finding somewhere in the network stack to store the
pre-hashed IPv6 addresses, as well as a fallback to use when spoofing
other source addresses, but that shouldn't be TOO difficult.

>> 3) Extend the 24-bit time-varying hash to a 28-bit one.
>>    This can cause the sequence numbers to wrap in 7/8 of the time
>>    they would with a fixed offset, but that doesn't seem too bad.
>>    (That's worst case; it's a triangular distribution centered
>>    on 15/16.)

> I want to stay with a 32-bits of entropy, thank you very much.

My goal is to give you *both*.  32 bits fixed + 28 bits time-varying.
An attacker would have to cryptanalyze the 32 bits (which the 28 bits
makes harder) *and* brute-force the 28 bits.

(It's almost certainly simpler to brute-force 32 bits.)


Thank you for your response!
