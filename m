From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix for a race condition in the inet frag code
Date: Wed, 05 Mar 2014 20:34:53 -0500 (EST)
Message-ID: <20140305.203453.493197545857379985.davem@davemloft.net>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
	<1393885158-4116-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, brouer@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757327AbaCFBe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 20:34:57 -0500
In-Reply-To: <1393885158-4116-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon,  3 Mar 2014 23:19:18 +0100

> The fix is simple, just move the lru_add under the hash chain locked
> region so when a removing function is called it'll have to wait for the
> fragment to be added to the lru_list, and then it'll remove it (it works
> because the hash chain removal is done before the lru_list one and
> there's no window between the two list adds when the frag can get
> dropped). With this fix applied I couldn't kill the same machine in 24
> hours with the same setup.
> 
> Fixes: 3ef0eb0db4bf ("net: frag, move LRU list maintenance outside of
> rwlock")

Applied and queued up for -stable, thanks.
