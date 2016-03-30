From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Wed, 30 Mar 2016 22:09:33 +0800
Message-ID: <20160330140933.GA19606@gondor.apana.org.au>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com>
 <1459329252.2055.1.camel@sipsolutions.net>
 <20160330135521.GA19423@gondor.apana.org.au>
 <1459346588.2055.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53620 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbcC3OJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 10:09:40 -0400
Content-Disposition: inline
In-Reply-To: <1459346588.2055.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 04:03:08PM +0200, Johannes Berg wrote:
> 
> But we really don't want that either - in the normal case where you
> don't create all these virtual interfaces for testing, you have a
> certain number of peers that can vary a lot (zero to hundreds, in
> theory thousands) where you *don't* have the same key, so we still want
> to have the rehashing if the chains get longer in that case.

insecure_elasticity only disables rehashing without growing, it
does not inhibit table expansion which is driven by the number of
objects in the whole table.

> It's really just the degenerate case that Ben is creating locally
> that's causing a problem, afaict, though it's a bit disconcerting that
> rhashtable in general can cause strange failures at delete time.

The failure is simple, rhashtable will rehash the table if a given
chain becomes too long.  This simply doesn't work if you hash many
objects with the same key since the chain will never get shorter
even after a rehash (or expansion).

Therefore if your hashtable has to do this then you have to disable
the rehash logic using the insecure_elasticity flag.

Alternatively you can construct your own linked list for objects
with the same key outside of rhashtable and hash the list instead.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
