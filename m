From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Mon, 23 Sep 2013 21:39:51 -0400 (EDT)
Message-ID: <20130923.213951.458607592939783973.davem@davemloft.net>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<1379980991.3165.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab3IXBjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 21:39:54 -0400
In-Reply-To: <1379980991.3165.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Sep 2013 17:03:11 -0700

> 1) Security alert here.
> 
> Many devices (lets say Android phones) have no entropy at this point,
> all devices will have same toeplitz key.
> 
> Check build_ehash_secret() for a possible point for the feeding of the
> key. (and commit 08dcdbf6a7b9d14c2302c5bd0c5390ddf122f664 )
> 
> If hardware toeplitz is ever used, we want to make sure every host uses
> a private and hidden Toeplitz key.
> 
> 2) Also it seems a given tuple would hash the same on different
> namespaces. Could be a problem if one particular TCP hash bucket is
> holding thousand of sockets.
> 
> 3) jhash() is fast, there is no possible cache line misses

4) Random input to the hash is now not used at all, instant exploit
   because now any attacker can open up connections over and over that
   will all hash to the same hash bucket making our lookups linear.
