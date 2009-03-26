From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: RDMA/nes: Fix mis-merge
Date: Thu, 26 Mar 2009 16:41:15 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903261639150.3994@localhost.localdomain>
References: <20090326.152515.43533230.davem@davemloft.net> <alpine.LFD.2.00.0903261555290.3032@localhost.localdomain> <adahc1fuarm.fsf_-_@cisco.com> <20090326.163114.131582923.davem@davemloft.net> <alpine.LFD.2.00.0903261638360.3994@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52248 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753776AbZCZXnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 19:43:39 -0400
In-Reply-To: <alpine.LFD.2.00.0903261638360.3994@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 26 Mar 2009, Linus Torvalds wrote:

> 
> 
> On Thu, 26 Mar 2009, David Miller wrote:
> > 
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> Can I get a sign-off from Roland too?

Btw, as far as I can tell, that function had never been tested with any 
polling. It had a line like

	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);

but that line was _before_ 'nesvnic' was actually initialized (well, it 
had been initialized to NULL, so it passed in some NULL-pointer-offset to 
that function).

I moved that initialization up in the merge, but I obviously didn't test 
anything. So I'd suggest somebody actually test this case, because it 
clearly must have  gotten no testing at all.

			Linus
