From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon, 02 Mar 2015 13:56:40 -0800
Message-ID: <1425333400.5130.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	 <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150302204203.GD9762@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38719 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbCBV4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:56:42 -0500
In-Reply-To: <20150302204203.GD9762@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 21:42 +0100, Florian Westphal wrote:

> Thats right.  Do you think its worth to already move cb[] near the end
> of skb and alter build_skb to not clear it anymore?
> 
> Which of the ideas, in your opinion, is worth pursuing first (if any)?

moving cb[] near the end will void my patches to use one cache line per
skb in TCP receive queue ( or write queue)

971f10eca186ca tcp: better TCP_SKB_CB layout to reduce cache line misses


I have worked a bit (3 months ago) about doing the skb->cb[] selective
clearing, but a lot of alloc_skb() users _assume_ it is already
cleared. 

That seemed a lot of work to me, because of the many alloc_skb()
variants we have. But definitely worth trying to complete.
