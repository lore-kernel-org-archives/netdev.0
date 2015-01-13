From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] remove nl_sk_hash_lock from netlink
 socket
Date: Tue, 13 Jan 2015 14:01:23 -0500 (EST)
Message-ID: <20150113.140123.1462176338597652543.davem@davemloft.net>
References: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbbAMTB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:01:26 -0500
In-Reply-To: <1421045544-13670-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 12 Jan 2015 14:52:21 +0800

> After tipc socket successfully avoids the involvement of an extra lock
> with rhashtable_lookup_insert(), it's possible for netlink socket to
> remove its hash socket lock now. But as netlink socket needs a compare
> function to look for an object, we first introduce a new function
> called rhashtable_lookup_compare_insert() in commit #1 which is
> implemented based on original rhashtable_lookup_insert(). We
> subsequently remove nl_sk_hash_lock from netlink socket with the new
> introduced function in commit #2. Lastly, as Thomas requested, we add
> commit #3 to indicate the implementation of what the grow and shrink
> decision function must enforce min/max shift.
> 
> v2:
>  As Thomas pointed out, there was a race between checking portid and
>  then setting it in commit #2. Now use socket lock to make the process
>  of both checking and setting portid atomic, and then eliminate the
>  race.

Series applied, thanks.
