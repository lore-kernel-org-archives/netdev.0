From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 4 Nov 2007 01:54:33 +0100
Message-ID: <200711040154.33316.ak@suse.de>
References: <4729A774.9030409@cosmosbay.com> <200711040018.15027.ak@suse.de> <20071103.162337.83099185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33521 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197AbXKDAyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 20:54:37 -0400
In-Reply-To: <20071103.162337.83099185.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > Also the EHASH_LOCK_SZ == 0 special case is a little strange. Why did
> > you add that?
> 
> He explained this in another reply, because ifdefs are ugly.

I meant why having it at all? 

> Any use that makes 
> "sense" is a case where the code should be rewritten to decrease the
> lock hold time or convert to RCU.

I don't think RCU would be really needed for single entry buckets (which
are common) if they are special cased. After all it would be just
a single pointer. Perhaps one could distingush this case e.g. by 
setting the low order bit of the hash bucket pointer.

In fact to optimize for this case it might be an interesting
experiment to go towards an closed hash table and allocate the sockets
in page sized objects and then remap them directly into a virtual
continuous table similar to the new vmemmap code (need to try this at some 
point). 

-Andi
