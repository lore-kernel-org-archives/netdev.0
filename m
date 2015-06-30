From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Tue, 30 Jun 2015 16:49:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1506301646500.5359@chino.kir.corp.google.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com> <557AA834.8070503@suse.cz> <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com> <20150618143019.GE5858@dhcp22.suse.cz> <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
 <20150618144311.GF5858@dhcp22.suse.cz> <5582E240.8080704@suse.cz> <20150618154716.GH5858@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Eric Dumazet <edumazet@google.com>, Shaohua Li <shli@fb.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org,
	dbavatar@gmail.com
To: Michal Hocko <mhocko@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34979 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbbF3Xt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 19:49:28 -0400
Received: by igblr2 with SMTP id lr2so86419198igb.0
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2015 16:49:27 -0700 (PDT)
In-Reply-To: <20150618154716.GH5858@dhcp22.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jun 2015, Michal Hocko wrote:

> That is to be discussed. Most allocations already express their interest
> in memory reserves by __GFP_HIGH directly or by GFP_ATOMIC indirectly.
> So maybe we do not need any additional flag here. There are not that
> many ~__GFP_WAIT and most of them seem to require it _only_ because the
> context doesn't allow for sleeping (e.g. to prevent from deadlocks).
> 

We're talking about a patch that is being backported to stable.  
Regardless of what improvements can be made to specify that an allocation 
shouldn't be able to access reserves (and what belongs solely in the page 
allocator proper) independent of __GFP_NO_KSWAPD, that can be cleaned up 
at a later time.  I don't anticipate that cleanup to be backported to 
stable, and my primary concern here is the ability for this allocations to 
now access, and possibly deplete, memory reserves.
