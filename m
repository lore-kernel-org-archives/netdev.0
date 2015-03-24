From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 9/10] rhashtable: Allow GFP_ATOMIC bucket table
 allocation
Date: Tue, 24 Mar 2015 14:09:13 +1100
Message-ID: <20150324030913.GA8184@gondor.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
 <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB077F0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56788 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbCXDJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 23:09:43 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB077F0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 12:53:11PM +0000, David Laight wrote:
>
> Given the lock is only used for insert and delete, I'm also not at
> all clear why you allocate 128 locks per cpu for very large tables.
> With the locks in their own array I don't think there can be 'false
> sharing', the worst than can happen is two cpus spinning on locks
> in the same cache line.

Personally I'm totally against Bucket locks.  If you have a
scalability problem you really need to solve them at a higher
level, e.g., multiqueue transmission in networking.  Bucket
locks are simply kicking the can down the road, it'll come back
to bite you sooner or later in terms of scalability.

So no I'm not going to waste my time fixing up something that
in my opinion shouldn't even exist :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
