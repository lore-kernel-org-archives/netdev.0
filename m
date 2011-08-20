From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: Sat, 20 Aug 2011 16:44:36 -0700 (PDT)
Message-ID: <20110820.164436.684817976385970137.davem@davemloft.net>
References: <20110816103028.1360.qmail@science.horizon.com>
	<20110820233951.6428.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, dan@doxpara.com, gerrit@erg.abdn.ac.uk,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, w@1wt.eu
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697Ab1HTXqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 19:46:25 -0400
In-Reply-To: <20110820233951.6428.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "George Spelvin" <linux@horizon.com>
Date: 20 Aug 2011 19:39:51 -0400

> While the increase to 32 bits is definitely desirable, and defends
> against a much less sophisticated attack, I'm concerned that this is a
> case of robbing Peter to pay Paul.

I disagree, attacking this random number selection is much more theoretical
than the brute force attacks possible on 24-bits of entropy.

Show me a usable attack on a real system, then we can talk.

By comparison, real attacks against the 24-bit value have been
demonstrated.

> 2) Do *both*: Use a fixed 32-bit offset *plus* a time-varing one.
>    They can be added together and provide the security advantages of
>    both.  The only cost is having to compute two hashes per SYN.
> 
>    The main problem here is coming up with a hash function fast enough
>    that computing both hashes is no slower than one MD5 invocation.

Doubling the hashing cost is a non-starter.   Going to MD5 itself was
a huge lose, and was right at the brink of acceptable performance loss.

This whole change was nearly nixed because of the cost introduced
merely by going to MD5.

> 3) Extend the 24-bit time-varying hash to a 28-bit one.
>    This can cause the sequence numbers to wrap in 7/8 of the time
>    they would with a fixed offset, but that doesn't seem too bad.
>    (That's worst case; it's a triangular distribution centered
>    on 15/16.)

I want to stay with a 32-bits of entropy, thank you very much.
