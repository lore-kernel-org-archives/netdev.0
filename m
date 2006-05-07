From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netdev: hotplug napi race cleanup
Date: Sat, 06 May 2006 18:09:47 -0700 (PDT)
Message-ID: <20060506.180947.35317492.davem@davemloft.net>
References: <20060421102503.4e44eb28@localhost.localdomain>
	<E1FX5zQ-000177-00@gondolin.me.apana.org.au>
	<20060424152341.094b72d8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, patrakov@ums.usu.ru,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22209
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751172AbWEGBJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 21:09:51 -0400
To: shemminger@osdl.org
In-Reply-To: <20060424152341.094b72d8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 24 Apr 2006 15:23:41 -0700

> This follows after the earlier two patches.
> 
> Change the initialization of the class device portion of the net device
> to be done earlier, so that any races before registration completes are
> harmless.  Add a mutex to avoid changes to netdevice during the
> class device registration. 
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I'm not going to apply this patch and instead request that we think
about why this problem exists in the first place.

This patch is even stronger evidence that doing the sysfs registry in
the todo list processing is wrong.  If you can legally do this while
holding the rtnl semaphore, you can just as equally do it inside of
register_netdevice() which is where it truly belongs.

Then you can handle errors properly, unwind the state, and return the
error to the caller instead of just losing the error and leaving the
device in a half-registered state.
