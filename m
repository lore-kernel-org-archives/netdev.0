From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Thu, 15 Oct 2015 13:53:11 -0700
Message-ID: <1444942391.25595.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444906569-9131-1-git-send-email-kernel@kyup.com>
	 <1444915978.4200.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <561FAD24.4050708@kyup.com>
	 <1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
	 <1444934818.25595.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJFSNy6TaL1padva6euP1-8XFFwPFnBYgsMaEmeWrHpf8AJM-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Nikolay Borisov <kernel@kyup.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Nikolay Borisov <n.borisov@siteground.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36841 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbbJOUxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 16:53:14 -0400
In-Reply-To: <CAJFSNy6TaL1padva6euP1-8XFFwPFnBYgsMaEmeWrHpf8AJM-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-15 at 23:20 +0300, Nikolay Borisov wrote:

> While GFP_ATOMIC does indeed look the correct solution for this particular
> case I was wondering whether something like (GFP_KERNEL & ~__GFP_WAIT)
> wouldn't also make the cut without causing sleeping? I guess this is exactly
> the sort of situation that Mel Gorman's patch can address
> (marc.info/?l=linux-kernel&m=144283282101953) ?

This is not applicable here, because the caller would have to find a way
to keep trying.

I believe one way to handle this problem (in a followup patch) would be
to use a work queue for the gc, not a timer.

Using a timer for gc is almost always subject to big problems anyway.

Thanks.
