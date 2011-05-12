From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] garp: remove last synchronize_rcu() call
Date: Thu, 12 May 2011 17:47:12 -0400 (EDT)
Message-ID: <20110512.174712.228493075378622339.davem@davemloft.net>
References: <1304948155.3342.32.camel@edumazet-laptop>
	<4DC831B0.80107@trash.net>
	<1305206957.3795.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, greearb@candelatech.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757968Ab1ELVta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 17:49:30 -0400
In-Reply-To: <1305206957.3795.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 May 2011 15:29:17 +0200

> [PATCH net-next-2.6] garp: remove last synchronize_rcu() call
> 
> When removing last vlan from a device, garp_uninit_applicant() calls
> synchronize_rcu() to make sure no user can still manipulate struct
> garp_applicant before we free it.
> 
> Use call_rcu() instead, as a step to further net_device dismantle
> optimizations.
> 
> Add the temporary garp_cleanup_module() function to make sure no pending
> call_rcu() are left at module unload time [ this will be removed when
> kfree_rcu() is available ]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks Eric.
