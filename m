From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 17:03:33 -0400
Message-ID: <20121019210333.GI8315@kvack.org>
References: <20121019195557.GG17417@1wt.eu> <20121019.160104.115897882147794932.davem@davemloft.net> <20121019200318.GH17417@1wt.eu> <20121019.160711.1159467896676133280.davem@davemloft.net> <20121019201430.GI17417@1wt.eu> <20121019202244.GH8315@kvack.org> <20121019205300.GJ17417@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:44836 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab2JSVDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 17:03:34 -0400
Content-Disposition: inline
In-Reply-To: <20121019205300.GJ17417@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 10:53:00PM +0200, Willy Tarreau wrote:
> I see. Then users will have the same issue when upgrading from 2.6.32 to 3.0.
> 
> OK let's bisect the situation :
>   - current 2.6.32 users are facing a routing bug that needs be fixed.
> 
>   - 2.6.34 and onwards do not have this bug but are probably affected by
>     lower performance due to the minimal fix.

Argh, sorry (too many patches in flight), it looks like just cherry picking 
d11a4dc18bf41719c9f0d7ed494d295dd2973b92 is okay.  It does have the 
rt_is_expired() changes, so it should not have much of a performance 
regression.  So going with only this change is probably the way to go 
for now.

		-ben
