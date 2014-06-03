From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec] xfrm: fix race between netns cleanup and state
 expire notification
Date: Tue, 03 Jun 2014 16:07:59 -0700 (PDT)
Message-ID: <20140603.160759.1806413663422270154.davem@davemloft.net>
References: <20140603082606.C28C1A3A9B@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933847AbaFCXIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 19:08:00 -0400
In-Reply-To: <20140603082606.C28C1A3A9B@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue,  3 Jun 2014 10:26:06 +0200 (CEST)

> The xfrm_user module registers its pernet init/exit after xfrm
> itself so that its net exit function xfrm_user_net_exit() is
> executed before xfrm_net_exit() which calls xfrm_state_fini() to
> cleanup the SA's (xfrm states). This opens a window between
> zeroing net->xfrm.nlsk pointer and deleting all xfrm_state
> instances which may access it (via the timer). If an xfrm state
> expires in this window, xfrm_exp_state_notify() will pass null
> pointer as socket to nlmsg_multicast().
> 
> As the notifications are called inside rcu_read_lock() block, it
> is sufficient to retrieve the nlsk socket with rcu_dereference()
> and check the it for null.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Looks good, applied, thanks Michal.
