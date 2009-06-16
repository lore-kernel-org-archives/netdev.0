From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 12:08:29 -0700 (PDT)
Message-ID: <20090616.120829.182011393.davem@davemloft.net>
References: <4A37A058.1030701@gmail.com>
	<4A37AA0C.40507@gmail.com>
	<alpine.LFD.2.01.0906161155400.3282@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mingo@elte.hu, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759965AbZFPTI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 15:08:26 -0400
In-Reply-To: <alpine.LFD.2.01.0906161155400.3282@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Jun 2009 11:59:34 -0700 (PDT)

> At the very least, add a helper function for "do I actually have 
> outstanding allocations" or something like that. IOW, do a 
> 
> 	/*
> 	 * Comment here about that magical "1"
> 	 */
> 	static inline int sk_has_allocations(struct sock *sk)
> 	{
> 		return atomic_read(&sk->sk_wmem_alloc) > 1 ||
> 			atomic_read(&sk->sk_rmem_alloc);
> 	}
> 
> and then make the various network protocols use that, rather than 
> open-coding some random internal implementation magic.

I agree, this should be handled with a helper function
abstraction rather than putting "1" checks all over the place.
