From: "George Spelvin" <linux@horizon.com>
Subject: Re: Where exactly will arch_fast_hash be used
Date: 7 Dec 2014 08:23:05 -0500
Message-ID: <20141207132305.24691.qmail@ns.horizon.com>
References: <20141207125157.GA9745@gondor.apana.org.au>
Cc: davem@davemloft.net, dborkman@redhat.com,
	hannes@stressinduktion.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: herbert@gondor.apana.org.au, linux@horizon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141207125157.GA9745@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> How does this implicate the low bits specifically?

> If you can easily deduce the pre-images that make the last bit
> of the hash even or odd, then you've just cut your search space
> for collisions by half.  The real killer is that you can do this
> without knowing what the secret is.

Um, yes, if you're in a situation where a hash collsion DoS is possible,
a CRC is disastrous choice.  You can trivially find collisions for *all*
bits of a CRC.  Low or high, they're all equally easy.

When you said
>>>>> Even if security wasn't an issue, straight CRC32 has really poor
>>>>> lower-order bit distribution, which makes it a terrible choice for
>>>>> a hash table that simply uses the lower-order bits.

This is talking about:
- Non-malicious inputs,where security isn't an issue, and
- Low-order bits specifically, implying that the high-order bits are different.

*That's* the claim I'm curious about.  I know perfectly well that if
security *is* an issue, a fixed-polynomial CRC is a disaser.

But for non-malicious inputs, like normal software identifiers, a CRC
actually works very well.


If you want to do secure hashing with a CRC, you need to have a secret
*polynomial*.  That *is* provably secure (it's a universal family of hash
functions), but isn't provided by x86 unless you use SSE and PCLMUL.

That's why it's a non-cryptographic hash, suitable for non-malicious
inputs only.  That's the same security claim as many other common hash
functions.

> Our entire scheme is dependent on using the secret to defeat
> would-be attackers.  If CRC does not make effective use of the
> secret, then we're essentially naked against attackers.

Okay, I'm confused.  *What* scheme?  The arch_fast_hash interface doesn't
have any provision for a secret.  Because there's no point to having one;
you can't change the polynomial, and anything additive has just moves
collisions around without reducing them.

So there are plenty of hash tables in Linux that you don't dare use this
with.  In fact, so many that, as you rightly point out, it's not clear
if it's worth providing this special optimization for the few remaining.
