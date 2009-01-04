From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Sun, 4 Jan 2009 19:41:36 +0100
Message-ID: <20090104184136.GY496@one.firstfloor.org>
References: <20090104151819.GA6590@basil.nowhere.org> <1231085150.3296.3.camel@johannes> <20090104162826.GT496@one.firstfloor.org> <1231087288.3296.15.camel@johannes> <20090104174339.GX496@one.firstfloor.org> <1231090388.3296.17.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com,
	davem <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55942 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbZADS1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 13:27:51 -0500
Content-Disposition: inline
In-Reply-To: <1231090388.3296.17.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 04, 2009 at 06:33:08PM +0100, Johannes Berg wrote:
> On Sun, 2009-01-04 at 18:43 +0100, Andi Kleen wrote:
> 
> > > we need to do is figure out is why the skb has a wrong truesize.
> > 
> > Because it was expanded without truesize being adjusted (see my
> > original mail) 
> 
> So why is this not making trouble with all the other users?

I think most adjustments are too small to be noticed. Typically
they are just for a few bytes in the header. truesize
is already larger, so it can tolerate some slag.

I also only see it occasionally (maybe 5-10 times/day) when
the wireless stack appends a lot of data.

My proposal would be to include this patch for 2.6.28/2.6.29
and investigate fixing pskb_expand_head for 2.6.30.

-Andi

-- 
ak@linux.intel.com
