From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net core: optimize netdev_create_hash()
Date: Fri, 15 Mar 2013 17:39:30 -0400 (EDT)
Message-ID: <20130315.173930.609483181280202005.davem@davemloft.net>
References: <1363365131-7906-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522Ab3COVjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 17:39:16 -0400
In-Reply-To: <1363365131-7906-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sat, 16 Mar 2013 00:32:11 +0800

> netdev_create_hash() is divded into two steps:
> 1. allocate space for hash_head
> 2. initialize hash_head->first to NULL for each hash_head
> 
> This patch merge the two steps into one step.
> 
> When allocating the space for hash_head, it will use kzalloc() instead of
> kmalloc(). Then hash_head->first is set to NULL during the allocation step,
> which means it is not necessary to call INIT_HLIST_HEAD() for each hash_head.
> 
> This will:
> 1. reduce the code size
> 2. reduce the run time of iteration on initializing hash_head array

Please do not ever post changes like this.

This makes assumtions about the list head implementation that
we should not make.  If someone adds a debugging facility that
causes lists to be initialized differently, it will be broken
for this hash table now.

The reason the abstractions exist is so that people do not
do things like you are trying to do.

If you want to add an interface in the generic list facilities which
performs this simplifcation, fine.  Implement it and post such a
suggestion to linux-kernel, and then once such a facility is present
in Linus's tree we can start using it in the networkng code.
