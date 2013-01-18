From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xfrm: fix freed block size calculation in
 xfrm_policy_fini()
Date: Fri, 18 Jan 2013 14:43:15 -0500 (EST)
Message-ID: <20130118.144315.1258314605128988201.davem@davemloft.net>
References: <20130118153446.3AE05C1AFE@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab3ARTnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:43:17 -0500
In-Reply-To: <20130118153446.3AE05C1AFE@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 18 Jan 2013 16:03:48 +0100

> Missing multiplication of block size by sizeof(struct hlist_head)
> can cause xfrm_hash_free() to be called with wrong second argument
> so that kfree() is called on a block allocated with vzalloc() or
> __get_free_pages() or free_pages() is called with wrong order when
> a namespace with enough policies is removed.
> 
> Bug introduced by commit a35f6c5d, i.e. versions >= 2.6.29 are
> affected.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

I'll let Steffen pick this one up.
