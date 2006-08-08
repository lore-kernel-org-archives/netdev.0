From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 01:23:01 +0200
Message-ID: <200608090123.01123.ak@suse.de>
References: <44D75EF8.1070901@sw.ru> <200608080711.06788.ak@suse.de> <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:14012 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1030357AbWHIAAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 20:00:38 -0400
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> >
> > IMHO there needs to be a maximum size (maybe related to the sum of
> > caches of all CPUs in the system?)
> >
> > Best would be to fix this for all large system hashes together.
> 
> How about using an algorithm like this: up to a certain "size"
> (memory size, cache size,...), scale the hash tables linearly; 
> but for larger sizes, scale logarithmically (or approximately
> logarithmically)

I don't think it makes any sense to continue scaling at all after
some point - you won't get better shorter hash chains anymore and the 
large hash tables actually cause problems: e.g. there are situations where we walk
the complete tables and that takes longer and longer.

Also does a 1TB machine really need bigger hash tables than a 100GB one?

The problem is to find out what a good boundary is.

-Andi
