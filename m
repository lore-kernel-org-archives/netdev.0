From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Fri, 17 Apr 2009 04:56:31 -0700 (PDT)
Message-ID: <20090417.045631.159492677.davem@davemloft.net>
References: <49E5FF5E.50409@cosmosbay.com>
	<20090415215454.GU6766@linux.vnet.ibm.com>
	<49E6C4C7.3050105@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755412AbZDQL4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 07:56:40 -0400
In-Reply-To: <49E6C4C7.3050105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 16 Apr 2009 07:40:23 +0200

> [PATCH] net: remove superfluous call to synchronize_net()
> 
> inet_register_protosw() function is responsible for adding a new
> inet protocol into a global table (inetsw[]) that is used with RCU rules.
> 
> As soon as the store of the pointer is done, other cpus might see
> this new protocol in inetsw[], so we have to make sure new protocol
> is ready for use. All pending memory updates should thus be committed
> to memory before setting the pointer.
> This is correctly done using rcu_assign_pointer()
> 
> synchronize_net() is typically used at unregister time, after
> unsetting the pointer, to make sure no other cpu is still using
> the object we want to dismantle. Using it at register time
> is only adding an artificial delay that could hide a real bug,
> and this bug could popup if/when synchronize_rcu() can proceed
> faster than now.
> 
> This saves about 13 ms on boot time on a HZ=1000 8 cpus machine  ;) 
> (4 calls to inet_register_protosw(), and about 3200 us per call)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I think this change is fine, so I'm adding it to net-next-2.6

If you guys want to continue discussing the merits of putting
comments in every spot where we lack a RCU sync call, that's
your call. :-)

