From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 10:58:55 +0200
Message-ID: <1474275535.4469.14.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <1474273219.4469.7.camel@sipsolutions.net>
         <1474273518.4469.8.camel@sipsolutions.net>
         <20160919083518.GA11821@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        tom@herbertland.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49892 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751129AbcISI7C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 04:59:02 -0400
In-Reply-To: <20160919083518.GA11821@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > I take that back. I think it's leaking memory - my tests never used
> > to run out of memory, but now they eventually do.
> 
> > I'll try to figure out more.
> 
> Interesting.  The kernel test robot found a bug in the insertion
> slowpath where we end up inserting without taking the inner spinlock
> in case of a nested table.  Not sure whether that's the same issue
> as you're seeing but I'll do a v2 posting.

Increasing the memory for the VMs from 384MB to 512MB didn't avoid the
issue, so there's a definite leak somewhere, although this time fewer
VMs crashed :)

Reverting the patches and running with 384MB then works, so it's not
something else added in the meantime (I ran last a few days ago, but
don't think I merged anything interesting in the meantime).

I'll test your new patches in a minute.

johannes
