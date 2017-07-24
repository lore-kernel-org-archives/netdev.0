From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: re-add check for NULL skb->head in
 kfree_skb path
Date: Mon, 24 Jul 2017 16:28:05 -0700 (PDT)
Message-ID: <20170724.162805.1216261982332186633.davem@davemloft.net>
References: <20170723175447.28431-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44638 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbdGXX2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:28:05 -0400
In-Reply-To: <20170723175447.28431-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 23 Jul 2017 19:54:47 +0200

> A null check is needed after all.  netlink skbs can have skb->head be
> backed by vmalloc.  The netlink destructor vfree()s head, then sets it to
> NULL.  We then panic in skb_release_data with a NULL dereference.
> 
> Re-add such a test.
> 
> Alternative would be to switch to kvfree to free skb->head memory
> and remove the special handling in netlink destructor.
> 
> Reported-by: kernel test robot <fengguang.wu@intel.com>
> Fixes: 06dc75ab06943 ("net: Revert "net: add function to allocate sk_buff head without data area")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Ok, back it goes.

Applied, thanks.
