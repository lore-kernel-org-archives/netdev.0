From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Thu, 19 Jul 2012 10:53:54 -0700 (PDT)
Message-ID: <20120719.105354.1512390551884485493.davem@davemloft.net>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, amirv@mellanox.com,
	brking@linux.vnet.ibm.com, leitao@linux.vnet.ibm.com,
	klebers@linux.vnet.ibm.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2GSRxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:53:55 -0400
In-Reply-To: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 16 Jul 2012 14:01:53 -0300

> In its receive path, mlx4_en driver maps each page chunk that it pushes
> to the hardware and unmaps it when pushing it up the stack. This limits
> throughput to about 3Gbps on a Power7 8-core machine.
> 
> One solution is to map the entire allocated page at once. However, this
> requires that we keep track of every page fragment we give to a
> descriptor. We also need to work with the discipline that all fragments will
> be released (in the sense that it will not be reused by the driver
> anymore) in the order they are allocated to the driver.
> 
> This requires that we don't reuse any fragments, every single one of
> them must be reallocated. We do that by releasing all the fragments that
> are processed and only after finished processing the descriptors, we
> start the refill.
> 
> We also must somehow guarantee that we either refill all fragments in a
> descriptor or none at all, without resorting to giving up a page
> fragment that we would have already given. Otherwise, we would break the
> discipline of only releasing the fragments in the order they were
> allocated.
> 
> This has passed page allocation fault injections (restricted to the
> driver by using required-start and required-end) and device hotplug
> while 16 TCP streams were able to deliver more than 9Gbps.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

I have not seen any reasonable objections to this patch, so I have
applied it to net-next, thanks!
