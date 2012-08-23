From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: fix RCU bugs
Date: Wed, 22 Aug 2012 22:40:17 -0700 (PDT)
Message-ID: <20120822.224017.847590732390009999.davem@davemloft.net>
References: <1345372308.5158.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fan.du@windriver.com,
	fengguang.wu@intel.com, Priyanka.Jain@freescale.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab2HWFkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 01:40:20 -0400
In-Reply-To: <1345372308.5158.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 19 Aug 2012 12:31:48 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch reverts commit 56892261ed1a (xfrm: Use rcu_dereference_bh to
> deference pointer protected by rcu_read_lock_bh), and fixes bugs
> introduced in commit 418a99ac6ad ( Replace rwlock on xfrm_policy_afinfo
> with rcu )
> 
> 1) We properly use RCU variant in this file, not a mix of RCU/RCU_BH
> 
> 2) We must defer some writes after the synchronize_rcu() call or a reader
>  can crash dereferencing NULL pointer.
> 
> 3) Now we use the xfrm_policy_afinfo_lock spinlock only from process
> context, we no longer need to block BH in xfrm_policy_register_afinfo()
> and xfrm_policy_unregister_afinfo()
> 
> 4) Can use RCU_INIT_POINTER() instead of rcu_assign_pointer() in
> xfrm_policy_unregister_afinfo()
> 
> 5) Remove a forward inline declaration (xfrm_policy_put_afinfo()),
>   and also move xfrm_policy_get_afinfo() declaration.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
