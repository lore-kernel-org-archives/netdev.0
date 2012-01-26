From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Allow ipv6 proxies and arp proxies be shown with ip
Date: Wed, 25 Jan 2012 21:40:08 -0500 (EST)
Message-ID: <20120125.214008.1103747130532025776.davem@davemloft.net>
References: <1327484698-344265-1-git-send-email-antonz@parallels.com>
	<20120125225931.GA11019@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antonz@parallels.com, ynot@mohnatka.ru, netdev@vger.kernel.org,
	xemul@parallels.com
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab2AZCkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:40:51 -0500
In-Reply-To: <20120125225931.GA11019@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Thu, 26 Jan 2012 02:59:31 +0400

> I see two variants:
> 
> 1. On request to list proxy entries, ip utility could send request containing
>    full ndmsg with NTF_PROXY set in ndm_flags. When kernel sees request without NTF_PROXY,
>    it dumps normal neighbor table. When it sees NTF_PROXY, it dumps proxy table instead.
> 
>    From user viewpoint, "ip neigh list ..." works as usual, "ip neigh list proxy ..." will list
>    proxy entries.
> 
> 2. Adding RTM_*PNEIGH and the whole new set of "ip pneigh ..." commands.
>    Logically, I would prefer this solution and, unless I was lazy 10 years ago, I would
>    go this way. Unfortunately, this will break compatibility with existing
>    "ip neigh add/del proxy ...", so that the kludge to intercept NTF_PROXY command in RTM_*NEIGH
>    is still required and the solution loses half of its beauty.
> 
> So, seems #1 looks better.

Agreed.
