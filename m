From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
Date: Wed, 04 Sep 2013 14:13:01 -0400 (EDT)
Message-ID: <20130904.141301.41040920905693536.davem@davemloft.net>
References: <20130902213128.GB14301@marquez.int.rhx>
	<20130903001331.GA8820@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michele@acksyn.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, sasha.levin@oracle.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759624Ab3IDSNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:13:02 -0400
In-Reply-To: <20130903001331.GA8820@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 3 Sep 2013 02:13:31 +0200

> Hi!
> 
> On Mon, Sep 02, 2013 at 10:31:28PM +0100, Michele Baldessari wrote:
>> with the latest linux master git tree from Linus
>> (248d296d6d9df384996c2ed95676b367d876d48c - 2 Sep) I can reproduceably oops 
>> the kernel with the following commands:
>> ip addrlabel flush
>> ip addrlabel add prefix ::1/128              label 0
>> ip addrlabel add prefix ::/0                 label 1
> 
> Thanks for the report! This patch should fix this issue:
> 
> [PATCH] ipv6: fix null pointer dereference in __ip6addrlbl_add
> 
> Commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a ("hlist: drop
> the node parameter from iterators") changed the behavior of
> hlist_for_each_entry_safe to leave the p argument NULL.
> 
> Fix this up by tracking the last argument.
> 
> Reported-by: Michele Baldessari <michele@acksyn.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
