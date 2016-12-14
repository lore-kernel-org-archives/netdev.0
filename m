From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Wed, 14 Dec 2016 12:21:15 +0100
Message-ID: <516c5633-14c2-ee18-90e4-84d73870ba2c@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46165 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932461AbcLNLVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 06:21:19 -0500
In-Reply-To: <20161214035927.30004-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 14.12.2016 04:59, Jason A. Donenfeld wrote:
> SipHash is a 64-bit keyed hash function that is actually a
> cryptographically secure PRF, like HMAC. Except SipHash is super fast,
> and is meant to be used as a hashtable keyed lookup function.

Can you show or cite benchmarks in comparison with jhash? Last time I
looked, especially for short inputs, siphash didn't beat jhash (also on
all the 32 bit devices etc.).

> SipHash isn't just some new trendy hash function. It's been around for a
> while, and there really isn't anything that comes remotely close to
> being useful in the way SipHash is. With that said, why do we need this?
> 
> There are a variety of attacks known as "hashtable poisoning" in which an
> attacker forms some data such that the hash of that data will be the
> same, and then preceeds to fill up all entries of a hashbucket. This is
> a realistic and well-known denial-of-service vector.

This pretty much depends on the linearity of the hash function? I don't
think a crypto secure hash function is needed for a hash table. Albeit I
agree that siphash certainly looks good to be used here.

> Linux developers already seem to be aware that this is an issue, and
> various places that use hash tables in, say, a network context, use a
> non-cryptographically secure function (usually jhash) and then try to
> twiddle with the key on a time basis (or in many cases just do nothing
> and hope that nobody notices). While this is an admirable attempt at
> solving the problem, it doesn't actually fix it. SipHash fixes it.

I am pretty sure that SipHash still needs a random key per hash table
also. So far it was only the choice of hash function you are questioning.

> (It fixes it in such a sound way that you could even build a stream
> cipher out of SipHash that would resist the modern cryptanalysis.)
> 
> There are a modicum of places in the kernel that are vulnerable to
> hashtable poisoning attacks, either via userspace vectors or network
> vectors, and there's not a reliable mechanism inside the kernel at the
> moment to fix it. The first step toward fixing these issues is actually
> getting a secure primitive into the kernel for developers to use. Then
> we can, bit by bit, port things over to it as deemed appropriate.

Hmm, I tried to follow up with all the HashDoS work and so far didn't
see any HashDoS attacks against the Jenkins/SpookyHash family.

If this is an issue we might need to also put those changes into stable.

> Dozens of languages are already using this internally for their hash
> tables. Some of the BSDs already use this in their kernels. SipHash is
> a widely known high-speed solution to a widely known problem, and it's
> time we catch-up.

Bye,
Hannes
