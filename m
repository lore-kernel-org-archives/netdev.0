From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Mon, 5 Jan 2009 15:05:28 +0100
Message-ID: <20090105140528.GR496@one.firstfloor.org>
References: <20090104162826.GT496@one.firstfloor.org> <1231087288.3296.15.camel@johannes> <20090104174339.GX496@one.firstfloor.org> <1231090388.3296.17.camel@johannes> <20090104184136.GY496@one.firstfloor.org> <1231144574.3286.15.camel@johannes> <20090105132141.GO496@one.firstfloor.org> <1231161379.3334.14.camel@johannes> <20090105133657.GQ496@one.firstfloor.org> <1231162275.3334.20.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com,
	davem <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41018 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbZAENvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:51:41 -0500
Content-Disposition: inline
In-Reply-To: <1231162275.3334.20.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 02:31:15PM +0100, Johannes Berg wrote:
> I was under the impression that you only modified monitor mode code, but
> upon closer inspection (really, you should diff with -p, makes it a lot
> easier to review) it seems that you also touched packet defragmentation
> code. Are you running a low fragmentation threshold on your network?

I don't use any special settings, only defaults.

> Can you
> check /sys/kernel/debug/ieee80211/phy*/statistics/rx_expand_skb_head*
> please?

The kernel doesn't have 80211 debugging enabled. I can enable 
it, but it will take some time until the messages reappear
(I cannot reproduce them at will, but have to wait)

> 
> > > actually used those skbs then it's likely that the warning didn't result
> > > in any corruption at all.
> > 
> > Nothing was corrupted ever to my knowledge, just lots of spam in my kernel logs.
> 
> You wouldn't easily notice any socket memory charge corruption anyway.

There are WARN_ON(sk->sk_forward_alloc)s in the socket destroy paths
which should trigger.

-Andi

-- 
ak@linux.intel.com
