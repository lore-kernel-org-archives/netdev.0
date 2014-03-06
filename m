From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: make slave status notifications
 GFP_ATOMIC
Date: Thu, 06 Mar 2014 14:56:55 -0500 (EST)
Message-ID: <20140306.145655.2060309492608052731.davem@davemloft.net>
References: <1394116402-5585-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas@glanzmann.de,
	dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbaCFT45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:56:57 -0500
In-Reply-To: <1394116402-5585-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu,  6 Mar 2014 15:33:22 +0100

> Currently we're using GFP_KERNEL, however there are some path(s) where we
> can hold some spinlocks, specifically bond->curr_slave_lock:
> 
> [    4.722916] BUG: sleeping function called from invalid context at mm/slub.c:965
> [    4.724438] in_atomic(): 1, irqs_disabled(): 0, pid: 940, name: ifup-eth
> [    4.726034] 5 locks held by ifup-eth/940:
> ...snip...
> [    4.734646]  #4:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa00badc6>] bond_enslave+0xda6/0xdd0 [bonding]
> ...snip...
> [    4.759081]  [<ffffffffa00b6f11>] bond_change_active_slave+0x191/0x3b0 [bonding]
> [    4.760917]  [<ffffffffa00b7227>] bond_select_active_slave+0xf7/0x1d0 [bonding]
> [    4.762751]  [<ffffffffa00badce>] bond_enslave+0xdae/0xdd0 [bonding]
> ...snip...
> 
> As it's out of hot path and is a really rare event - change the gfp_t flags
> to GFP_ATOMIC to avoid sleeping under spinlock.
> 
> v2: convert new notify calls to GFP_ATOMIC.
> 
> CC: Thomas Glanzmann <thomas@glanzmann.de>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
