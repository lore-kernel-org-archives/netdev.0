From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] tap: convert a mutex to a spinlock
Date: Thu, 06 Jul 2017 10:52:24 +0100 (WEST)
Message-ID: <20170706.105224.2248990091127065553.davem@davemloft.net>
References: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borntraeger@de.ibm.com,
        sainath.grandhi@intel.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdGFJw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 05:52:28 -0400
In-Reply-To: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  5 Jul 2017 13:50:00 -0700

> We are not allowed to block on the RCU reader side, so can't
> just hold the mutex as before. As a quick fix, convert it to
> a spinlock.
> 
> Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Sainath Grandhi <sainath.grandhi@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I agree with Eric that we should use idr_preload() and
idr_preload_end() here so that we can still use GFP_KERNEL even though
we're now using a spinlock instead of a mutex.
